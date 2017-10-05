clc
clearvars
dbstop if error
tic;

addpath(genpath(fullfile('C:\SMART-DS')));

%dataFolder='C:\Dropbox (MIT)\SMART_DS\data\cities\Greensboro_NC';
dataFolder='D:\Claudio\Dropbox (MIT)\SMART_DS\data\cities\Greensboro_NC';

%%
building_centroids=shaperead(fullfile(dataFolder,'centroid_points.shp'));
points_intersects=shaperead(fullfile(dataFolder,'point_parcel_intersect.shp'));
%%
% for i=1:length(building_centroids)
%     %buildings(i).type=points_intersects(find([points_intersects.ORIG_FID]==i,1)).PARUSEDESC;
%     buildings(i).type=points_intersects(find([points_intersects.FID_buildi]==i,1)).PARUSEDESC;
%     
%     if ~mod(i,100)
%         clc
%         disp([num2str(i) ' buildings processed']);
%     end 
% end

for i=1:length(points_intersects)
    buildings(points_intersects(i).FID_buildi).type =...
        points_intersects(i).PARUSEDESC;    
    if ~mod(i,100)
        clc
        disp([num2str(i) ' buildings processed']);
    end 
end

for i=1:length(building_centroids)
    buildings(i).
end
