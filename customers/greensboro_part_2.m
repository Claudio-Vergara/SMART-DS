%% Configuration                                                          
% this script requires the workspace saved at the end of
% greensboro_part_1.m
clc
clearvars
fclose all;
addpath(fullfile('C:\SMART-DS\libraries'));

dataset='combined'; % urban, suburban, or combined
rootFolder=fullfile('C:\Dropbox (MIT)\SMART_DS\data\Dataset 3');
dataFolder=fullfile(rootFolder,'Greensboro_Cold');
shapefilesFolder=fullfile(rootFolder,'Greensboro_shared\shapefiles');

d=15; % distance between the auxiliary consumers for the street map
pf=0.9; % inductive power factor of all the loads
lf=[0.25 0.4]; % load factor [LV MV]
cf=[0.4 0.8]; % peak-coincidence factor [LV MV]
LV=0.416;
MV=12.47;
areaPerUser=180; %m^2
prob_has_PV=0.005;
min_size_PV=1; %kW
PV_eff=0.2;
areaTolerance=0.3;
%% Switch output folders
switch dataset
    case 'urban'
        outputFolder=fullfile(dataFolder,'dataset3_urban');
    case 'suburban'
        outputFolder=fullfile(dataFolder,'dataset3_suburban');
    case 'combined'        
        outputFolder=fullfile(dataFolder,'dataset3_urban_suburban');
end

%% Load data
% part 1 workspace
load(fullfile(rootFolder,'Greensboro_shared\Greensboro_part_1.mat'));
nBuildings=length(users.x);

% suburban boundary
suburban_boundary=shaperead(fullfile(shapefilesFolder,'suburban_boundary.shp'));
subPolyLat=suburban_boundary.Y(1:end-1);
subPolyLon=suburban_boundary.X(1:end-1);
[subPolyX,subPolyY,~]=deg2utm(subPolyLat,subPolyLon);

% buildings information
buildingTypesData=readtable(fullfile(dataFolder,'summary_load.xlsx'));
%% Assign peak power                                                        
users.p=zeros(nBuildings,1);
users.type=zeros(nBuildings,1);
users.scaleFactor=ones(nBuildings,1);
users.height=[buildings_deg.Height1]'*0.3;
users.levels=ceil(users.height/3.5); % assuming 3.5 m per level
users.totalArea=users.area.*users.levels;
for i=1:nBuildings
    pType=users.parcelType(i);
    totArea=users.totalArea(i);
    
