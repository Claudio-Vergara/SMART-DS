clc
clearvars
dbstop if error
tic;

addpath(genpath(fullfile('C:\SMART-DS')));

dataFolder='C:\Dropbox (MIT)\SMART_DS\data\cities\Greensboro_NC';

%%
nBuildings=19;
load=nan(8760,nBuildings); % each column is a building type
a=dir(fullfile(dataFolder,'load profiles'));
for i=3:21
    
bData=csvread(fullfile(dataFolder,'load profiles',a(i).name),1,1);
load(:,i-2)=bData(:,1); % kW    
end
peakLoad=max(load);
minLoad=min(load);
avLoad=mean(load);
energy=sum(load);
xlswrite(fullfile(dataFolder,'summary_load.xlsx'),peakLoad',1,'D2:D20');
xlswrite(fullfile(dataFolder,'summary_load.xlsx'),minLoad',1,'E2:E20');
xlswrite(fullfile(dataFolder,'summary_load.xlsx'),avLoad',1,'F2:F20');
xlswrite(fullfile(dataFolder,'summary_load.xlsx'),energy',1,'G2:G20');

buildingData=readtable(fullfile(dataFolder,'summary_load.xlsx'));