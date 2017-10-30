clc
clearvars

%% Configure
%dataFolder='C:\Dropbox (MIT)\SMART_DS\data\cities\Greensboro_NC\KML';
addpath(fullfile('C:\SMART-DS\libraries'));

rootFolder=fullfile('C:\Dropbox (MIT)\SMART_DS\data\Dataset 3');
dataFolder=fullfile(rootFolder,'Greensboro_MixedHumid');

kmlFolder=fullfile(rootFolder,'Greensboro_shared\KML');
shapefilesFolder=fullfile(rootFolder,'Greensboro_shared\shapefiles');
outputFolder=fullfile(dataFolder,'dataset3_rural');
d=15; % distance between the auxiliary consumers for the street map
pf=0.9; % inductive power factor of all the loads
lf=[0.25 0.4]; % load factor [LV MV]
cf=[0.4 0.8]; % peak-coincidence factor [LV MV]
LV=0.416;
MV=12.47;
prob_has_PV=0.05;
min_size_PV=1; %kW
rng(1); 
validIndices=[8 9 14 16 17 18 19];
freqs=[2 10 1 50 500 137 300 ]; % per 1000 buildings


%% buildings information
buildingTypesData=readtable(fullfile(dataFolder,'summary_load.xlsx'));
indices=[];
for i=1:length(validIndices)
    indices=[indices;repmat(validIndices(i),freqs(i),1)];
end


%% Get building centers in meters 
R=kml2struct(fullfile(kmlFolder,'rural_buildings.kml'));
Lon=[];
Lat=[];

for i=1:length(R)
 Lon=[Lon;R(i).Lon];   
 Lat=[Lat;R(i).Lat]; 
end
nBuildings=length(Lon);

[users.x,users.y,~]=deg2utm(Lat,Lon);

users.type=indices(randi(length(indices),nBuildings,1));

%% Load roads                                                               
roads_deg=shaperead(fullfile(shapefilesFolder,'roads_rural.shp'));
roadSegs.x=[];
roadSegs.y=[];
nRoads=length(roads_deg);
nSubRoads=zeros(nRoads,1);
for i=1:nRoads
    nanLocs=find(isnan(roads_deg(i).X ));
    for j=1:length(nanLocs)
        if j==1
            subRoadLon=roads_deg(i).X(1:nanLocs(1)-1);
            subRoadLat=roads_deg(i).Y(1:nanLocs(1)-1);            
        else
            subRoadLon=roads_deg(i).X(nanLocs(j-1)+1:nanLocs(j)-1);
            subRoadLat=roads_deg(i).Y(nanLocs(j-1)+1:nanLocs(j)-1);
        end
        [subRoadX,subRoadY,~]=deg2utm(subRoadLat,subRoadLon);
        roadSegs.x=[roadSegs.x;[subRoadX(1:end-1),subRoadX(2:end)]];
        roadSegs.y=[roadSegs.y;[subRoadY(1:end-1),subRoadY(2:end)]];
    end
    nSubRoads(i)=j;
end

%% Virtual users for the creation of the roadmap                            
mapUsers.x=roadSegs.x(:,1);
mapUsers.y=roadSegs.y(:,1);

nRoadSegs=length(roadSegs.x);

for i=1:nRoadSegs
   segLength(i)=sqrt((roadSegs.x(i,2)-roadSegs.x(i,1))^2+...
       (roadSegs.y(i,2)-roadSegs.y(i,1))^2);
   segSlope(i)= (roadSegs.y(i,2)-roadSegs.y(i,1))/...
       (roadSegs.x(i,2)-roadSegs.x(i,1));
   nSegPoints(i)= max(0,floor(segLength(i)/d)-1);
   xPoints=roadSegs.x(i,1)+((roadSegs.x(i,2)-roadSegs.x(i,1))/(nSegPoints(i)+1)*...
       linspace(1,nSegPoints(i),nSegPoints(i)));
   yPoints=roadSegs.y(i,1)+segSlope(i)*(xPoints-roadSegs.x(i,1));
   mapUsers.x=[mapUsers.x;xPoints'];
   mapUsers.y=[mapUsers.y;yPoints'];
   
   if ~mod(i,1000)
        clc
        disp([num2str(i) ' road segments processed']);
    end   
end
clc
        disp([num2str(nRoadSegs) ' road segments processed']);  
        
%% Compile other fields                                                     
users.nUsersEq=ones(nBuildings,1);
users.area=zeros(nBuildings,1);
users.p=buildingTypesData{users.type,4};
users.q=users.p*tan(acos(pf));
users.s=sqrt(users.p.^2+users.q.^2);
users.v=LV*ones(nBuildings,1); % default to LV
users.nPhases=ones(nBuildings,1); % default to single phase
users.z=zeros(nBuildings,1);
users.levels=ones(nBuildings,1);
%users.type=18*ones(nBuildings,1); % assign everyone to medium residential

%% Assign PV generation

hasPV=binornd(1,prob_has_PV,[nBuildings,1])~=0;
users.PVkW=zeros(nBuildings,1);
PVPower=2*users.p.*rand(nBuildings,1);
users.PVkW(hasPV)=max(min_size_PV,round(PVPower(hasPV),1));
users.PVOrientation=randi(4,nBuildings,1); % maps to a power production profile
users.invkVA=users.PVkW; 
users.invType=zeros(nBuildings,1); % maps to control settings. 0 means no inverter 
users.invType(users.invkVA~=0)=1;

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
    users.id{i,1}=['RCLV' num2str(nLV)];
    users.e(i)=round(users.p(i)*lf(1)*8760);  % yearly energy in kWh
    users.cp(i)=round(users.p(i)*cf(1),2); % peak-coincident power in kW
    users.cq(i)=round(users.q(i)*cf(1),2); % peak-coincident power in kW
    elseif users.v(i)==MV
        nMV=nMV+1;
        users.id{i}=['CMVR' num2str(nMV)];
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
users.x=round(users.x,1);
users.y=round(users.y,1);
users.p=round(users.p,2);
users.q=round(users.q,2);

tUsers=table(users.x,users.y,users.z,...
    users.id,users.v,users.p,...
    users.q,users.nPhases);
writetable(tUsers,fullfile(outputFolder,'customers.txt'),'Delimiter',';','writeVariableNames',false);

tUsersExtended=table(users.x,users.y,users.z,users.id,users.v,users.p,...
    users.q,users.nPhases,users.area,users.levels,users.e,users.cp,...
    users.cq,users.nUsersEq, users.type,users.PVkW,users.invkVA,users.invType );
writetable(tUsersExtended,fullfile(outputFolder,'customers_extended.txt'),'Delimiter',';','writeVariableNames',false);

mapUsers.x=round(mapUsers.x,1);
mapUsers.y=round(mapUsers.y,1);
tMapUsers=table(mapUsers.x,mapUsers.y,...
    mapUsers.z,mapUsers.id);
writetable(tMapUsers,fullfile(outputFolder,'PointStreetMap.txt'),'Delimiter',';','writeVariableNames',false);

%% Write shapefile
% for i=1:nBuildings
% rBuildings(i).X=Lon(i);
% rBuildings(i).Y=Lat(i);
% rBuildings(i).Geometry='Point';
% end
% shapewrite(rBuildings,fullfile(shpFolder,'rural_buildings.shp'));





