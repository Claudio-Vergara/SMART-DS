addpath('C:\Users\athakall\Desktop\FEEDER_CODES\SMART-DS-master\Network_Characterization\ODSS\functions');
addpath('C:\Users\athakall\Desktop\FEEDER_CODES\SMART-DS-master\Network_Characterization\ODSS\functions\matlab-networks-toolbox-master');
set_up1_MLX;
load(fullfile(saveWorkspace, 'network.mat'));
load(fullfile(saveWorkspace, 'circuit.mat'));
load(fullfile(saveWorkspace, 'coord.mat'));
load(fullfile(saveWorkspace, 'tuples.mat'));
load(fullfile(saveWorkspace, 'summary_lines_final'));
load(fullfile(saveWorkspace, 'summary_nodes_final'));
load(fullfile(saveWorkspace, 'a_matrix'));
load(fullfile(saveWorkspace, 'a_matrix_non'));
load(fullfile(saveWorkspace, 'bus_names'));
load(fullfile(saveWorkspace, 'x_load'));
load(fullfile(saveWorkspace, 'asym_matrix'));
load(fullfile(saveWorkspace, 'nodes_array'));
load(fullfile(saveWorkspace, 'Feeder'));
%load(fullfile(saveWorkspace, 'Voltage'));
MainFolder='C:\Users\athakall\Desktop\FEEDER_CODES\Validation_CSV_Files';
CaseFolder=file.caseName;
CaseFolder_Cr = fullfile(MainFolder,file.caseName);
mkdir(CaseFolder_Cr);
global FinalPath;
Objective={'1_Real_Phys_Layout','2_Real_System_Size','3_Real_Equip_Parameters',...
          '4_Load_Specification','5_Repres_Voltage_Control_Schemes','6_Repres_Voltage_Profiles',...
          '7_Repres_SystemLosses_LoadInterupptions','8_Real_Reconfig_Options',...
          '9_Computational_Requirements','10_TimeSeries'};

Attributes={'1_Physical_Attributes','2_Structural_Attributes',...
            '3_Operational_Attributes'};
Obj=char(Objective);
Attr=char(Attributes);
Len_Obj=length(Objective);
Len_Attr=length(Attributes);

for i=1:Len_Obj
    ValiPath=char(fullfile(CaseFolder_Cr,Objective(i)));
    mkdir(ValiPath);
    for j=1:Len_Attr
       AttrPath=char(fullfile(ValiPath,Attributes(j)));
       FinalPath{i,j} = textscan(AttrPath , '%s');
       mkdir(AttrPath);
    end
end

end_row = 0;
start_corner = 'A1';
write_header = 1;

%% 1_Realistic Physical Layout 1_Physical Attributes
Idx=strcmp(coord.node_type,'node');
Idx1=find(Idx==1);
summary11=coord(Idx,:);
writetable(summary11, fullfile(char(FinalPath{1,1}{1}), 'node_coordinates.csv'));

Idx=strcmp(coord.node_type,'load');
Idx1=find(Idx==1);
summary11=coord(Idx,:);
writetable(summary11, fullfile(char(FinalPath{1,1}{1}), 'load_coordinates.csv'));


Idx=strcmp(tuples.edge_type,'line');
Idx1=find(Idx==1);
summary11=tuples(Idx1,:);
writetable(summary11, fullfile(char(FinalPath{1,1}{1}), 'line_coordinates.csv'));

Idx=strcmp(tuples.edge_type,'transformer');
Idx1=find(Idx==1);
summary11=tuples(Idx1,:);
writetable(summary11, fullfile(char(FinalPath{1,1}{1}), 'transformer_coordinates.csv'));

Idx=strcmp(tuples.edge_type,'regulator');
Idx1=find(Idx==1);
summary11=tuples(Idx1,:);
writetable(summary11, fullfile(char(FinalPath{1,1}{1}), 'regulator_coordinates.csv'));

Idx=strcmp(tuples.edge_type,'substation');
Idx1=find(Idx==1);
summary11=tuples(Idx1,:);
writetable(summary11, fullfile(char(FinalPath{1,1}{1}), 'substation_coordinates.csv'));



[Utili_Ratio, No_of_HV_Lines, No_of_MV_Lines, No_of_LV_Lines, Total_No_Transformers, summary_substations, No_of_Substations, Total_No_Feeders] ...
    =substation_feeder_count1(summary_lines_final,summary_nodes_final)