switch pType
    case 1 % residential
     resIndices=[6,17,18,19];
    [M,I]= min(abs(totArea-buildingTypesData{resIndices,3}));
    scaleFactor=1-(buildingTypesData{resIndices(I),3}-totArea)/...
           buildingTypesData{resIndices(I),3};
   if scaleFactor<1-areaTolerance
       users.scaleFactor(i)=scaleFactor;
    users.p(i)=scaleFactor*buildingTypesData{resIndices(I),4};
   else   
    users.p(i)=buildingTypesData{resIndices(I),4};
   end
    users.type(i)=resIndices(I);
    case 2 % commercial
        comIndices=[1,7,9];
        [M,I]= min(abs(totArea-buildingTypesData{comIndices,3}));
        scaleFactor=1-(buildingTypesData{comIndices(I),3}-totArea)/...
           buildingTypesData{comIndices(I),3};
   if scaleFactor<1-areaTolerance
       users.scaleFactor(i)=scaleFactor;
    users.p(i)=scaleFactor*buildingTypesData{comIndices(I),4};
   else   
        users.p(i)=buildingTypesData{comIndices(I),4};
   end
        users.type(i)=comIndices(I);
    case 3 % office
        ofIndices=[4,5,12];
        [M,I]= min(abs(totArea-buildingTypesData{ofIndices,3}));
        
        scaleFactor=1-(buildingTypesData{ofIndices(I),3}-totArea)/...
            buildingTypesData{ofIndices(I),3};
        if scaleFactor<1-areaTolerance
            users.scaleFactor(i)=scaleFactor;
            users.p(i)=scaleFactor*buildingTypesData{ofIndices(I),4};
        else
            users.p(i)=buildingTypesData{ofIndices(I),4};
        end
        users.type(i)=ofIndices(I);
    case 4 % industrial
        users.p(i)=0.1*users.area(i); %guess for industrial specific load
        users.type(i)=0;
    case 5 % hotel
        hotIndices=[3,11];
    [M,I]= min(abs(totArea-buildingTypesData{hotIndices,3}));
    
    scaleFactor=1-(buildingTypesData{hotIndices(I),3}-totArea)/...
           buildingTypesData{hotIndices(I),3};
   if scaleFactor<1-areaTolerance
       users.scaleFactor(i)=scaleFactor;
    users.p(i)=scaleFactor*buildingTypesData{hotIndices(I),4};
   else   
    users.p(i)=buildingTypesData{hotIndices(I),4};
   end
    users.type(i)=hotIndices(I);
    case 6 % Institutional % there's no institutional-specific load type
        ofIndices=[4,5,12];
        [M,I]= min(abs(totArea-buildingTypesData{ofIndices,3}));
        scaleFactor=1-(buildingTypesData{ofIndices(I),3}-totArea)/...
           buildingTypesData{ofIndices(I),3};
   if scaleFactor<1-areaTolerance
       users.scaleFactor(i)=scaleFactor;
    users.p(i)=scaleFactor*buildingTypesData{ofIndices(I),4};
   else   
        users.p(i)=buildingTypesData{ofIndices(I),4};
   end
        users.type(i)=ofIndices(I);
    case 7 % retail
        retIndices=[13,14,15];
        [M,I]= min(abs(totArea-buildingTypesData{retIndices,3}));
        scaleFactor=1-(buildingTypesData{retIndices(I),3}-totArea)/...
           buildingTypesData{retIndices(I),3};
   if scaleFactor<1-areaTolerance
       users.scaleFactor(i)=scaleFactor;
    users.p(i)=scaleFactor*buildingTypesData{retIndices(I),4};
   else   
        users.p(i)=buildingTypesData{retIndices(I),4};
   end
        users.type(i)=retIndices(I);
    case 8 % schools
    schIndices=[8,10];
    [M,I]= min(abs(totArea-buildingTypesData{schIndices,3}));
    scaleFactor=1-(buildingTypesData{schIndices(I),3}-totArea)/...
           buildingTypesData{schIndices(I),3};
   if scaleFactor<1-areaTolerance
       users.scaleFactor(i)=scaleFactor;
    users.p(i)=scaleFactor*buildingTypesData{schIndices(I),4};
   else   
    users.p(i)=buildingTypesData{schIndices(I),4};
   end
    
    users.type(i)=schIndices(I);    
    case 9 % hospitals
    hospIndices=[8,10];
    scaleFactor=1-(buildingTypesData{2,3}-totArea)/...
           buildingTypesData{2,3};
   if scaleFactor<1-areaTolerance
       users.scaleFactor(i)=scaleFactor;
    users.p(i)=scaleFactor*buildingTypesData{2,4};
   else   
    users.p(i)=buildingTypesData{2,4};
   end
    users.type(i)=2;
    otherwise % assume residential       
    [M,I]= min(abs(totArea-buildingTypesData{resIndices,3}));
    scaleFactor=1-(buildingTypesData{resIndices(I),3}-totArea)/...
           buildingTypesData{resIndices(I),3};
   if scaleFactor<1-areaTolerance
       users.scaleFactor(i)=scaleFactor;
    users.p(i)=scaleFactor*buildingTypesData{resIndices(I),4};
   else   
    users.p(i)=buildingTypesData{resIndices(I),4};   
   end
    users.type(i)=resIndices(I);
end
end

users.p(users.p>50000)=50000; % cap the power at 50 MW 
isSuburbanUser=inpolygon(users.x,users.y,subPolyX,subPolyY);
isSuburbanMapUser=inpolygon(mapUsers.x,mapUsers.y,subPolyX,subPolyY);
%% Assign PV generation and inverters                                       
hasPV=binornd(1,prob_has_PV,[nBuildings,1])~=0;
users.PVkW=zeros(nBuildings,1);
PVPower=PV_eff*0.6*users.area.*rand(nBuildings,1);
users.PVkW(hasPV)=max(min_size_PV,round(PVPower(hasPV),1));
users.PVOrientation=randi(4,nBuildings,1); % maps to a power production profile
users.invkVA=users.PVkW; 
users.invType=zeros(nBuildings,1); % maps to control settings. 0 means no inverter 
users.invType(users.invkVA~=0)=1;
%% Compile other fields                                                     
users.nUsersEq=ones(nBuildings,1);
users.area=round(users.area);
users.q=users.p*tan(acos(pf));
users.s=sqrt(users.p.^2+users.q.^2);
users.v=LV*ones(nBuildings,1); % default to LV
users.nPhases=ones(nBuildings,1); % default to single phase
users.nPhases(users.v==LV & users.s>50)=3; % Move LV users of more than 30 kVA of peak power to 3 phase
users.v(users.s>1000)=MV; % if the load is greater than 1500 kVA of peak power, move to MV
users.nPhases(users.s>1000)=3; % Move all users of more than 300 kVA peak to 3 phase MV
users.z=zeros(nBuildings,1);
users.nUsersEq(users.v==LV & users.parcelType==1)=...
   max(1,round(users.area(users.v==LV & users.parcelType==1)/areaPerUser,0));
