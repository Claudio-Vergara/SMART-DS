clc
%clearvars
dbstop if error

%% Configure                                                                

addpath(genpath(fullfile('C:\SMART-DS')));

dataFolder='C:\Dropbox (MIT)\SMART_DS\data\cities\Greensboro_NC';
%dataFolder='D:\Claudio\Dropbox (MIT)\SMART_DS\data\cities\Greensboro_NC';
shapefilesFolder=fullfile(dataFolder,'shapefiles');

d=15; % distance between the auxiliary consumers for the street map
pf=0.9; % inductive power factor of all the loads
lf=[0.25 0.4]; % load factor [LV MV]
cf=[0.4 0.8]; % peak-coincidence factor [LV MV]
LV=0.416;
MV=12.47;
areaPerUser=180; %m^2

%% Load roads                                                               
roads_deg=shaperead(fullfile(shapefilesFolder,'roads.shp'));
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

%% Load buildings and building type data                                    
buildings_deg=shaperead(fullfile(shapefilesFolder,'buildings.shp'));
points_intersects=shaperead(fullfile(shapefilesFolder,'point_parcel_intersect.shp'));
nBuildings=length(buildings_deg);

for i=1:length(points_intersects)
    buildingType(points_intersects(i).FID_buildi) =...
        string(points_intersects(i).PARUSEDESC);  
end

buildingType=buildingType';
uniqueTypes=unique(buildingType);
bPoly=struct;
users.nSubBuildings=nan(nBuildings,1);


%% Create building type ID from parcels                                     
users.parcelType=nan(nBuildings,1);
for i=1:nBuildings
    thisBuildingTypeName=buildingType(i);
    switch thisBuildingTypeName
        case 'RESIDENTIAL'
            users.parcelType(i)=1;
        case 'MULTI-FAMILY5>'
            users.parcelType(i)=1;
        case 'MULTI-FAMILY<4'
            users.parcelType(i)=1;
        case 'Condominium'
            users.parcelType(i)=1;
        case 'Apartment'
            users.parcelType(i)=1;
        case 'Townhouse'
            users.parcelType(i)=1;
        case 'Commercial'
            users.parcelType(i)=2;
        case 'PETROLEUM OR GAS PRODUCTION, STORAGE OR TRANSPORT'
            users.parcelType(i)=2;
        case 'OFFICE'
            users.parcelType(i)=3;
        case 'Industrial'
            users.parcelType(i)=4;
        case 'airport'
            users.parcelType(i)=4;
        case 'Hotel/motel'
            users.parcelType(i)=5;
        case 'GOVERNMENT OWNED'
            users.parcelType(i)=6;
        case 'INSTITUTIONAL'
            users.parcelType(i)=6;
        case 'RETAIL'
            users.parcelType(i)=7;
        case 'school, college, university public or private'
            users.parcelType(i)=8;   
        case 'Homes for the Aged-ASSISTED LIVING & SKILLED CARE'
            users.parcelType(i)=9;
        otherwise
            users.parcelType(i)=0;
    end
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

%% Calculate building areas and nearest connection points
nMapUsers=length(mapUsers.x);
users.area=nan(nBuildings,1);
users.height=nan(nBuildings,1);
for i=1:nBuildings 
   bPoly(i).x=[];
   bPoly(i).y=[];       
    nanLocs=find(isnan(buildings_deg(i).X));
    users.area(i)=0;
    for j=1:length(nanLocs)
        if j==1
            polyLat=buildings_deg(i).Y(1:nanLocs(j)-1);
            polyLon=buildings_deg(i).X(1:nanLocs(j)-1);          
        else
            polyLat=buildings_deg(i).Y(nanLocs(j-1)+1:nanLocs(j)-1);
            polyLon=buildings_deg(i).X(nanLocs(j-1)+1:nanLocs(j)-1);            
        end
        [polyX,polyY,UTMZone]=deg2utm(polyLat,polyLon); 
        bPoly(i).x=[bPoly(i).x;polyX];
        bPoly(i).y=[bPoly(i).y;polyY];
        users.area(i)=users.area(i)+polyarea(polyX,polyY);
    end
    users.nSubBuildings(i)=j;  
    
    M1x=repmat( bPoly(i).x,1,nMapUsers);
    M1y=repmat( bPoly(i).y,1,nMapUsers);
    
    M2x=repmat(mapUsers.x',length( bPoly(i).x),1);
    M2y=repmat(mapUsers.y',length( bPoly(i).y),1);
    
    dx=M1x-M2x;
    dy=M1y-M2y;
    d=sqrt(dx.^2+dy.^2);
    [M,I] = min(d(:));
    [I_row, I_col] = ind2sub(size(d),I);
    users.x(i,1)=bPoly(i).x(I_row);
    users.y(i,1)=bPoly(i).y(I_row);
    
    if ~mod(i,100)
        clc
        disp([num2str(i) ' buildings processed']);
    end   
end
clc
disp([num2str(nBuildings) ' buildings processed']);

%% Save the workspace
save('Greensboro_part_1.mat','users','mapUsers','buildingTypesData','buildings_deg');
        