summary_substations.bus=[];
summary_substations.linecode=[];
summary_substations.parent=[];
summary_substations.phases=[];
summary_substations.length=[];
summary_substations.resistence_R=[];
summary_substations.reactance_X=[];
summary_substations.susceptance_B=[];
summary_substations.x=[];
summary_substations.y=[];
summary_substations.measured_real_power=[];
summary_substations.measured_reactive_power=[];
summary_substations.Vmag_phase_A=[];
summary_substations.Vmag_phase_B=[];
summary_substations.Vmag_phase_C=[];
summary_substations.length_numPhase1=[];
%summary_substations.length_numPhase2=[];
summary_substations.length_numPhase3=[];
summary_substations.maxDev_V=[];
summary_substations.arbitrary_x=[];
summary_substations.arbitrary_y=[];
%summary_substations.primaryV=[];
%summary_substations.priname=[];
summary_substations.type=[];
SS    = cell(No_of_Substations,1);
SS(:) = {'substation'};
summary_substations.type=SS;
summary_substations = [summary_substations(:,end) summary_substations(:,1:end-1)];

sumsub1=table;
sumsub1.type=summary_substations.type;
sumsub1.name=summary_substations.name;
sumsub1.to=summary_substations.to;
sumsub1.from=summary_substations.from;
sumsub1.phasecount=summary_substations.phasecount;
sumsub1.nominal_2nd_voltage_kV=summary_substations.nominalV;
sumsub1.rating_kVA=summary_substations.cont_rating_amps_or_kVA;
sumsub1.active_power_Aph_kW=summary_substations.power_in_A_P;
sumsub1.reactive_power_Aph_kVar=summary_substations.power_in_A_Q;
sumsub1.active_power_Bph_kW=summary_substations.power_in_B_P;
sumsub1.reactive_power_Bph_kVar=summary_substations.power_in_B_Q;
sumsub1.active_power_Cph_kW=summary_substations.power_in_C_P;
sumsub1.reactive_power_Cph_kVar=summary_substations.power_in_C_Q;
sumsub1.current_Aph_real_Amps=summary_substations.current_in_A_real;
sumsub1.current_Aph_imag_Amps=summary_substations.current_in_A_im;
sumsub1.current_Bph_real_Amps=summary_substations.current_in_B_real;
sumsub1.current_Bph_imag_Amps=summary_substations.current_in_B_im;
sumsub1.current_Cph_real_Amps=summary_substations.current_in_C_real;
sumsub1.current_Cph_imag_Amps=summary_substations.current_in_C_im;
sumsub1.voltage_pri_Aph_mag_volts=summary_substations.voltage_in_A_mag;
sumsub1.voltage_pri_Aph_degree=summary_substations.voltage_in_A_deg;
sumsub1.voltage_pri_Bph_mag_volts=summary_substations.voltage_in_B_mag;
sumsub1.voltage_pri_Bph_degree=summary_substations.voltage_in_B_deg;
sumsub1.voltage_pri_Cph_mag_volts=summary_substations.voltage_in_C_mag;
sumsub1.voltage_pri_Cph_degree=summary_substations.voltage_in_C_deg;
sumsub1.URatio=summary_substations.URatio;

writetable(sumsub1, fullfile(char(FinalPath{1,1}{1}), 'summary_substations.csv'));



Count.Substations=No_of_Substations;
Count.Feeders=Feeder.Total_No_Feeders;
Count1=struct2table(Count);
writetable(Count1, fullfile(char(FinalPath{1,1}{1}), 'Total_substations_feeder_count.csv'));

sum1=table;
sum1.Substation = Feeder.Feeder_Counts.Substation;
sum1.No_of_Feeders = Feeder.Feeder_Counts.Count;
writetable(sum1, fullfile(char(FinalPath{1,1}{1}), 'substation_wise_feeder_count.csv'));

%% Feeder Wise
mkdir(char(fullfile(FinalPath{1,2}{1},'Feeder_Wise')));
for nk=1:Feeder.Total_No_Feeders
    filename = sprintf('%s_%d','FeederNo',nk);
    summary.diameter = Feeder.Feeder_Agg_Metrics.(filename).diameter;
    summary.char_path_length = Feeder.Feeder_Agg_Metrics.(filename).char_path_len;
    summary.deg_assort = Feeder.Feeder_Agg_Metrics.(filename).deg_assort;
    summary.ave_deg = Feeder.Feeder_Agg_Metrics.(filename).ave_deg;
    filename1 = sprintf('%s_%d','Agg_metrics_FeederNo',nk,'.csvz');
    filename2=strtok(filename1,'z');
    cd(char(fullfile(FinalPath{1,2}{1},'Feeder_Wise')));
    struct2csv(summary,filename2);
end
%% 1_Realistic Physical Layout 2_Structural Attributes

