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