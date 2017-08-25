function [Utili_Ratio, No_of_HV_Lines, No_of_MV_Lines, No_of_LV_Lines, Total_No_Transformers, summary_substations, No_of_Substations, Total_No_Feeders]=substation_feeder_count1(summary_lines_final,summary_nodes_final)
%  HV > 115kV, 69kV < MV < 2.4kV, LV < 600V
%% No of Substations
Idx=regexp(summary_lines_final.name,'transformer');

Idx1=find(~cellfun(@isempty,Idx));

Idx=regexp(summary_lines_final.type,'regulator');

Idx2=find(~cellfun(@isempty,Idx));

No_of_Regulators = length(Idx2);

summary_regulators = summary_lines_final(Idx2,:);

Idx3=setdiff(Idx1, Idx2);

summary_transformer=summary_lines_final(Idx3,:);

Idx=regexp(summary_nodes_final.component,'node');

Idx1=find(~cellfun(@isempty,Idx));

summary_nodes=summary_nodes_final(Idx1,:);

Idxl=regexp(summary_lines_final.name,'line');

Idxl1=find(~cellfun(@isempty,Idxl));

summary_lines1=summary_lines_final(Idxl1,:);

Idxol=find(summary_lines1.length > 1e-3);

summary_lines=summary_lines1(Idxol,:);


Idxaa=find(summary_transformer.nominalV > 2.4 & summary_transformer.phasecount == 3 ...
        & summary_transformer.cont_rating_amps_or_kVA > 499);
summary_transformer1=summary_transformer(Idxaa,:);
l_xfrm=length(summary_transformer1.name);
l_node=length(summary_nodes.name);

for i=1:l_xfrm
    for j= 1:l_node
        Idx10=strfind(summary_transformer1.from{i}, summary_nodes.name{j});
        if Idx10==1
            summary_transformer1.primaryV(i)=summary_nodes.nominalV(j)*1.732;
            summary_transformer1.priname(i)=summary_nodes.name(j);
            break
        end
    end
end

for i=1:l_xfrm
    for j= 1:l_node
        Idx10=strfind(summary_transformer1.to{i}, summary_nodes.name{j});
        if Idx10==1
            summary_transformer1.nodename(i)=summary_nodes.name(j);
            break
        end
    end
end

%Idxaa=find(summary_transformer1.nominalV < 38 & summary_transformer1.nominalV > 2.4 & summary_transformer1.phasecount == 3 ...
%        & summary_transformer1.cont_rating_amps_or_kVA > 499 & summary_transformer1.primaryV >= 30);
Idxaa=find(summary_transformer1.nominalV < 38 & summary_transformer1.nominalV > 2.4 & summary_transformer1.phasecount == 3 ...
        & summary_transformer1.cont_rating_amps_or_kVA > 499);
summary_propbable_substations=summary_transformer1(Idxaa,:);
No_of_Substations=length(summary_propbable_substations.name);

%% No of Feeders
% Xfrm_To = summary_propbable_substations.to;
% Feeder_Counts=table;
% SubStn_Name = [];
% Idx_Fe = [];
% From_Node = [];
% To_Node = [];
% Feeder_Summary = table;
% for ix = 1 : No_of_Substations
%     Idx1 = strcmp(summary_lines_final.from,Xfrm_To(ix));
%     Idx2 = find(Idx1 == 1);
%     SubStn_Node(ix) = summary_lines_final.to(Idx2);
%     Idx3=strcmp(summary_lines_final.from,SubStn_Node(ix));
%     Idx4 = find(Idx3 == 1);
%     Feeder_Counts.Substation(ix,1) = summary_propbable_substations.name(ix);
%     Feeder_Counts.Count(ix,1) = length(Idx4);
%     [Idx_Fe] = [Idx_Fe;Idx4];
%     C = cell(length(Idx4),1);
%     C(:) = SubStn_Node(ix);
%     [From_Node] = [From_Node;C];
%     Feeder_Node=summary_lines_final.to(Idx4);
%     To_Node = [To_Node;summary_lines_final.to(Idx4)];
%     C1 = cell(length(Idx4),1);
%     C1(:) = summary_propbable_substations.name(ix);
%     SubStn_Name = [SubStn_Name;C1];
% end
%   
% Feeder_Summary.SubStn_Name = SubStn_Name;
% Feeder_Summary.From_Node = From_Node;
% Feeder_Summary.To_Node = To_Node;
% Feeder.Feeder_Counts =  Feeder_Counts;
% Feeder.Feeder_Summary = Feeder_Summary;
% 
%  Total_No_Feeders=length(Feeder_Summary.To_Node);
  summary_substations=summary_propbable_substations;
%  Total_No_Transformers=length(summary_transformer.name);
 Total_No_Feeders=1;
% summary_substations=1;
 Total_No_Transformers=1;

%% No of HV/MV/LV Lines +/- 10% bandwidth assumed

Idx_line=find(summary_lines.nominalV > 110/1.732);
No_of_HV_Lines=length(Idx_line);
summary_lines_HV=summary_lines(Idx_line,:);
Utili_Ratio_HV.Name=summary_lines_HV.name;
Utili_Ratio_HV.Type=summary_lines_HV.type;
Utili_Ratio_HV.Rating_Amps=summary_lines_HV.cont_rating_amps_or_kVA;
IAR=summary_lines_HV.current_in_A_real;
IAI=summary_lines_HV.current_in_A_im;
IBR=summary_lines_HV.current_in_B_real;
IBI=summary_lines_HV.current_in_B_im;
ICR=summary_lines_HV.current_in_C_real;
ICI=summary_lines_HV.current_in_C_im;
IMag=(abs(IAR+sqrt(-1)*IAI)+abs(IBR+sqrt(-1)*IBI)+abs(ICR+sqrt(-1)*ICI))/3;
Utili_Ratio_HV.IMag_Amps=IMag;
Utili_Ratio_HV.Percent_Utilization=(IMag./summary_lines_HV.cont_rating_amps_or_kVA);