summary12.clust_coeff = mean(network.topology.clust_coeff);
summary12.top_deg_assort = network.topology.deg_assort;
summary12.node_betweenness = network.topology.betweenness;
%table_summary12 = struct2table(summary12);
% writetable(table_summary12, fullfile(char(FinalPath{1,2}{1}), 'Structural_Attributes_12.xls'),...
%         'WriteVariableNames', write_header, 'Range', start_corner);
cd(char(FinalPath{1,2}{1}));
struct2csv(summary12,'aggregate_metrics.csv');


%% 2_Realistic System Size 1_Physical Attributes
All_Counts.Total_Num_Customers=circuit.Total_Num_Customers;
All_Counts.Total_Num_Substations=No_of_Substations;
All_Counts.Feeders_Per_Substation=Total_No_Feeders/No_of_Substations;
All_Counts.Total_Transformers=Total_No_Transformers; %includes substation transformers and excludes regulators
All_Counts.No_of_HV_Lines=No_of_HV_Lines;
All_Counts.No_of_MV_Lines=No_of_MV_Lines;
All_Counts.No_of_LV_Lines=No_of_LV_Lines;
Count2=struct2table(All_Counts);
writetable(Count2, fullfile(char(FinalPath{2,1}{1}), 'System_Size_Counts.csv'));


%% 3_Realistic_Electrical_Design 1_Physical Attributes
summary31.HV_Line_Length_km=0;
summary31.MV_Line_Length_km=network.MV.length.MV;
summary31.LV_Line_Length_km=network.MV.length.LV;
summary31.LV_to_Total_length_ratio=network.MV.length.LV/(network.MV.length.LV+network.MV.length.MV);
summary31.MV_to_Total_length_ratio=network.MV.length.MV/(network.MV.length.LV+network.MV.length.MV);
summary31.ug_oh_ratio=circuit.ug_oh_ratio;
cd(char(FinalPath{3,1}{1}));
struct2csv(summary31,'Physical_Parameters_Ratios.csv');

Line_Electrical_Params=circuit.LineParams.Line;
LL=struct2table(Line_Electrical_Params);
len_line = length(LL.Bus1);
for ii=1:len_line
    Bus1=LL.Bus1(ii);
    idx=strcmp(summary_lines_final.from,Bus1);
    idx1=find(idx==1);
    nominalV(ii) = summary_lines_final.nominalV(idx1(1));
end
LL.nominalV_kV=nominalV.';
%struct2csv(Line_Electrical_Params,'Line_Parameters.csv');

idx1=1:length(LL.Length_km);
idx=find(LL.Length_km == 1e-3 & LL.R1_ohmperkm == 1 & round(LL.C1_nFperkm,3) == 3.6090 );
LL2=LL(idx,:);
writetable(LL2, fullfile(char(FinalPath{3,1}{1}), 'Switch_Parameters.csv'));
idx2=setdiff(idx1,idx);
LL1=LL(idx2,:);
writetable(LL1, fullfile(char(FinalPath{3,1}{1}), 'Line_Parameters.csv'));

Xfrm_Electrical_Params=circuit.XfrmParams.Line;

XL=struct2table(Xfrm_Electrical_Params);
XL.percent_short_ckt_reactance_highvolt_teritiary = XL.Xht;
XL.percent_short_ckt_reactance_high_low = XL.Xhl;
XL.percent_short_ckt_reactance_lowvolt_teritiary = XL.Xlt;
XL.Xht=[];
XL.Xlt=[];
XL.Xhl=[];
writetable(XL, fullfile(char(FinalPath{3,1}{1}), 'Transformer_Parameters.csv'));

struct2csv(Utili_Ratio.TF_Class,'Transformer_Size.csv');

xxload=struct2table(x_load);
Load_Per_Transformer.Name = xxload.name;
Load_Per_Transformer.kVA = xxload.xfm_capacity;
Load_Per_Transformer.kW = xxload.total_P;
struct2csv(Load_Per_Transformer, 'kW_kVA_Transformer.csv');

% Transformer_Size_Per_Consumer.Name = xxload.name;
% Transformer_Size_Per_Consumer.Size_Per_Load = xxload.xfm_capacity./xxload.nLoads;
% struct2csv(Transformer_Size_Per_Consumer, 'Transformer_Size_Per_Load.csv');

Customer_Per_Transformer.Name = xxload.name;
Customer_Per_Transformer.No_Loads = xxload.nLoads;
struct2csv(Customer_Per_Transformer, 'Loads_Per_Transformer.csv');


%% 3_Realistic_Electrical_Design 2_Structural Attributes
    summary32.top_ave_deg = network.topology.ave_deg; 
    summary32.top_diameter = network.topology.diameter;
    summary32.top_char_path_len = network.topology.char_path_len;
