function [Feeder]=Feeder_Wise_Data(file,summary_lines_final,summary_nodes_final,a_matrix,bus_names,a_matrix_non,asym_matrix,nodes_array)
%Added by NREL
%  HV > 115kV, 69kV < MV < 2.4kV, LV < 600V
%% No of Substations
Idx=regexp(summary_lines_final.name,'transformer');

Idx1=find(~cellfun(@isempty,Idx));

Idx=regexp(summary_lines_final.type,'regulator');

Idx2=find(~cellfun(@isempty,Idx));

No_of_Regulators = length(Idx2);

summary_regulators = summary_lines_final(Idx2,:);

Idx3=setdiff(Idx1, Idx2);
%Idx3=Idx1;
summary_transformer=summary_lines_final(Idx3,:);

Idx=regexp(summary_nodes_final.component,'node');

Idx1=find(~cellfun(@isempty,Idx));

summary_nodes=summary_nodes_final(Idx1,:);

Idxl=regexp(summary_lines_final.name,'line');

Idxl1=find(~cellfun(@isempty,Idxl));

summary_lines1=summary_lines_final(Idxl1,:);

Idxol=find(summary_lines1.length > 1e-3);

summary_lines=summary_lines1(Idxol,:);



%%
%Idxaa=find(summary_transformer.nominalV > 2.4 & summary_transformer.phasecount == 3 ...
%        & summary_transformer.cont_rating_amps_or_kVA > 499);
Idxaa=find(summary_transformer.nominalV < 38 & summary_transformer.nominalV > 2.4 & summary_transformer.phasecount == 3 ...
        & summary_transformer.cont_rating_amps_or_kVA > 499);
if isempty(Idxaa)
    Idx=regexp(summary_lines_final.name,'transformer');

    Idx1=find(~cellfun(@isempty,Idx));

    summary_transformer=summary_lines_final(Idx1,:);
    
    Idxaa=find(summary_transformer.nominalV < 38 & summary_transformer.nominalV > 2.4 ...
        & summary_transformer.cont_rating_amps_or_kVA > 499);
    summary_transformer1=summary_transformer(Idxaa,:);
    summary_propbable_substations=summary_transformer1;
    
    No_of_Substations=length(unique(strtok(summary_propbable_substations.from,'.')));
    Feeder.summary_propbable_substations=summary_propbable_substations;
    Feeder.No_of_Substations=No_of_Substations;
    [Xfrm_To,ia,ib] = unique(strtok(summary_propbable_substations.to,'.'));
    Xfrm_To = Xfrm_To(ib);
    clear ib
else
summary_transformer1=summary_transformer(Idxaa,:);
l_xfrm=length(summary_transformer1.name);
l_node=length(summary_nodes.name);

% for i=1:l_xfrm
%     for j= 1:l_node
%         Idx10=strfind(summary_transformer1.from{i}, summary_nodes.name{j});
%         if Idx10==1
%             summary_transformer1.primaryV(i)=summary_nodes.nominalV(j)*1.732;
%             summary_transformer1.priname(i)=summary_nodes.name(j);
%             break
%         end
%     end
% end
% 
% for i=1:l_xfrm
%     for j= 1:l_node
%         Idx10=strfind(summary_transformer1.to{i}, summary_nodes.name{j});
%         if Idx10==1
%             summary_transformer1.nodename(i)=summary_nodes.name(j);
%             break
%         end
%     end
% end

%Idxaa=find(summary_transformer1.nominalV < 38 & summary_transformer1.nominalV > 2.4 & summary_transformer1.phasecount == 3 ...
%        & summary_transformer1.cont_rating_amps_or_kVA > 499 & summary_transformer1.primaryV >= 30);
 Idxaa=find(summary_transformer1.nominalV < 38 & summary_transformer1.nominalV > 2.4 & summary_transformer1.phasecount == 3 ...
         & summary_transformer1.cont_rating_amps_or_kVA > 499);
summary_propbable_substations=summary_transformer1(Idxaa,:);
No_of_Substations=length(summary_propbable_substations.name);
Feeder.summary_propbable_substations=summary_propbable_substations;
Feeder.No_of_Substations=No_of_Substations;
Xfrm_To = summary_propbable_substations.to;
end

%% No of Feeders