Idx_line=find(summary_lines.nominalV < 75.9/1.732 & summary_lines.nominalV > 2.16/1.732);
No_of_MV_Lines=length(Idx_line);
summary_lines_MV=summary_lines(Idx_line,:);
Utili_Ratio_MV.Name=summary_lines_MV.name;
Utili_Ratio_MV.Type=summary_lines_MV.type;
Utili_Ratio_MV.Rating_Amps=summary_lines_MV.cont_rating_amps_or_kVA;
IAR=summary_lines_MV.current_in_A_real;
IAI=summary_lines_MV.current_in_A_im;
IBR=summary_lines_MV.current_in_B_real;
IBI=summary_lines_MV.current_in_B_im;
ICR=summary_lines_MV.current_in_C_real;
ICI=summary_lines_MV.current_in_C_im;
IMag=(abs(IAR+sqrt(-1)*IAI)+abs(IBR+sqrt(-1)*IBI)+abs(ICR+sqrt(-1)*ICI))/3;
Utili_Ratio_MV.IMag_Amps=IMag;
Utili_Ratio_MV.Percent_Utilization=(IMag./summary_lines_MV.cont_rating_amps_or_kVA);

Idx_line=find(summary_lines.nominalV < 0.66);
No_of_LV_Lines=length(Idx_line);
summary_lines_LV=summary_lines(Idx_line,:);
Utili_Ratio_LV.Name=summary_lines_LV.name;
Utili_Ratio_LV.Type=summary_lines_LV.type;
Utili_Ratio_LV.Rating_Amps=summary_lines_LV.cont_rating_amps_or_kVA;
IAR=summary_lines_LV.current_in_A_real;
IAI=summary_lines_LV.current_in_A_im;
IBR=summary_lines_LV.current_in_B_real;
IBI=summary_lines_LV.current_in_B_im;
ICR=summary_lines_LV.current_in_C_real;
ICI=summary_lines_LV.current_in_C_im;
IMag=(abs(IAR+sqrt(-1)*IAI)+abs(IBR+sqrt(-1)*IBI)+abs(ICR+sqrt(-1)*ICI))/3;
Utili_Ratio_LV.IMag_Amps=IMag;
Utili_Ratio_LV.Percent_Utilization=(IMag./summary_lines_LV.cont_rating_amps_or_kVA);
Utili_Ratio.LV=Utili_Ratio_LV;
Utili_Ratio.MV=Utili_Ratio_MV;
Utili_Ratio.HV=Utili_Ratio_HV;

TF_Class.name=summary_transformer.name;
TF_Class.kV=summary_transformer.nominalV;
TF_Class.kva=summary_transformer.cont_rating_amps_or_kVA;
Utili_Ratio.TF_Class=TF_Class;


%% Loads
Idx=regexp(summary_nodes_final.component,'load');

Idx1=find(~cellfun(@isempty,Idx));

summary_loads=summary_nodes_final(Idx1,:);

Power_Factor.name=summary_loads.name;

Power_Factor.PhaseA = summary_loads.power_in_A_P./(sqrt(summary_loads.power_in_A_P+summary_loads.power_in_A_Q));

Power_Factor.PhaseB = summary_loads.power_in_B_P./(sqrt(summary_loads.power_in_B_P+summary_loads.power_in_B_Q));

Power_Factor.PhaseC = summary_loads.power_in_C_P./(sqrt(summary_loads.power_in_C_P+summary_loads.power_in_C_Q));

Utili_Ratio.Power_Factor = Power_Factor;

%% Ratios 3_phase and 1_phase to total
Idx_load=find(summary_loads.phasecount == 3);
summary_3ph_loads=summary_loads(Idx_load,:);
No_of_3Ph_Loads=length(Idx_load);

Idx_load=find(summary_loads.phasecount == 1);
summary_1ph_loads=summary_loads(Idx_load,:);
No_of_1Ph_Loads=length(Idx_load);

Idx_load=find(summary_loads.phasecount == 2);
summary_2ph_loads=summary_loads(Idx_load,:);
No_of_2Ph_Loads=length(Idx_load);


Total_Num_Loads=length(summary_loads.name);

Utili_Ratio.Ratio_3ph_total_load = No_of_3Ph_Loads/Total_Num_Loads;
Utili_Ratio.Ratio_1ph_total_load = No_of_1Ph_Loads/Total_Num_Loads;

Utili_Ratio.summary_3ph_loads=summary_3ph_loads;
Utili_Ratio.summary_2ph_loads=summary_2ph_loads;
Utili_Ratio.summary_1ph_loads=summary_1ph_loads;

Utili_Ratio.No_of_Regulators=No_of_Regulators;
Utili_Ratio.summary_regulators=summary_regulators;


%% Switches and sectionalizers
Idxol=find(summary_lines_final.length == 1e-3);

summary_switches=summary_lines_final(Idxol,:);

No_of_Switches = length(Idxol);

Utili_Ratio.No_of_Switches=No_of_Switches;
Utili_Ratio.summary_switches=summary_switches;


end        
   