%     table_summary32 = struct2table(summary32);
%     writetable(table_summary32, fullfile(char(FinalPath{3,2}{1}), 'Structural_Attributes_32.xls'),...
%         'WriteVariableNames', write_header, 'Range', start_corner);
cd(char(FinalPath{3,2}{1}));
struct2csv(summary32,'Aggregate_Structural_Metrics.csv');

%% 3_Realistic Electrical Design 3_Operational Attributes
cd(char(FinalPath{3,3}{1}));
struct2csv(Utili_Ratio.LV,'LV_Utilization_Ratio.csv');
struct2csv(Utili_Ratio.MV,'MV_Utilization_Ratio.csv');
struct2csv(Utili_Ratio.HV,'HV_Utilization_Ratio.csv');

%% 4_Load_Specification 1_Physical Attributes
load_ratios_phase_to_total=struct;
load_ratios_phase_to_total.single_Ph=Utili_Ratio.Ratio_1ph_total_load;
load_ratios_phase_to_total.three_Ph=Utili_Ratio.Ratio_3ph_total_load;
cd(char(FinalPath{4,1}{1}));
struct2csv(load_ratios_phase_to_total,'1ph_3ph_load_ratios_to_total.csv');  

Summary_LV_Loads=circuit.Loads.Summary_of_LV_Loads;
writetable(Summary_LV_Loads, fullfile(char(FinalPath{4,1}{1}), 'Summary_LV_Loads.csv'));

Summary_MV_Loads=circuit.Loads.Summary_of_MV_Loads;
writetable(Summary_MV_Loads, fullfile(char(FinalPath{4,1}{1}), 'Summary_MV_Loads.csv'));

Summary_HV_Loads=circuit.Loads.Summary_of_HV_Loads;
writetable(Summary_HV_Loads, fullfile(char(FinalPath{4,1}{1}), 'Summary_HV_Loads.csv'));

Utili_Ratio.summary_3ph_loads.to=[];
Utili_Ratio.summary_3ph_loads.from=[];
Utili_Ratio.summary_3ph_loads.linecode=[];
Utili_Ratio.summary_3ph_loads.parent=[];
Utili_Ratio.summary_3ph_loads.phases=[];
Utili_Ratio.summary_3ph_loads.nominalV_2nd_xfm=[];
Utili_Ratio.summary_3ph_loads.cont_rating_amps_or_kVA=[];
Utili_Ratio.summary_3ph_loads.resistence_R=[];
Utili_Ratio.summary_3ph_loads.reactance_X=[];
Utili_Ratio.summary_3ph_loads.susceptance_B=[];
Utili_Ratio.summary_3ph_loads.x=[];
Utili_Ratio.summary_3ph_loads.y=[];
Utili_Ratio.summary_3ph_loads.measured_real_power=[];
Utili_Ratio.summary_3ph_loads.measured_reactive_power=[];
Utili_Ratio.summary_3ph_loads.URatio=[];
Utili_Ratio.summary_3ph_loads.length_numPhase1=[];
%Utili_Ratio.summary_3ph_loads.length_numPhase2=[];
Utili_Ratio.summary_3ph_loads.length_numPhase3=[];
Utili_Ratio.summary_3ph_loads.magI_Phase1=[];
Utili_Ratio.summary_3ph_loads.magI_Phase2=[];
Utili_Ratio.summary_3ph_loads.magI_Phase3=[];
Utili_Ratio.summary_3ph_loads.maxDev_I=[];
Utili_Ratio.summary_3ph_loads.maxDev_S=[];
Utili_Ratio.summary_3ph_loads.meanI=[];
Utili_Ratio.summary_3ph_loads.meanS=[];
Utili_Ratio.summary_3ph_loads.arbitrary_x=[];
Utili_Ratio.summary_3ph_loads.arbitrary_y=[];

Utili_Ratio.summary_2ph_loads.to=[];
Utili_Ratio.summary_2ph_loads.from=[];
Utili_Ratio.summary_2ph_loads.linecode=[];
Utili_Ratio.summary_2ph_loads.parent=[];
Utili_Ratio.summary_2ph_loads.phases=[];
Utili_Ratio.summary_2ph_loads.nominalV_2nd_xfm=[];
Utili_Ratio.summary_2ph_loads.cont_rating_amps_or_kVA=[];
Utili_Ratio.summary_2ph_loads.resistence_R=[];
Utili_Ratio.summary_2ph_loads.reactance_X=[];
Utili_Ratio.summary_2ph_loads.susceptance_B=[];
Utili_Ratio.summary_2ph_loads.x=[];
Utili_Ratio.summary_2ph_loads.y=[];
Utili_Ratio.summary_2ph_loads.measured_real_power=[];
Utili_Ratio.summary_2ph_loads.measured_reactive_power=[];
Utili_Ratio.summary_2ph_loads.URatio=[];
Utili_Ratio.summary_2ph_loads.length_numPhase1=[];
%Utili_Ratio.summary_2ph_loads.length_numPhase2=[];
Utili_Ratio.summary_2ph_loads.length_numPhase3=[];
Utili_Ratio.summary_2ph_loads.magI_Phase1=[];
Utili_Ratio.summary_2ph_loads.magI_Phase2=[];
Utili_Ratio.summary_2ph_loads.magI_Phase3=[];
Utili_Ratio.summary_2ph_loads.maxDev_I=[];
Utili_Ratio.summary_2ph_loads.maxDev_S=[];
Utili_Ratio.summary_2ph_loads.meanI=[];
Utili_Ratio.summary_2ph_loads.meanS=[];
Utili_Ratio.summary_2ph_loads.arbitrary_x=[];
Utili_Ratio.summary_2ph_loads.arbitrary_y=[];

