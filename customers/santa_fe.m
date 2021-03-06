clc
clearvars
dbstop if error
tic;
addpath(genpath(fullfile('C:\SMART-DS')));
dataFolder='C:\Dropbox (MIT)\SMART_DS\data\cities\Santa_Fe_NM';
d=10; % distance between the auxiliary consumers for the street map
pf=0.9; % inductive power factor of all the loads
lf=[0.25 0.4]; % load factor [LV MV]
cf=[0.4 0.8]; % peak-coincidence factor [LV MV]
LV=0.416;
MV=12.47;
areaPerUser=180; %m^2
peakPerArea=0.04; % kW/m^2;

%% Load roads data and convert to meters
roads_deg=shaperead(fullfile(dataFolder,'Roads.shp'));
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
end

nMapUsers=length(mapUsers.x);

%% Load buildings data, convert to meters and calculate the shape centroids
% I'm using the centroid of the bounding box for now.
buildings_deg=shaperead(fullfile(dataFolder,'Buildings.shp'));
nBuildings=length(buildings_deg);
centerLat=nan(nBuildings,1);
centerLon=nan(nBuildings,1);
buildingArea=nan(nBuildings,1);
nSubBuildings=nan(nBuildings,1);
for i=1:nBuildings
    
    %% Center of the bounding box in degrees
    centerLon(i)=mean(buildings_deg(i).BoundingBox(:,1));
    centerLat(i)=mean(buildings_deg(i).BoundingBox(:,2));
    bVertex.x=[];
    bVertex.y=[];
        
    %% Area of each building and best connection vertex
    nanLocs=find(isnan(buildings_deg(i).X));
    buildingArea(i)=0;
    for j=1:length(nanLocs)
        if j==1
            polyLat=buildings_deg(i).Y(1:nanLocs(j)-1);
            polyLon=buildings_deg(i).X(1:nanLocs(j)-1); 
           
        else
            polyLat=buildings_deg(i).Y(nanLocs(j-1)+1:nanLocs(j)-1);
            polyLon=buildings_deg(i).X(nanLocs(j-1)+1:nanLocs(j)-1);
            
        end
        [polyX,polyY,~]=deg2utm(polyLat,polyLon); 
        bVertex.x=[bVertex.x;polyX];
        bVertex.y=[bVertex.y;polyY];
        buildingArea(i)=buildingArea(i)+polyarea(polyX,polyY);
    end
    nSubBuildings(i)=j;  
    M1x=repmat(bVertex.x,1,nMapUsers);
    M1y=repmat(bVertex.y,1,nMapUsers);
    
    M2x=repmat(mapUsers.x',length(bVertex.x),1);
    M2y=repmat(mapUsers.y',length(bVertex.x),1);
    
    dx=M1x-M2x;
    dy=M1y-M2y;
    d=sqrt(dx.^2+dy.^2);
    [M,I] = min(d(:));
    [I_row, I_col] = ind2sub(size(d),I);
    users.x(i,1)=bVertex.x(I_row);
    users.y(i,1)=bVertex.y(I_row);
    
    if mod(i,10)
        clc
        disp([num2str(i) ' buildings processed']);
    end
   
    
end

[users.Centroid.x,users.Centroid.y,~]=deg2utm(centerLat,centerLon);

%% Compile other fields

users.area=round(buildingArea);
users.height=[buildings_deg.Height1]'*0.3; % convert feet to meters
users.levels=ceil(users.height/3.5); % assuming 3.5 m per level
users.totalArea=users.area.*users.levels;
users.nUsersEq=max(1,round(users.totalArea/areaPerUser,0));
users.selfCF=0.5*(1+5./(2*users.nUsersEq+3)); %Electric Power distribution Handbook, Tom Short, Second Edition (2014) 
users.p=round(peakPerArea*users.totalArea.*users.selfCF,2); % peak power in kW
users.q=users.p*tan(acos(pf));
users.s=sqrt(users.p.^2+users.q.^2);
users.v=LV*ones(nBuildings,1); % default to LV
users.nPhases=ones(nBuildings,1); % default to single phase
users.nPhases(users.v==LV & users.s>30/cf(1))=3; % Move LV users of more than 30 kVA of coincident power to 3 phase
users.v(users.s>300/cf(2))=MV; % if the load is greater than 300 kVA of coincident power, move to MV
users.nPhases(users.s>300)=3; % Move all users of more than 300 kVA peak to 3 phase MV
users.z=zeros(nBuildings,1);
users.nUsersEq(users.v==MV)=1;
%% write user codes
nLV=0;
nMV=0;
users.id={};
users.e=zeros(nBuildings,1);
users.cp=zeros(nBuildings,1);
users.cq=zeros(nBuildings,1);
for i=1:nBuildings
    if users.v(i)==LV
        nLV=nLV+1;
    users.id{i,1}=['CLV' num2str(nLV)];
    users.e(i)=round(users.p(i)*lf(1)*8760);  % yearly energy in kWh
    users.cp(i)=round(users.p(i)*cf(1),2); % peak-coincident power in kW
    users.cq(i)=round(users.q(i)*cf(1),2); % peak-coincident power in kW
    elseif users.v(i)==MV
        nMV=nMV+1;
        users.id{i}=['CMV' num2str(nMV)];
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

%% write files and save the workspace
users.x=round(users.x,1);
users.y=round(users.y,1);
tUsers=table(users.x,users.y,users.z,users.id,users.v,users.p,users.q,users.nPhases);
writetable(tUsers,fullfile(dataFolder,'customers.txt'),'Delimiter',';','writeVariableNames',false);

tUsersExtended=table(users.x,users.y,users.z,users.id,users.v,users.p,...
    users.q,users.nPhases,users.area,users.levels,users.e,users.cp,users.cq,users.nUsersEq);
writetable(tUsersExtended,fullfile(dataFolder,'customers_extended.txt'),'Delimiter',';','writeVariableNames',false);

mapUsers.x=round(mapUsers.x,1);
mapUsers.y=round(mapUsers.y,1);
tMapUsers=table(mapUsers.x,mapUsers.y,mapUsers.z,mapUsers.id);
writetable(tMapUsers,fullfile(dataFolder,'PointStreetMap.txt'),'Delimiter',';','writeVariableNames',false);

save(fullfile(dataFolder,'WorkspaceLocalInfo.mat'));


toc;
%% Summary info
clc
disp(['LV customers: ' num2str(sum(users.v==LV))]);
disp(['MV customers: ' num2str(sum(users.v==MV))]);
disp(['Single-phase customers: ' num2str(sum(users.nPhases==1))]);
disp(['Three-phase LV customers: ' num2str(sum(users.v==LV & users.nPhases==3))]);
disp(['Single-phase MV customers: ' num2str(sum(users.v==MV & users.nPhases==1))]);
disp(['Three-phase customers: ' num2str(sum(users.nPhases==3))]);
disp(['Sum of customer peaks: ' num2str(round(sum(users.s),0))]);

LV_peak=round(sum(users.p(users.v==LV))*cf(1),0);
MV_peak=round(sum(users.p(users.v==MV))*cf(2),0);

disp(['Approximate peak-coincident power: ' num2str(LV_peak+MV_peak)]);
%% histogram
figure(1)
hist(users.p,10000);
xlabel('Peak load (kW)')
ylabel('Number of buildings')

%% create heatmap

mapHeight=400; %cells
mapWidth=800;
hMin=min(users.y)-1;
hMax=max(users.y)-1;
wMin=min(users.x)-1;
wMax=max(users.x)-1;

hStep=(hMax-hMin)/mapHeight;
wStep=(wMax-wMin)/mapWidth;

cellArea=hStep*wStep;

M=zeros(mapHeight,mapWidth);

for i=1:mapHeight
    for j=1:mapWidth
        if j==1, xMin=wMin; else, xMin=(j-1)*wStep+wMin; end
        xMax=j*wStep+wMin;
        if i==1, yMin=hMin; else, yMin=(i-1)*hStep+hMin; end
        yMax=i*hStep+hMin;        
        M(i,j)=sum(users.p(users.x<xMax & users.x>xMin & users.y<yMax & users.y>yMin));
    end
end

M=1/cellArea*M;

%%
H = fspecial('gaussian',[20,20],10);

fM=imfilter(M,H);

figure(2)
imagesc(1000*flipud(fM)); % w/m^2
%surf(fM,'EdgeColor','none')
CB=colorbar;
title(CB,'Power density in W/m^2');
axis equal

%%
figure(3)
scatter(users.x(users.v==LV),users.y(users.v==LV),2,'red','filled')
hold on
scatter(users.x(users.v==MV),users.y(users.v==MV),10,'blue','filled')
hold off
xlabel('UTM Easting (m)')
ylabel('UTM Northing (m)')
legend('LV','MV','Location','SE');
axis equal

%% Show roads and buildings
% close all
% figure(1)
% mapshow(roads_deg)
% mapshow(buildings_deg)
% %%
% figure(2)
%  line(roadSegs.x',roadSegs.y','Color','black')
%  hold on
%  scatter(users.x,users.y,5,'red','filled')
%  scatter(mapUsers.x,mapUsers.y,6,'blue','filled');
%  hold off








