% Gergely Tak�cs, www.gergelytakacs.com
% No guarantees given, whatsoever.
% Ideas: Residuals plot, Weighted forgetting, ,

clc; clear; close all;
importData;
load dataSKpred;

d1=datetime(2020,3,6,'Format','d.M'); % First confirmed case
pDay=5;                  % Days to predict  
symptoms=5;              % Mean days before symptoms show
popSize=5.45;            % Population size in millions


dt = d1+length(Day);       % Length of last data
Date = datestr(d1:dt);     % Date array with data
dp = dt+pDay;              % End date ith prediction
DatePred = datestr(d1:dp); % Date array for predictions



Nd=cumsum(Confirmed); % Number of daily cases, cumulative sum of confirmed cases

%% Tests
totTest=negTest+Nd; %Total tests performed
popTest=totTest./popSize; % Tests per million people

newTest=diff(totTest);
changeTest=(newTest(end)/newTest(end-1)-1)*100; % Changes in testing

%NdLog=log2(Nd);

%% Growth factor
growthFactor= ([Nd; 0]./[0; Nd]);
growthFactor= (growthFactor(2:end-1)-1)*100;

%% Finding exponential fit to data

[fitresult,gof]=expFit(Day, Nd);
gF=fitresult.a; % Growth factor 
ci=confint(fitresult); % Confidence intervals at 95% confidentce
R2=gof.rsquare;
DayPred=1:1:length(Day)+pDay;

NdPredicted=round(gF.^DayPred);
NdPredHigh=round(ci(2).^DayPred);
NdPredLow=round(ci(1).^DayPred);


% dataSKpred(2,:)=[(max(Day)+1),NdPredicted(max(Day)+1), NdPredLow(max(Day)+1), NdPredHigh(max(Day)+1), gF, ci(1), ci(2)]
% save dataSKpred dataSKpred
%% Shift data



NdSymptoms=round(gF.^(DayPred+symptoms));
NdSymptomsHigh=round(ci(2).^(DayPred+symptoms));
NdSymptomsLow=round(ci(1).^(DayPred+symptoms));

%% Cases

figure(1)

patch([DayPred, DayPred(end:-1:1), DayPred(1)],[NdPredLow, NdPredHigh(end:-1:1),NdPredLow(1)],'r','EdgeAlpha',0,'FaceAlpha',0.2) % Confidence intervals
hold on
grid on
patch([DayPred, DayPred(end:-1:1), DayPred(1)],[NdSymptomsLow, NdSymptomsHigh(end:-1:1),NdSymptomsLow(1)],'b','EdgeAlpha',0,'FaceAlpha',0.2) % Confidence intervals

plot(Day,Nd,'.-','LineWidth',2) % Confirmed cumulative cases
bar(Day,Confirmed) % Confirmed new cases
plot(DayPred,NdPredicted) % Predicted cases

plot(DayPred,NdSymptoms) % Predicted Shifted Cases

% Previous predictions
plot(dataSKpred(:,1),dataSKpred(:,2),'k.')
errorbar(dataSKpred(:,1),dataSKpred(:,2),dataSKpred(:,2)-dataSKpred(:,3),dataSKpred(:,2)-dataSKpred(:,4),'k')

xticks(DayPred)
xticklabels(DatePred)
xtickangle(90)
xlabel('Date')
ylabel('Cases')
legend('95% Confidence (Confirmed prediction)','95% Confidence (Total, 5 d shift)','Cumulative confirmed','New confirmed',['Exp. Approximation (Confirmed) R^2=',num2str(R2)],['Exp. Approximation (Total)'],'Location','northwest')
title(['SARS-CoV-2 Cases in Slovakia, ',datestr(dt)])
axis([0,length(DayPred),0,NdSymptoms(max(Day)+1)])
text(0.2,0.9,'github.com/gergelytakacs/SK-COVID-19','FontSize',7,'rotation',90,'Color',[0.7 0.7 0.7])
text(0.6,0.9,'gergelytakacs.com','FontSize',7,'rotation',90,'Color',[0.7 0.7 0.7])
fig = gcf;
fig.PaperUnits = 'centimeters';
fig.PaperPosition = [0 0 20 10];

cd out
print(['skCOVID19_Cases_',datestr(dt)],'-dpng','-r0')
print(['skCOVID19_Cases_',datestr(dt)],'-dpdf','-r0')

axis([0,length(Day)+1,0,dataSKpred(end,4)])

print(['skCOVID19_Cases_Detail',datestr(dt)],'-dpng','-r0')
print(['skCOVID19_Cases_Detail',datestr(dt)],'-dpdf','-r0')
cd ..