Utili_Ratio.summary_1ph_loads.to=[];
Utili_Ratio.summary_1ph_loads.from=[];
Utili_Ratio.summary_1ph_loads.linecode=[];
Utili_Ratio.summary_1ph_loads.parent=[];
Utili_Ratio.summary_1ph_loads.phases=[];
Utili_Ratio.summary_1ph_loads.nominalV_2nd_xfm=[];
Utili_Ratio.summary_1ph_loads.cont_rating_amps_or_kVA=[];
Utili_Ratio.summary_1ph_loads.resistence_R=[];
Utili_Ratio.summary_1ph_loads.reactance_X=[];
Utili_Ratio.summary_1ph_loads.susceptance_B=[];
Utili_Ratio.summary_1ph_loads.x=[];
Utili_Ratio.summary_1ph_loads.y=[];
Utili_Ratio.summary_1ph_loads.measured_real_power=[];
Utili_Ratio.summary_1ph_loads.measured_reactive_power=[];
Utili_Ratio.summary_1ph_loads.URatio=[];
Utili_Ratio.summary_1ph_loads.length_numPhase1=[];
%Utili_Ratio.summary_1ph_loads.length_numPhase2=[];
Utili_Ratio.summary_1ph_loads.length_numPhase3=[];
Utili_Ratio.summary_1ph_loads.magI_Phase1=[];
Utili_Ratio.summary_1ph_loads.magI_Phase2=[];
Utili_Ratio.summary_1ph_loads.magI_Phase3=[];
Utili_Ratio.summary_1ph_loads.maxDev_I=[];
Utili_Ratio.summary_1ph_loads.maxDev_S=[];
Utili_Ratio.summary_1ph_loads.meanI=[];
Utili_Ratio.summary_1ph_loads.meanS=[];
Utili_Ratio.summary_1ph_loads.arbitrary_x=[];
Utili_Ratio.summary_1ph_loads.arbitrary_y=[];


writetable(Utili_Ratio.summary_3ph_loads, fullfile(char(FinalPath{4,1}{1}), 'summary_3ph_loads.csv'));
writetable(Utili_Ratio.summary_2ph_loads, fullfile(char(FinalPath{4,1}{1}), 'summary_2ph_loads.csv'));
writetable(Utili_Ratio.summary_1ph_loads, fullfile(char(FinalPath{4,1}{1}), 'summary_1ph_loads.csv'));


%% 4_Load_Specification 2_Structural Attributes
summary42.Ratio_wye_delta_load = circuit.Ratio_Y_D_Load; 
% table_summary42 = struct2table(summary42);
%     writetable(table_summary42, fullfile(char(FinalPath{4,2}{1}), 'Structural_Attributes_42.xls'),...
%         'WriteVariableNames', write_header, 'Range', start_corner);
cd(char(FinalPath{4,2}{1}));
struct2csv(summary42,'Ratio_wye_delta_load.csv');   

Num_Customers.No_of_HV_Customers=circuit.Loads.No_of_HV_Cust;
Num_Customers.No_of_MV_Customers=circuit.Loads.No_of_MV_Cust;
Num_Customers.No_of_LV_Customers=circuit.Loads.No_of_LV_Cust;
cd(char(FinalPath{4,2}{1}));
struct2csv(Num_Customers,'Num_Customers_Per_Area.csv');




%% 4_Load_Specification 3_Operational Attributes
load_pf=struct2table(circuit.Loads.Load);
Load_Power_Factors.Name = load_pf.Name;
Load_Power_Factors.PF = load_pf.PF;
cd(char(FinalPath{4,3}{1}));
struct2csv(Load_Power_Factors,'Load_Power_Factors.csv'); 