Feeder_Counts=table;
SubStn_Name = [];
SubStn_Name1 = [];
Idx_Fe = [];
From_Node = [];
From_Node1 = [];
To_Node = [];
Feeder_Summary = table;
Feed_Node1 = [];
if length(unique(Xfrm_To)) < length(Xfrm_To)
      Idx1 = strcmp(summary_lines_final.from,strtok(Xfrm_To(1),'.'));
    Idx2 = find(Idx1 == 1);
    if isempty(Idx2)
        len1=length(summary_lines_final.from);
        for jk=1:len1
        Idx1 = regexp(Xfrm_To(1),summary_lines_final.from(jk),'match');
        Idx2=find(~cellfun(@isempty,Idx1));
        if Idx2 > 0
            Idx2=jk;
            break
        end
        end
    end
    SubStn_Node = summary_lines_final.to(Idx2);
    for ix=1:length(Xfrm_To)
    Idx3=strcmp(strtok(summary_lines_final.from,'.'),SubStn_Node(ix));
    Idx4 = find(Idx3 == 1);
    Feeder_Counts.Substation(ix,1) = summary_propbable_substations.name(ix);
    Feeder_Counts.Count(ix,1) = length(Idx4);
    [Idx_Fe] = [Idx_Fe;Idx4];
    C = cell(length(Idx4),1);
    C(:) = SubStn_Node(ix);
    [From_Node] = [From_Node;C];
    Feeder_Node=summary_lines_final.to(Idx4);
    To_Node = [To_Node;summary_lines_final.to(Idx4)];
    C1 = cell(length(Idx4),1);
    C1(:) = summary_propbable_substations.name(ix);
    SubStn_Name = [SubStn_Name;C1];
    SubStn_Name1 = SubStn_Name;
    end
    %%
    else