%% Growth factor

figure(2)

% Previous predictions
plot(dataSKpred(:,1)-1,(dataSKpred(:,5)-1)*100,'k.')
errorbar(dataSKpred(:,1)-1,(dataSKpred(:,5)-1)*100,(dataSKpred(:,6)-1)*100-(dataSKpred(:,5)-1)*100,(dataSKpred(:,7)-1)*100-(dataSKpred(:,5)-1)*100,'k')
hold on
grid on

plot(Day(2:end),growthFactor,'.-','LineWidth',2) % Predicted Shifted Cases

xticks(DayPred)
xticklabels(DatePred)
xtickangle(90)
xlabel('Date')
ylabel('Growth factor [%]')
legend('Growth factor (fit)','Growth factor (data)','Location','northwest')
title(['SARS-CoV-2 Growth factor in Slovakia, ',datestr(dt)])
axis([2,length(Day+1),0,150])
text(2.2,2.9,'github.com/gergelytakacs/SK-COVID-19','FontSize',7,'rotation',90,'Color',[0.7 0.7 0.7])
text(2.6,2.9,'gergelytakacs.com','FontSize',7,'rotation',90,'Color',[0.7 0.7 0.7])

cd out
print(['skCOVID19_GrowthFactor_',datestr(dt)],'-dpng','-r0')
print(['skCOVID19_GrowthFactor_',datestr(dt)],'-dpdf','-r0')
cd ..

%% Testing

figure(3)

hold on
plot(Day,totTest,'.-','LineWidth',2) % Predicted Shifted Cases
bar(Day(2:end),newTest) % Confirmed new cases
grid on

xticks(DayPred)
xticklabels(DatePred)
xtickangle(90)
xlabel('Date')
ylabel('Tests')
legend('Total tests','New Tests','Location','northwest')
title(['SARS-CoV-2 Tests in Slovakia, ',datestr(dt)])
axis([1,max(Day)+1,0,max(totTest)])
text(1.2,2.9,'github.com/gergelytakacs/SK-COVID-19','FontSize',7,'rotation',90,'Color',[0.7 0.7 0.7])
text(1.6,2.9,'gergelytakacs.com','FontSize',7,'rotation',90,'Color',[0.7 0.7 0.7])

cd out
print(['skCOVID19_Tests_',datestr(dt)],'-dpng','-r0')
print(['skCOVID19_Tests_',datestr(dt)],'-dpdf','-r0')
cd ..

%% Print

disp(['SARS-CoV-2 na Slovensku'])
disp(['----------------------------'])
disp(['* V�hlad zmeny poctu pr�padov k ',datestr(dt),' * (aktualne do konca dna):'])
disp(' ')
disp(['Overen� pr�pady: ',num2str(NdPredicted(max(Day)+1)),' (',num2str(NdPredLow(max(Day)+1)),'-',num2str(NdPredHigh(max(Day)+1)),')']) %,'(',num2str(NdPredLow(max(Day)+1)),'-',NdPredHigh(max(Day)+1),')'])
disp(['Nov� overen� pr�pady: ',num2str(NdPredicted(max(Day)+1)-Nd(end)),' (',num2str(NdPredLow(max(Day)+1)-Nd(end)),'-',num2str(NdPredHigh(max(Day)+1)-Nd(end)),')']) %,'(',num2str(NdPredLow(max(Day)+1)),'-',NdPredHigh(max(Day)+1),')'])
disp(['Celkov� predpokladan� pocet nakazen�ch: ',num2str(NdSymptoms(max(Day)+1)),' (',num2str(NdSymptomsLow(max(Day)+1)),'-',num2str(NdSymptomsHigh(max(Day)+1)),')'])
disp(['Predpokladan� d�tum 100+ overen�ch pr�padov: ',datestr(d1+min(find(NdPredicted>100)))])
disp(['Faktor n�rastu: ',num2str(round((gF-1)*100*10)/10),'%, R^2=',num2str(R2)])
disp(['Zdvojenie pr�padov za: ',num2str( round((70/((gF-1)*100))*10)/10),' dn�'])
disp(' ')
disp(['* Stav testovania k ',datestr(dt-1),' (vratane) *'])
disp(' ')
disp(['Celkove testy na mil. obyvatelov: ',num2str(round(popTest(end)))])
disp(['Nove testy za den na mil. obyvatelov: ',num2str( round(newTest(end)/popSize))])
disp(['Denn� zmena intenzity testovania: ',num2str(round(changeTest)),'%'])


disp(['----------------------------'])
disp(['Viac na: https://github.com/gergelytakacs/SK-COVID-19'])