%Utili_Ratio.Power_Factor.PhaseC = [];
% cd(char(FinalPath{4,3}{1}));
% struct2csv(Utili_Ratio.Power_Factor,'Num_Customers_Per_Area.csv');

%% 5_Representative voltage control schemes 1_Physical attributes
clear Count3;
Count3 = struct;
Count3.No_of_Regulators = Utili_Ratio.No_of_Regulators;
Count3.No_of_Capacitors = circuit.Loads.No_of_Capacitors;
cd(char(FinalPath{5,1}{1}));
struct2csv(Count3,'counts_voltage_control_devices.csv');

Utili_Ratio.summary_regulators.bus=[];
Utili_Ratio.summary_regulators.linecode=[];
Utili_Ratio.summary_regulators.parent=[];
Utili_Ratio.summary_regulators.phases=[];
Utili_Ratio.summary_regulators.length=[];
Utili_Ratio.summary_regulators.resistence_R=[];
Utili_Ratio.summary_regulators.reactance_X=[];
Utili_Ratio.summary_regulators.susceptance_B=[];
Utili_Ratio.summary_regulators.x=[];
Utili_Ratio.summary_regulators.y=[];
Utili_Ratio.summary_regulators.measured_real_power=[];
Utili_Ratio.summary_regulators.measured_reactive_power=[];
Utili_Ratio.summary_regulators.Vmag_phase_A=[];
Utili_Ratio.summary_regulators.Vmag_phase_B=[];
Utili_Ratio.summary_regulators.Vmag_phase_C=[];
Utili_Ratio.summary_regulators.length_numPhase1=[];
%Utili_Ratio.summary_regulators.length_numPhase2=[];
Utili_Ratio.summary_regulators.length_numPhase3=[];
Utili_Ratio.summary_regulators.maxDev_V=[];
Utili_Ratio.summary_regulators.arbitrary_x=[];
Utili_Ratio.summary_regulators.arbitrary_y=[];
Utili_Ratio.summary_regulators.nominalV_2nd_xfm=[];

sumreg=table;
sumreg.type=Utili_Ratio.summary_regulators.type;
sumreg.name=Utili_Ratio.summary_regulators.name;
sumreg.to=Utili_Ratio.summary_regulators.to;
sumreg.from=Utili_Ratio.summary_regulators.from;
sumreg.phasecount=Utili_Ratio.summary_regulators.phasecount;
sumreg.nominal_2nd_voltage_kV=Utili_Ratio.summary_regulators.nominalV;
sumreg.rating_kVA=Utili_Ratio.summary_regulators.cont_rating_amps_or_kVA;
sumreg.active_power_Aph_kW=Utili_Ratio.summary_regulators.power_in_A_P;
sumreg.reactive_power_Aph_kVar=Utili_Ratio.summary_regulators.power_in_A_Q;
sumreg.active_power_Bph_kW=Utili_Ratio.summary_regulators.power_in_B_P;
sumreg.reactive_power_Bph_kVar=Utili_Ratio.summary_regulators.power_in_B_Q;
sumreg.active_power_Cph_kW=Utili_Ratio.summary_regulators.power_in_C_P;
sumreg.reactive_power_Cph_kVar=Utili_Ratio.summary_regulators.power_in_C_Q;
sumreg.current_Aph_real_Amps=Utili_Ratio.summary_regulators.current_in_A_real;
sumreg.current_Aph_imag_Amps=Utili_Ratio.summary_regulators.current_in_A_im;
sumreg.current_Bph_real_Amps=Utili_Ratio.summary_regulators.current_in_B_real;
sumreg.current_Bph_imag_Amps=Utili_Ratio.summary_regulators.current_in_B_im;
sumreg.current_Cph_real_Amps=Utili_Ratio.summary_regulators.current_in_C_real;
sumreg.current_Cph_imag_Amps=Utili_Ratio.summary_regulators.current_in_C_im;
sumreg.voltage_pri_Aph_mag_volts=Utili_Ratio.summary_regulators.voltage_in_A_mag;
sumreg.voltage_pri_Aph_degree=Utili_Ratio.summary_regulators.voltage_in_A_deg;
sumreg.voltage_pri_Bph_mag_volts=Utili_Ratio.summary_regulators.voltage_in_B_mag;
sumreg.voltage_pri_Bph_degree=Utili_Ratio.summary_regulators.voltage_in_B_deg;
sumreg.voltage_pri_Cph_mag_volts=Utili_Ratio.summary_regulators.voltage_in_C_mag;
sumreg.voltage_pri_Cph_degree=Utili_Ratio.summary_regulators.voltage_in_C_deg;
sumreg.URatio=Utili_Ratio.summary_regulators.URatio;

writetable(sumreg, fullfile(char(FinalPath{5,1}{1}), 'summary_regulators.csv'));