for ix = 1 : No_of_Substations
    Idx1 = strcmp(summary_lines_final.from,strtok(Xfrm_To(ix),'.'));
    Idx2 = find(Idx1 == 1);
    ix
    if isempty(Idx2)
        len1=length(summary_lines_final.from);
        for jk=1:len1
        Idx1 = regexp(Xfrm_To(ix),summary_lines_final.from(jk),'match');
        Idx2=find(~cellfun(@isempty,Idx1));
        if Idx2 > 0
            Idx2=jk;
            break
        end
        end
    end
    
     if isempty(Idx2) %loveland
        len1=length(summary_lines_final.from);
        Idx1 = strcmp(strtok(summary_lines_final.from,'.'),strtok(Xfrm_To(ix),'.'));
        Idx2 = find(Idx1 == 1);
     end  %loveland end
    
    
    if length(Idx2)==1
    SubStn_Node(ix) = summary_lines_final.to(Idx2);
    Idx3=strcmp(strtok(summary_lines_final.from,'.'),SubStn_Node(ix));
    Idx4 = find(Idx3 == 1);
    %% multiple fuses to same feeder
    fuse_node1 = summary_lines_final.to(Idx4);
    clear feed_node
    iii = 1;
    clear fuse_node
    for ij=1:length(fuse_node1)
        idf=strcmp(strtok(summary_lines_final.from,'.'),strtok(fuse_node1(ij),'.'));
        idf1=find(idf==1);
        if isempty(idf1)
            1;
        else
            fuse_node(iii) = fuse_node1(ij);
            iii = iii+1;
        end
    end
    for ij=1:length(fuse_node)
        idf=strcmp(strtok(summary_lines_final.from,'.'),strtok(fuse_node(ij),'.'));
        idf1=find(idf==1);
        feed_node(ij)=summary_lines_final.from(idf1); %changed from 'to' to 'from'
    end
   
    %%
     C = cell(length(fuse_node),1);
     C(:) = SubStn_Node(ix);
     
      C0 = cell(length(unique(feed_node.')),1);
     C0(:) = SubStn_Node(ix);
   
    else
        SubStn_Node = Xfrm_To(ix);
        Idx4=Idx2;
         fuse_node = summary_lines_final.to(Idx4);
         clear feed_node
         for ij=1:length(fuse_node)
            idf=strcmp(strtok(summary_lines_final.from,'.'),strtok(fuse_node(ij),'.'));
            idf1=find(idf==1);
            feed_node(ij)=summary_lines_final.to(idf1);
         end
        C = cell(length(Idx4),1);
        C(:) = SubStn_Node;
          
      C0 = cell(length(unique(feed_node.')),1);
     C0(:) = SubStn_Node(ix);
    end
    [fff,ia,ib]=unique(feed_node.')
    Feed_Node1 = [Feed_Node1;fff(ib)];
    Feeder_Counts.Substation(ix,1) = summary_propbable_substations.name(ix);
    Feeder_Counts.Count(ix,1) = length(unique(feed_node));
    Feeder_Counts.totalconn(ix,1) = (length(fuse_node));
    [Idx_Fe] = [Idx_Fe;Idx4];
    
    [From_Node] = [From_Node;C];
    [From_Node1] = [From_Node1;C0];
    Feeder_Node=feed_node;
    To_Node = [To_Node;feed_node.'];
    
    C1 = cell(length(fuse_node),1);
    C1(:) = summary_propbable_substations.name(ix);
    SubStn_Name = [SubStn_Name;C1];
    
    C2 = cell(length(unique(feed_node.')),1);
    C2(:) = summary_propbable_substations.name(ix);
    SubStn_Name1 = [SubStn_Name1;C2]; %map to FEED_NODE1
end
end
summary_substations=summary_propbable_substations;
Total_No_Transformers=length(summary_transformer.name);
Total_No_Feeders=sum(Feeder_Counts.Count);
Total_No_Connections=sum(Feeder_Counts.totalconn);
Feeder_Summary.SubStn_Name = SubStn_Name;
Feeder_Summary.From_Node = From_Node;
Feeder_Summary.To_Node = To_Node;
Feeder.Feeder_Counts =  Feeder_Counts;
%Feeder.Feeder_Summary = Feeder_Summary;
Feeder.Total_No_Feeders = Total_No_Feeders;
Feeder.Total_No_Connections = Total_No_Connections;
To_Node1 = strtok(Feed_Node1,'.');
Feeder_Final_Summary = table;
Feeder_Final_Summary.SubStn_Name = SubStn_Name1;
Feeder_Final_Summary.From_Node = From_Node1;
Feeder_Final_Summary.To_Node = To_Node1;
% Feeder.Feeder_Final_Summary = Feeder_Final_Summary;

%% Feeder Seperation
%Feeder_Summary1 = Feeder_Summary(1:40,:)

if length(nodes_array) == length(bus_names)
   a_matrix1 = a_matrix;
  
else
    a_matrix1 = a_matrix(2:length(bus_names),2:length(bus_names));
end
%including loops between feeders
% for ilo = 1:Total_No_Feeders
%    frm_node=Feeder_Final_Summary.To_Node(ilo);
%    idxa = strcmp(strtok(summary_lines_final.from,'.'),frm_node);
%    idxb = find(idxa==1);
%    to_node = strtok(summary_lines_final.to(idxb),'.');
%    idxa1 = strcmp(strtok(summary_lines_final.from,'.'),to_node);
%    idxb1 = find(idxa1==1);
%    to_node1 = strtok(summary_lines_final.to(idxb1),'.');
%    %finding connection to adjacent loops
%    idxa2 = strcmp(strtok(summary_lines_final.to,'.'),to_node);
%    idxb2 = find(idxa2==1);
%    frm1_node = strtok(summary_lines_final.from(idxb2),'.');
%    nodes_other = setdiff(frm1_node,frm_node); %nodes coming from other feeders
%    
%    from_self =  frm_node;
%    from_other = nodes_other;
%    to_self = to_node;
%    to_other = to_node;
%    
%    Idx = strcmp(bus_names,from_self);
%    Idx1 = find(Idx==1);
%    Idx = strcmp(bus_names,to_self);
%    Idx2 = find(Idx==1);
%    Idx = strcmp(bus_names,from_other);
%    Idx3 = find(Idx==1);
%    Idx = strcmp(bus_names,to_other);
%    Idx4 = find(Idx==1);
%    
%    a_matrix1(Idx1,Idx2) = 0;
%    a_matrix1(Idx2,Idx2) = 0;
%    a_matrix1(Idx3,Idx4) = 0;
%    a_matrix1(Idx4,Idx3) = 0;
% end

M1 = importdata(file.switch_urban_suburban);
M2 = importdata(file.switch_rural);
M3 = importdata(file.switch_industrial);
M=[M1;M2;M3];
M=lower(M);
xx=length(M);
for kk=1:xx
MM = strsplit(M{kk,1});
if length(MM)>7 && strcmp(MM{1,7},'r1=1e11')
    kk
    aa = strsplit(MM{1,3},'=');
    frm_bus = aa{1,2};
    bb = strsplit(MM{1,4},'=');
    to_bus = bb{1,2};
    Idx1 = strcmp(bus_names,strtok(frm_bus,'.'));
    Idx2 = find(Idx1==1);
    Idx3 = strcmp(bus_names,strtok(to_bus,'.'));
    Idx4 = find(Idx3==1);
    a_matrix1(Idx2,Idx4) = 0;
    a_matrix1(Idx4,Idx2) = 0;
end
end


for iy=1:Total_No_Connections
Idx1 = strcmp(bus_names,Feeder_Final_Summary.From_Node(iy));
Idx2 = find(Idx1==1);
Idx3 = strcmp(bus_names,strtok(Feeder_Final_Summary.To_Node(iy),'.'));
Idx4 = find(Idx3==1);
a_matrix1(Idx2,Idx4) = 0;
a_matrix1(Idx4,Idx2) = 0;
end

% for iy=1:Total_No_Connections  %loveland add
% Idx1 = strcmp(bus_names,Feeder_Final_Summary.To_Node(iy));
% Idx2 = find(Idx1==1);
% Idx3 = strcmp(bus_names,strtok(Feeder_Summary.To_Node(iy),'.'));
% Idx4 = find(Idx3==1);
% a_matrix1(Idx2,Idx4) = 0;
% a_matrix1(Idx4,Idx2) = 0;
% end  %loveland end

%[S, C] = graphconncomp(a_matrix1);
[S,C] = tarjan(a_matrix1);
No_of_SubGraphs = max(C);

%%
lin_from = strtok(summary_lines_final.from,'.');
lin_to = strtok(summary_lines_final.to,'.');

Ix=strcmp(summary_nodes_final.type,'node');
Ix1=find(Ix == 1);
summary_nodes_final.bus(Ix1)=summary_nodes_final.name(Ix1);
nod_bus = strtok(summary_nodes_final.bus,'.');
%%
[Feed_Node2,ia,ib]=unique([To_Node1;bus_names(1)]); %add source bus name
Feed_Node2 = Feed_Node2(ib);
iz1=0;
iz2=0;
for iz = 1:No_of_SubGraphs
Id_bus{iz} = find(C == iz);
a_sub_matrix{iz} = a_matrix(Id_bus{iz},Id_bus{iz});
Bus_Sub_Names{iz} = bus_names(Id_bus{iz});
iz
     for iq = 1:length(Feed_Node2)
         ida = strcmp(Bus_Sub_Names{iz},Feed_Node2(iq));
         ida1 = find(ida==1);
         if isempty(ida1)
             continue
         else
             break
         end
     end

AA(iz) = iq;
    if iq == No_of_SubGraphs
        1;
    else
        iz1=iz1+1;
        filename = sprintf('%s_%d','FeederNo',iz1);
        adj_matrix.(filename)=a_matrix(Id_bus{iz},Id_bus{iz});
        adj_matrix_non.(filename)=a_matrix_non(Id_bus{iz},Id_bus{iz});
        asy_matrix.(filename)=asym_matrix(Id_bus{iz},Id_bus{iz});
        Bus_Sub_Names1.(filename) = bus_names(Id_bus{iz});
        Bus_Node_Array1 = nodes_array(Id_bus{iz});
    end

Idz_from=[];
Idz_to=[];
Idz_nod=[];

    for ig = 1:length(bus_names(Id_bus{iz}))
    %summary_lines_final
    Idz1=strcmp(lin_from,bus_names(Id_bus{iz}(ig)));
    Idz2=find(Idz1==1);
    Idz_from =[Idz_from;Idz2];
    Idz3=strcmp(lin_to,bus_names(Id_bus{iz}(ig)));
    Idz4=find(Idz3==1);
    Idz_to =[Idz_to;Idz4];
    Line_Idx_from{iz}=Idz_from;
    Line_Idx_to{iz}=Idz_to;
    %summary_nodes_final
    Idz5=strcmp(nod_bus,bus_names(Id_bus{iz}(ig)));
    Idz6=find(Idz5==1);
    Idz_nod =[Idz_nod;Idz6];   
    end
    [Idz_line,ia,ib] = unique([Idz_from;Idz_to]);
    Idz_line = Idz_line(ib);
    if iq == No_of_SubGraphs
        1;
    else
        iz2=iz2+1;
        filename = sprintf('%s_%d','FeederNo',iz2);
        summary_feeder_lines.(filename) = summary_lines_final(Idz_line,:);
        summary_feeder_nodes.(filename) = summary_nodes_final(Idz_nod,:);
    end
%     G=graph(a_sub_matrix{iz});
%     figure(iz)
%     plot(G)
end
iy=0;
for ih = 1:No_of_SubGraphs
    ih
    idy = AA(ih);
    if idy == No_of_SubGraphs
        SS_Idx = ih  %substation
    else
        iy=iy+1;
        Feeder_Summary1(iy,:)=Feeder_Final_Summary(AA(ih),:);
    end
end
Feeder.Feeder_Summary = Feeder_Summary1;

Feeder.summary_feeder_lines=summary_feeder_lines;
Feeder.summary_feeder_nodes=summary_feeder_nodes;
Feeder.adj_matrix = adj_matrix;
Feeder.adj_matrix_non = adj_matrix_non;
Feeder.asy_matrix = asy_matrix;
Feeder.Bus_Sub_Names = Bus_Sub_Names1;
Feeder.Bus_Node_Array1 = Bus_Node_Array1;
Feeder.Total_No_Feeders = No_of_SubGraphs-1;
idab = find(AA == No_of_SubGraphs);
iz3=0;
for ik = 1:No_of_SubGraphs
    if ik==idab
        1;
    else
    iz3=iz3+1;
    filename = sprintf('%s_%d','FeederNo',iz3);
    a_matrixn = adj_matrix.(filename);
    a_matrix_nonn = adj_matrix_non.(filename);
%    [feeder_metrics]=struct_metric(a_matrixn,a_matrix_nonn);
%    Feeder_Agg_Metrics.(filename) = feeder_metrics;
   Feeder_Agg_Metrics.(filename) = [];
    end
    clear feeder_metrics;
end
Feeder.Feeder_Agg_Metrics=Feeder_Agg_Metrics;
%% X/R Ratio
% [num,txt,raw] = xlsread(file.X_R);
% [ra ca]=size(txt);
% bus_n = [txt(2:ra,1)];
% X_R_Ratio = [num(1:ra-1,8)];
% X_R_Tab = table(bus_n,X_R_Ratio);
% [rb cb]=size(Bus_Sub_Names);
% iz4=0;
% for ij = 1:cb
%     Bus_Fed=Bus_Sub_Names(ij);
%     [rc cc]=size(Bus_Fed{1});
%     Idx3=[];
%     for ip=1:rc
%         Idx1=strcmp(lower(X_R_Tab.bus_n),Bus_Fed{1}(ip));
%         Idx2=find(Idx1==1);
%         Idx3=[Idx3;Idx2];
%     end
%     if idab == No_of_SubGraphs
%         1;
%     else
%         iz4=iz4+1;
%         filename = sprintf('%s_%d','FeederNo',iz4);
%         Feeder_X_R_Ratio.(filename) = X_R_Tab(Idx3,:);
%     end
% end
% Feeder.Feeder_X_R_Ratio=Feeder_X_R_Ratio;
% Feeder.X_R_Ratio = X_R_Tab;
%unique
for ii = 1:Feeder.Total_No_Feeders
filename = sprintf('%s_%d','FeederNo',ii);
Feeder1.summary_feeder_lines.(filename) = table;
aaa = Feeder.summary_feeder_lines.(filename);
[bbb ib ia]=unique(aaa.name);
Feeder1.summary_feeder_lines.(filename).component=Feeder.summary_feeder_lines.(filename).component(ib);
Feeder1.summary_feeder_lines.(filename).name=Feeder.summary_feeder_lines.(filename).name(ib);
Feeder1.summary_feeder_lines.(filename).type=Feeder.summary_feeder_lines.(filename).type(ib);
Feeder1.summary_feeder_lines.(filename).bus=Feeder.summary_feeder_lines.(filename).bus(ib);
Feeder1.summary_feeder_lines.(filename).to=Feeder.summary_feeder_lines.(filename).to(ib);
Feeder1.summary_feeder_lines.(filename).from=Feeder.summary_feeder_lines.(filename).from(ib);
Feeder1.summary_feeder_lines.(filename).linecode=Feeder.summary_feeder_lines.(filename).linecode(ib);
Feeder1.summary_feeder_lines.(filename).parent=Feeder.summary_feeder_lines.(filename).parent(ib);
Feeder1.summary_feeder_lines.(filename).phases=Feeder.summary_feeder_lines.(filename).phases(ib);
Feeder1.summary_feeder_lines.(filename).phasecount=Feeder.summary_feeder_lines.(filename).phasecount(ib);
Feeder1.summary_feeder_lines.(filename).length=Feeder.summary_feeder_lines.(filename).length(ib);
Feeder1.summary_feeder_lines.(filename).nominalV=Feeder.summary_feeder_lines.(filename).nominalV(ib);
Feeder1.summary_feeder_lines.(filename).nominalV_2nd_xfm=Feeder.summary_feeder_lines.(filename).nominalV_2nd_xfm(ib);
Feeder1.summary_feeder_lines.(filename).cont_rating_amps_or_kVA=Feeder.summary_feeder_lines.(filename).cont_rating_amps_or_kVA(ib);
Feeder1.summary_feeder_lines.(filename).resistence_R=Feeder.summary_feeder_lines.(filename).resistence_R(ib);
Feeder1.summary_feeder_lines.(filename).reactance_X=Feeder.summary_feeder_lines.(filename).reactance_X(ib);
Feeder1.summary_feeder_lines.(filename).susceptance_B=Feeder.summary_feeder_lines.(filename).susceptance_B(ib);
Feeder1.summary_feeder_lines.(filename).power_in_A_P=Feeder.summary_feeder_lines.(filename).power_in_A_P(ib);
Feeder1.summary_feeder_lines.(filename).power_in_A_Q=Feeder.summary_feeder_lines.(filename).power_in_A_Q(ib);
Feeder1.summary_feeder_lines.(filename).power_in_B_P=Feeder.summary_feeder_lines.(filename).power_in_B_P(ib);
Feeder1.summary_feeder_lines.(filename).power_in_B_Q=Feeder.summary_feeder_lines.(filename).power_in_B_Q(ib);
Feeder1.summary_feeder_lines.(filename).power_in_C_P=Feeder.summary_feeder_lines.(filename).power_in_C_P(ib);
Feeder1.summary_feeder_lines.(filename).power_in_C_Q=Feeder.summary_feeder_lines.(filename).power_in_C_Q(ib);
Feeder1.summary_feeder_lines.(filename).current_in_A_real=Feeder.summary_feeder_lines.(filename).current_in_A_real(ib);
Feeder1.summary_feeder_lines.(filename).current_in_A_im=Feeder.summary_feeder_lines.(filename).current_in_A_im(ib);
Feeder1.summary_feeder_lines.(filename).current_in_B_real=Feeder.summary_feeder_lines.(filename).current_in_B_real(ib);
Feeder1.summary_feeder_lines.(filename).current_in_B_im=Feeder.summary_feeder_lines.(filename).current_in_B_im(ib);
Feeder1.summary_feeder_lines.(filename).current_in_C_real=Feeder.summary_feeder_lines.(filename).current_in_C_real(ib);
Feeder1.summary_feeder_lines.(filename).current_in_C_im=Feeder.summary_feeder_lines.(filename).current_in_C_im(ib);
Feeder1.summary_feeder_lines.(filename).voltage_in_A_mag=Feeder.summary_feeder_lines.(filename).voltage_in_A_mag(ib);
Feeder1.summary_feeder_lines.(filename).voltage_in_A_deg=Feeder.summary_feeder_lines.(filename).voltage_in_A_deg(ib);
Feeder1.summary_feeder_lines.(filename).voltage_in_B_mag=Feeder.summary_feeder_lines.(filename).voltage_in_B_mag(ib);
Feeder1.summary_feeder_lines.(filename).voltage_in_B_deg=Feeder.summary_feeder_lines.(filename).voltage_in_B_deg(ib);
Feeder1.summary_feeder_lines.(filename).voltage_in_C_mag=Feeder.summary_feeder_lines.(filename).voltage_in_C_mag(ib);
Feeder1.summary_feeder_lines.(filename).voltage_in_C_deg=Feeder.summary_feeder_lines.(filename).voltage_in_C_deg(ib);
Feeder1.summary_feeder_lines.(filename).x=Feeder.summary_feeder_lines.(filename).x(ib);
Feeder1.summary_feeder_lines.(filename).y=Feeder.summary_feeder_lines.(filename).y(ib);
Feeder1.summary_feeder_lines.(filename).measured_real_power=Feeder.summary_feeder_lines.(filename).measured_real_power(ib);
Feeder1.summary_feeder_lines.(filename).measured_reactive_power=Feeder.summary_feeder_lines.(filename).measured_reactive_power(ib);
Feeder1.summary_feeder_lines.(filename).losses_re=Feeder.summary_feeder_lines.(filename).losses_re(ib);
Feeder1.summary_feeder_lines.(filename).losses_im=Feeder.summary_feeder_lines.(filename).losses_im(ib);
Feeder1.summary_feeder_lines.(filename).S_phase_A=Feeder.summary_feeder_lines.(filename).S_phase_A(ib);
Feeder1.summary_feeder_lines.(filename).S_phase_B=Feeder.summary_feeder_lines.(filename).S_phase_B(ib);
Feeder1.summary_feeder_lines.(filename).S_phase_C=Feeder.summary_feeder_lines.(filename).S_phase_C(ib);
Feeder1.summary_feeder_lines.(filename).S_total=Feeder.summary_feeder_lines.(filename).S_total(ib);
Feeder1.summary_feeder_lines.(filename).URatio=Feeder.summary_feeder_lines.(filename).URatio(ib);
Feeder1.summary_feeder_lines.(filename).Vmag_phase_A=Feeder.summary_feeder_lines.(filename).Vmag_phase_A(ib);
Feeder1.summary_feeder_lines.(filename).Vmag_phase_B=Feeder.summary_feeder_lines.(filename).Vmag_phase_B(ib);
Feeder1.summary_feeder_lines.(filename).Vmag_phase_C=Feeder.summary_feeder_lines.(filename).Vmag_phase_C(ib);
Feeder1.summary_feeder_lines.(filename).imbalance=Feeder.summary_feeder_lines.(filename).imbalance(ib);
Feeder1.summary_feeder_lines.(filename).length_numPhase1=Feeder.summary_feeder_lines.(filename).length_numPhase1(ib);
Feeder1.summary_feeder_lines.(filename).length_numPhase2=Feeder.summary_feeder_lines.(filename).length_numPhase2(ib);
Feeder1.summary_feeder_lines.(filename).length_numPhase3=Feeder.summary_feeder_lines.(filename).length_numPhase3(ib);
Feeder1.summary_feeder_lines.(filename).magI_Phase1=Feeder.summary_feeder_lines.(filename).magI_Phase1(ib);
Feeder1.summary_feeder_lines.(filename).magI_Phase2=Feeder.summary_feeder_lines.(filename).magI_Phase2(ib);
Feeder1.summary_feeder_lines.(filename).magI_Phase3=Feeder.summary_feeder_lines.(filename).magI_Phase3(ib);
Feeder1.summary_feeder_lines.(filename).maxDev_I=Feeder.summary_feeder_lines.(filename).maxDev_I(ib);
Feeder1.summary_feeder_lines.(filename).maxDev_S=Feeder.summary_feeder_lines.(filename).maxDev_S(ib);
Feeder1.summary_feeder_lines.(filename).maxDev_V=Feeder.summary_feeder_lines.(filename).maxDev_V(ib);
Feeder1.summary_feeder_lines.(filename).meanI=Feeder.summary_feeder_lines.(filename).meanI(ib);
Feeder1.summary_feeder_lines.(filename).meanS=Feeder.summary_feeder_lines.(filename).meanS(ib);
Feeder1.summary_feeder_lines.(filename).meanV=Feeder.summary_feeder_lines.(filename).meanV(ib);
Feeder1.summary_feeder_lines.(filename).arbitrary_x=Feeder.summary_feeder_lines.(filename).arbitrary_x(ib);
Feeder1.summary_feeder_lines.(filename).arbitrary_y=Feeder.summary_feeder_lines.(filename).arbitrary_y(ib);
end
Feeder.summary_feeder_lines = Feeder1.summary_feeder_lines;
end        
   






