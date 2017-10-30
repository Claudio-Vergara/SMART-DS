clc
clearvars
dbstop if error
tic;

addpath(fullfile('C:\SMART-DS\libraries'));
rootFolder=fullfile('C:\Dropbox (MIT)\SMART_DS\data\Dataset 3');
dataFolder=fullfile(rootFolder,'Greensboro_MixedHumid');

%%
nBuildings=19;
load=nan(8760,nBuildings); % each column is a building type
a=dir(fullfile(dataFolder,'load profiles'));
for i=3:21
    
bData=csvread(fullfile(dataFolder,'load profiles',a(i).name),1,1);
load(:,i-2)=bData(:,1); % kW    
end

floorArea=xlsread(fullfile(dataFolder,'summary_load.xlsx'),1,'C2:C20');

peakLoad=max(load);
minLoad=min(load);
avLoad=mean(load);
energy=sum(load);
loadFactor=avLoad./peakLoad;
areaSpecPeak=peakLoad'./floorArea;
areaSpecEnergy=energy'./floorArea;

xlswrite(fullfile(dataFolder,'summary_load.xlsx'),peakLoad',1,'D2:D20');
xlswrite(fullfile(dataFolder,'summary_load.xlsx'),minLoad',1,'E2:E20');
xlswrite(fullfile(dataFolder,'summary_load.xlsx'),avLoad',1,'F2:F20');
xlswrite(fullfile(dataFolder,'summary_load.xlsx'),energy',1,'G2:G20');
xlswrite(fullfile(dataFolder,'summary_load.xlsx'),loadFactor',1,'H2:H20');
xlswrite(fullfile(dataFolder,'summary_load.xlsx'),areaSpecPeak,1,'I2:I20');
xlswrite(fullfile(dataFolder,'summary_load.xlsx'),areaSpecEnergy,1,'J2:J20');

buildingData=readtable(fullfile(dataFolder,'summary_load.xlsx'));