struct2csv(circuit.Loads.Capacitor_controls_Summary,'Capacitor_controls_Summary.csv');

struct2csv(circuit.Loads.Reg_controls_Summary,'Regulator_controls_Summary.csv');

%% 5_Representative voltage control schemes 3_Operational attributes
cd(char(FinalPath{5,3}{1}));
sumd1=struct2table(circuit.Loads.Capacitor_Summary.Line)
writetable(sumd1, fullfile(char(FinalPath{5,3}{1}), 'capacitor_reactive_power_injection.csv'));
struct2csv(circuit.Loads.Reg_operational_Summary,'regulator_operation_summary.csv');

%% 6_Represntative_Volatge_Profiles 3_Operational Attributes
%use for ploting voltage profile w.r.t distance
% Voltage_Profile;
% Voltage_Drop_Phase_A.Distance = Voltage.Dist1.';
% Voltage_Drop_Phase_A.delta_V_pu = Voltage.Voltage_Drop_Phase_A.';
% Voltage_Drop_Phase_B.Distance = Voltage.Dist2.';
% Voltage_Drop_Phase_B.delta_V_pu = Voltage.Voltage_Drop_Phase_B;
% Voltage_Drop_Phase_C.Distance = Voltage.Dist3.';
% Voltage_Drop_Phase_C.delta_V_pu = Voltage.Voltage_Drop_Phase_C;
% cd(char(FinalPath{6,3}{1}));
% struct2csv(Voltage_Drop_Phase_A,'Voltage_Drop_Phase_A.csv');
% struct2csv(Voltage_Drop_Phase_B,'Voltage_Drop_Phase_B.csv');
% struct2csv(Voltage_Drop_Phase_C,'Voltage_Drop_Phase_C.csv');

%writetable(Feeder.X_R_Ratio, fullfile(char(FinalPath{6,1}{1}), 'XbyR_Ratio.csv'));

%% 7_Repres_SystemLosses_LoadInterupptions 3_Operational Attributes
summary73.Total_Active_Power_Loss_kW=(circuit.total_loss(1))/1e3;
summary73.Total_Reactive_Power_Loss_kVar=(circuit.total_loss(2))/1e3;
cd(char(FinalPath{7,3}{1}));
struct2csv(summary73,'system_losses.csv');


ne=length(circuit.all_elements.element_losses);
odd = 1:2:ne;
even = 2:2:ne;
summary731.Element = circuit.all_elements.element_names;
summary731.Active_PowerLoss_kW = circuit.all_elements.element_losses(odd).';
summary731.Reactive_PowerLoss_kVar = circuit.all_elements.element_losses(even).';
struct2csv(summary731,'element_wise_losses.csv');



%% 8_Realistic_reconfigoptions 1_physical attributes
clear Count4;
Count4.No_of_Reclosers = circuit.No_of_Reclosers;
Count4.No_of_Fuses = circuit.fuse.no_of_fuse;
Count4.No_of_Swicthes = Utili_Ratio.No_of_Switches;
cd(char(FinalPath{8,1}{1}));
struct2csv(Count4,'counts_swithcing_devices.csv');
struct2csv(circuit.recl_data,'Recloser_Summary.csv');
struct2csv(circuit.fuse.fuse_data,'Fuse_Summary.csv');

Utili_Ratio.summary_switches.bus=[];
Utili_Ratio.summary_switches.linecode=[];
Utili_Ratio.summary_switches.parent=[];
Utili_Ratio.summary_switches.phases=[];
Utili_Ratio.summary_switches.length=[];
Utili_Ratio.summary_switches.resistence_R=[];
Utili_Ratio.summary_switches.reactance_X=[];
Utili_Ratio.summary_switches.susceptance_B=[];
Utili_Ratio.summary_switches.x=[];
Utili_Ratio.summary_switches.y=[];
Utili_Ratio.summary_switches.measured_real_power=[];
Utili_Ratio.summary_switches.measured_reactive_power=[];
Utili_Ratio.summary_switches.Vmag_phase_A=[];
Utili_Ratio.summary_switches.Vmag_phase_B=[];
Utili_Ratio.summary_switches.Vmag_phase_C=[];
Utili_Ratio.summary_switches.length_numPhase1=[];
Utili_Ratio.summary_switches.length_numPhase2=[];
Utili_Ratio.summary_switches.length_numPhase3=[];
Utili_Ratio.summary_switches.maxDev_V=[];
Utili_Ratio.summary_switches.arbitrary_x=[];
Utili_Ratio.summary_switches.arbitrary_y=[];
Utili_Ratio.summary_switches.nominalV_2nd_xfm=[];