%% Write user codes                                                         
nLV=0;
nMV=0;
users.id={};
users.e=zeros(nBuildings,1);
users.cp=zeros(nBuildings,1);
users.cq=zeros(nBuildings,1);
for i=1:nBuildings
    if users.v(i)==LV
        nLV=nLV+1;
        if isSuburbanUser
            users.id{i,1}=['SCLV' num2str(nLV)];
        else
            users.id{i,1}=['UCLV' num2str(nLV)];
        end
    users.e(i)=round(users.p(i)*lf(1)*8760);  % yearly energy in kWh
    users.cp(i)=round(users.p(i)*cf(1),2); % peak-coincident power in kW
    users.cq(i)=round(users.q(i)*cf(1),2); % peak-coincident power in kW
    elseif users.v(i)==MV
        nMV=nMV+1;
        if isSuburbanUser
        users.id{i}=['SCMV' num2str(nMV)];
        else
            users.id{i}=['UCMV' num2str(nMV)];
        end            
        users.e(i)=round(users.p(i)*lf(2)*8760); % yearly energy in kWh
        users.cp(i)=round(users.p(i)*cf(2),2); % peak-coincident active power in kW
        users.cq(i)=round(users.q(i)*cf(2),2); % peak-coincident reactive power in kVA
    end        
end

nMapUsers=length(mapUsers.x);
for i=1:nMapUsers
    mapUsers.id{i,1}=['SM' num2str(i)];
end
mapUsers.z=zeros(nMapUsers,1);
%% Write files                                                              

switch dataset
    case 'urban'
        inArea=~isSuburbanUser;
        mapinArea=~isSuburbanMapUser;
    case 'suburban'
        inArea=isSuburbanUser;
        mapinArea=isSuburbanMapUser;
    case 'combined'
        inArea=true(size(users.x));
        mapinArea=true(size(mapUsers.x));
end

users.x=round(users.x,1);
users.y=round(users.y,1);
users.p=round(users.p,2);
users.q=round(users.q,2);

tUsers=table(users.x(inArea),users.y(inArea),users.z(inArea),...
    users.id(inArea),users.v(inArea),users.p(inArea),...
    users.q(inArea),users.nPhases(inArea));
writetable(tUsers,fullfile(outputFolder,'customers.txt'),'Delimiter',';','writeVariableNames',false);

variableNamesExtended={'x','y','z','id','v','p','q','nPhases','area',...
    'level','e','cp','cq','nUsersEq','type','PVkW','invkVA','invType','scaleFactor'};

tUsersExtended=table(users.x(inArea),users.y(inArea),users.z(inArea),...
    users.id(inArea),users.v(inArea),users.p(inArea),...
    users.q(inArea),users.nPhases(inArea),users.area(inArea),...
    users.levels(inArea),users.e(inArea),users.cp(inArea),...
    users.cq(inArea),users.nUsersEq(inArea),users.type(inArea),...
    users.PVkW(inArea),users.invkVA(inArea),users.invType(inArea),...
    users.scaleFactor(inArea),'VariableNames',variableNamesExtended);

writetable(tUsersExtended,fullfile(outputFolder,'customers_extended.txt'),...
    'Delimiter',';','WriteVariableNames',true);

mapUsers.x=round(mapUsers.x,1);
mapUsers.y=round(mapUsers.y,1);
tMapUsers=table(mapUsers.x(mapinArea),mapUsers.y(mapinArea),...
    mapUsers.z(mapinArea),mapUsers.id(mapinArea));
writetable(tMapUsers,fullfile(outputFolder,'PointStreetMap.txt'),'Delimiter',';','writeVariableNames',false);
%% Display summary info                                                     
clc
disp(['LV customers: ' num2str(sum(users.v==LV & inArea))]);
disp(['MV customers: ' num2str(sum(users.v==MV & inArea))]);
disp(['Single-phase customers: ' num2str(sum(users.nPhases==1 & inArea))]);
disp(['Three-phase LV customers: ' num2str(sum(users.v==LV & users.nPhases==3 & inArea))]);
disp(['Single-phase MV customers: ' num2str(sum(users.v==MV & users.nPhases==1 & inArea))]);
disp(['Three-phase customers: ' num2str(sum(users.nPhases==3 & inArea))]);
disp(['Sum of customer peaks: ' num2str(round(sum(users.s(inArea)),0)) ' kVA']);
disp(['Installed PV capacity: ' num2str(round(sum(users.PVkW(inArea)),0)) ' kW'] );

LV_peak=round(sum(users.p(users.v==LV & inArea))*cf(1),0);
MV_peak=round(sum(users.p(users.v==MV & inArea))*cf(2),0);

disp(['Approximate peak-coincident power: ' num2str(LV_peak+MV_peak) ' kVA.']);

%% Save the workspace

save(fullfile(dataFolder,['Greensboro_' dataset '.mat']));