sumsub2=table;
sumsub2.type=Utili_Ratio.summary_switches.type;
sumsub2.name=Utili_Ratio.summary_switches.name;
sumsub2.to=Utili_Ratio.summary_switches.to;
sumsub2.from=Utili_Ratio.summary_switches.from;
sumsub2.phasecount=Utili_Ratio.summary_switches.phasecount;
sumsub2.nominal_voltage_kV=Utili_Ratio.summary_switches.nominalV;
sumsub2.rating_Amps=Utili_Ratio.summary_switches.cont_rating_amps_or_kVA;
sumsub2.active_power_Aph_kW=Utili_Ratio.summary_switches.power_in_A_P;
sumsub2.reactive_power_Aph_kVar=Utili_Ratio.summary_switches.power_in_A_Q;
sumsub2.active_power_Bph_kW=Utili_Ratio.summary_switches.power_in_B_P;
sumsub2.reactive_power_Bph_kVar=Utili_Ratio.summary_switches.power_in_B_Q;
sumsub2.active_power_Cph_kW=Utili_Ratio.summary_switches.power_in_C_P;
sumsub2.reactive_power_Cph_kVar=Utili_Ratio.summary_switches.power_in_C_Q;
sumsub2.current_Aph_real_Amps=Utili_Ratio.summary_switches.current_in_A_real;
sumsub2.current_Aph_imag_Amps=Utili_Ratio.summary_switches.current_in_A_im;
sumsub2.current_Bph_real_Amps=Utili_Ratio.summary_switches.current_in_B_real;
sumsub2.current_Bph_imag_Amps=Utili_Ratio.summary_switches.current_in_B_im;
sumsub2.current_Cph_real_Amps=Utili_Ratio.summary_switches.current_in_C_real;
sumsub2.current_Cph_imag_Amps=Utili_Ratio.summary_switches.current_in_C_im;
sumsub2.voltage_Aph_mag_volts=Utili_Ratio.summary_switches.voltage_in_A_mag;
sumsub2.voltage_Aph_degree=Utili_Ratio.summary_switches.voltage_in_A_deg;
sumsub2.voltage_Bph_mag_volts=Utili_Ratio.summary_switches.voltage_in_B_mag;
sumsub2.voltage_Bph_degree=Utili_Ratio.summary_switches.voltage_in_B_deg;
sumsub2.voltage_Cph_mag_volts=Utili_Ratio.summary_switches.voltage_in_C_mag;
sumsub2.voltage_Cph_degree=Utili_Ratio.summary_switches.voltage_in_C_deg;
sumsub2.URatio=Utili_Ratio.summary_switches.URatio;

writetable(sumsub2, fullfile(char(FinalPath{8,1}{1}), 'Switches_Summary.csv'));

%  HV > 115kV, 69kV < MV < 2.4kV, LV < 600V
MaxiRat = struct;
Idx=find(sumsub2.nominal_voltage_kV < (0.62/1.732));
MaxiRat.LV_Max_Amps = max(sumsub2.rating_Amps(Idx,:)); 

Idx=find(sumsub2.nominal_voltage_kV < (80/1.732) & sumsub2.nominal_voltage_kV > (2/1.732));
MaxiRat.MV_Max_Amps = max(sumsub2.rating_Amps(Idx,:)); 

Idx=find(sumsub2.nominal_voltage_kV > (100/1.732));
MaxiRat.HV_Max_Amps = max(sumsub2.rating_Amps(Idx,:)); 

cd(char(FinalPath{8,1}{1}));
struct2csv(MaxiRat,'Maximum_Rating_Per_Voltage_Class.csv');
% writetable(MaxiRat, fullfile(char(FinalPath{8,1}{1}), 'Maximum_Rating_Per_Voltage_Class.csv'));

%% 9_Reasonal Computational Requirements 3_Operational Attributes
summary93.Total_Time_Power_Flow_seconds = circuit.Power_Flow_Time;
summary93.Iterations_Power_Flow = circuit.Power_Flow_Iterations; 
summary93.Tolerance_Power_Flow = circuit.Power_Flow_Tolerance; 
% table_summary93 = struct2table(summary93);
%     writetable(table_summary93, fullfile(char(FinalPath{9,3}{1}), 'Structural_Attributes_93.xls'),...
%         'WriteVariableNames', write_header, 'Range', start_corner);
cd(char(FinalPath{9,3}{1}));
struct2csv(summary93,'PowerFlow_Computations.csv');
    
%% 8_Realistic_Reconfiguration_Options 2_Structural Attributes
%plot_aMatrix_MLX;



cd('C:\Users\athakall\Desktop\FEEDER_CODES\SMART-DS-master\Network_Characterization\ODSS\scripts');


