addpath('C:\Users\athakall\Desktop\FEEDER_CODES\SMART-DS-master\Network_Characterization\ODSS\functions');
addpath('C:\Users\athakall\Desktop\FEEDER_CODES\SMART-DS-master\Network_Characterization\ODSS\functions\matlab-networks-toolbox-master');
set_up1_MLX;
MainFolder='C:\Users\athakall\Desktop\FEEDER_CODES\Validation_CSV_Files';
CaseFolder=file.caseName;
CaseFolder_Cr = fullfile(MainFolder,file.caseName)

units = 'km';
%units = 'ft'
m = 'N' %loveland
if strcmp('km',units)
    dist_mult = 0.621371
end
if strcmp('ft',units)
    dist_mult = 0.000189394
end
src_node = 'st_mat';
load(fullfile(saveWorkspace, 'Feeder'));
load(fullfile(saveWorkspace, 'summary_lines_final'));
load(fullfile(saveWorkspace, 'summary_nodes_final'));
load(fullfile(saveWorkspace, 'FeederData'));
load(fullfile(saveWorkspace, 'inputsTable'));
load(fullfile(saveWorkspace, 'a_matrix'));
load(fullfile(saveWorkspace, 'a_matrix_non'));
load(fullfile(saveWorkspace, 'circuit'));

SysLevel = table;
SysLevel.Name = file.caseName;
SysLevel.No_of_Substations = Feeder.No_of_Substations;
SysLevel.Total_No_Feeders = Feeder.Total_No_Feeders;
SysLevel.Capacity_MVA = max(summary_lines_final.cont_rating_amps_or_kVA)*2/1000;
SysLevel.Distribution_Tranformer_Total_Capacity_MVA = sum(FeederData.Distribution_Tranformer_Total_Capacity_MVA);
SysLevel.No_of_Distribution_Transformer =  sum(FeederData.No_of_Distribution_Transformer);

aa =  strcmp(summary_nodes_final.type,'node');
bb = find(aa==1);
cc = summary_nodes_final.nominalV(bb);
dd_mv = length(find(cc > 1 & cc < 36));
dd_lv = length(find(cc < 1));
SysLevel.No_of_MV_Nodes = dd_mv;
SysLevel.No_of_LV_Nodes = dd_lv;

SysLevel.No_of_Customers = sum(FeederData.No_of_Customers);


tf_1a = find(summary_lines_final.phasecount == 1);
tf_1b = strcmp(summary_lines_final.type(tf_1a),'transformer');
tf_1 = length(find(tf_1b == 1));
tf_3a = find(summary_lines_final.phasecount == 3);
tf_3b = strcmp(summary_lines_final.type(tf_3a),'transformer');
tf_3 = length(find(tf_3b == 1));
%SysLevel.Ratio_1phto3ph_Xfrm = tf_1/tf_3;

ilv1 = strcmp(summary_lines_final.type,'line');
ilv = find(ilv1 == 1);
aa = summary_lines_final.nominalV(ilv);
bb = summary_lines_final.length(ilv);
ilvlen1 = find(aa < 1);
SysLevel.lv_length_miles = sum(bb(ilvlen1))*dist_mult;
ilvlen1 = find(aa < 36 & aa > 1);
Syslevel.mv_length_miles = sum(bb(ilvlen1))*dist_mult;
idx_fut = find(summary_nodes_final.phasecount == 3);
dis_fur = summary_nodes_final.bus(idx_fut);
[cc dd ee]=intersect(strtok(circuit.Nodes_Dis,'.'),dis_fur);
% if isempty(dd)
%    SysLevel.furtherest_node_miles = 0;
% else
%    SysLevel.furtherest_node_miles = max(circuit.Distance(dd))*0.621371;
% end

%new update mv/lv line lengths
% total 3-ph MV-length
idxmv = find(summary_lines_final.nominalV < 36 & summary_lines_final.nominalV > 1 & ...
        summary_lines_final.phasecount == 3);
if isempty(idxmv)
    len_3ph = 0;
else
    len_3ph = sum(summary_lines_final.length(idxmv));
end
idxoh = regexp(summary_lines_final.linecode,'oh');
idxoh1=find(~cellfun(@isempty,idxoh));
idx_oh = intersect(idxoh1,idxmv);
if isempty(idx_oh)
    len_3ph_oh = 0;
else
    len_3ph_oh = sum(summary_lines_final.length(idx_oh));
end
% SysLevel.Length_mv3ph_miles = len_3ph*dist_mult; %in miles
% SysLevel.Length_OH_mv3ph_miles = len_3ph_oh*dist_mult; %in miles

% total 2-ph MV-length
idxmv = find(summary_lines_final.nominalV < 36 & summary_lines_final.nominalV > 1 & ...
    summary_lines_final.phasecount == 2);
if isempty(idxmv)
    len_3ph = 0;
else
    len_3ph = sum(summary_lines_final.length(idxmv));
end
idxoh = regexp(summary_lines_final.linecode,'oh');
idxoh1=find(~cellfun(@isempty,idxoh));
idx_oh = intersect(idxoh1,idxmv);
if isempty(idx_oh)
    len_3ph_oh = 0;
else
    len_3ph_oh = sum(summary_lines_final.length(idx_oh));
end
% SysLevel.Length_mv2ph_miles = len_3ph*dist_mult; %in miles
% SysLevel.Length_OH_mv2ph_miles = len_3ph_oh*dist_mult; %in miles

% total 1-ph MV-length
idxmv = find(summary_lines_final.nominalV < 36 & summary_lines_final.nominalV > 1 & ...
    summary_lines_final.phasecount == 1);
if isempty(idxmv)
    len_3ph = 0;
else
    len_3ph = sum(summary_lines_final.length(idxmv));
end
idxoh = regexp(summary_lines_final.linecode,'oh');
idxoh1=find(~cellfun(@isempty,idxoh));
idx_oh = intersect(idxoh1,idxmv);
if isempty(idx_oh)
    len_3ph_oh = 0;
else
    len_3ph_oh = sum(summary_lines_final.length(idx_oh));
end
% SysLevel.Length_mv1ph_miles = len_3ph*dist_mult; %in miles
% SysLevel.Length_OH_mv1ph_miles = len_3ph_oh*dist_mult; %in miles

% total 3-ph LV-length

idxmv = find(summary_lines_final.nominalV < 1 & ...
    summary_lines_final.phasecount == 3);
if isempty(idxmv)
    len_3ph = 0;
else
    len_3ph = sum(summary_lines_final.length(idxmv));
end
idxoh = regexp(summary_lines_final.linecode,'oh');
idxoh1=find(~cellfun(@isempty,idxoh));
idx_oh = intersect(idxoh1,idxmv);
if isempty(idx_oh)
    len_3ph_oh = 0;
else
    len_3ph_oh = sum(summary_lines_final.length(idx_oh));
end
% SysLevel.Length_lv3ph_miles = len_3ph*dist_mult; %in miles
% SysLevel.Length_OH_lv3ph_miles = len_3ph_oh*dist_mult; %in miles

% total 2-ph LV-length

idxmv = find(summary_lines_final.nominalV < 1 & ...
    summary_lines_final.phasecount == 2);
if isempty(idxmv)
    len_3ph = 0;
else
    len_3ph = sum(summary_lines_final.length(idxmv));
end
idxoh = regexp(summary_lines_final.linecode,'oh');
idxoh1=find(~cellfun(@isempty,idxoh));
idx_oh = intersect(idxoh1,idxmv);
if isempty(idx_oh)
    len_3ph_oh = 0;
else
    len_3ph_oh = sum(summary_lines_final.length(idx_oh));
end
% Length_lv2ph_miles = len_3ph*dist_mult; %in miles
% Length_OH_lv2ph_miles = len_3ph_oh*dist_mult; %in miles


% total 1-ph LV-length
idxmv = find(summary_lines_final.nominalV < 1 & ...
    summary_lines_final.phasecount == 1);
if isempty(idxmv)
    len_3ph = 0;
else
    len_3ph = sum(summary_lines_final.length(idxmv));
end
idxoh = regexp(summary_lines_final.linecode,'oh');
idxoh1=find(~cellfun(@isempty,idxoh));
idx_oh = intersect(idxoh1,idxmv);
if isempty(idx_oh)
    len_3ph_oh = 0;
else
    len_3ph_oh = sum(summary_lines_final.length(idx_oh));
end
%SysLevel.Length_lv1ph_miles = len_3ph*dist_mult + Length_lv2ph_miles; %in miles % LV 2-ph lines are treated as 1-ph line due to cneter tap
%SysLevel.Length_OH_lv1ph_miles = len_3ph_oh*dist_mult + Length_OH_lv2ph_miles; %in miles
%new update mv and lv line length

aa = strcmp(summary_lines_final.from,src_node);
bb = find(aa==1);
power_P_A = sum(summary_lines_final.power_in_A_P(bb));
power_P_B = sum(summary_lines_final.power_in_B_P(bb));
power_P_C = sum(summary_lines_final.power_in_C_P(bb));

Total_1ph = power_P_A + power_P_B + power_P_C;

power_Q_A = sum(summary_lines_final.power_in_A_Q(bb));
power_Q_B = sum(summary_lines_final.power_in_B_Q(bb));
power_Q_C = sum(summary_lines_final.power_in_C_Q(bb));

Total_1ph = power_P_A + power_P_B + power_P_C;
Total_1ph_q = power_Q_A + power_Q_B + power_Q_C;

% SysLevel.ph_A_load_kw_percentage = (power_P_A/Total_1ph)*100;
% SysLevel.ph_B_load_kw_percentage = (power_P_B/Total_1ph)*100;
% SysLevel.ph_C_load_kw_percentage = (power_P_C/Total_1ph)*100;

SysLevel.Total_Demand_kW = Total_1ph;
SysLevel.Total_Reactive_Power_kVAr = Total_1ph_q;

ivload1 =strcmp(summary_nodes_final.type,'load');
ivload = find(ivload1==1);
ilvlo = find(summary_nodes_final.nominalV(ivload) < 1 & summary_nodes_final.phasecount(ivload) == 1);
cust_1ph_lv = length(ilvlo);
ilvlo = find(summary_nodes_final.nominalV(ivload) < 1 & summary_nodes_final.phasecount(ivload) == 2);
cust_2ph_lv = length(ilvlo);
ilvlo = find(summary_nodes_final.nominalV(ivload) < 1 & summary_nodes_final.phasecount(ivload) == 3);
cust_3ph_lv = length(ilvlo);
ilvlo = find(summary_nodes_final.nominalV(ivload) < 36 & summary_nodes_final.nominalV(ivload) > 1 & summary_nodes_final.phasecount(ivload) == 3);
cust_3ph_mv = length(ilvlo);
SysLevel.No_Loads_LV_1ph = cust_1ph_lv+cust_2ph_lv;
SysLevel.No_Loads_LV_3ph = cust_3ph_lv;
SysLevel.No_Loads_MV_3ph = cust_3ph_mv;
SysLevel.No_Loads_per_Xfrm = (cust_1ph_lv+cust_2ph_lv+cust_3ph_lv+cust_3ph_mv)/SysLevel.No_of_Distribution_Transformer;

%no of line regulators
idxr=strcmp(summary_lines_final.type,'regulator');
idx1r=find(idxr==1);
No_of_reg = length(idx1r);
SysLevel.No_of_Regulators = No_of_reg;

%No of Cap Banks
idx=strcmp(summary_nodes_final.type,'capacitor');
idx1=find(idx==1);
No_of_Cap = length(idx1);    
SysLevel.No_of_CapacitorBanks = No_of_Cap;


        
idx=regexp(summary_lines_final.name,'boos');
idx1=find(~cellfun(@isempty,idx));
No_of_inter=length(idx1);
SysLevel.No_of_Boosters=No_of_inter;

%HV Volatge > 36kV
SysLevel.NominalVoltage_HV_kV = max(summary_lines_final.nominalV(find(summary_lines_final.nominalV > 36 & summary_lines_final.nominalV < 71)));
SysLevel.NominalVoltage_MV_kV = max(summary_lines_final.nominalV(find(summary_lines_final.nominalV > 1 & summary_lines_final.nominalV < 36)));
SysLevel.NominalVoltage_LV_kV = max(summary_lines_final.nominalV(find(summary_lines_final.nominalV < 1)));


% NO of swithcing devices
idx=regexp(summary_lines_final.name,'fuse');
idx1=find(~cellfun(@isempty,idx));
No_of_inter=length(idx1);
SysLevel.No_of_Fuses=No_of_inter;

idx=regexp(summary_lines_final.name,'recloser');
idx1=find(~cellfun(@isempty,idx));
No_of_inter=length(idx1);
SysLevel.No_of_Reclosers=No_of_inter;

idx=regexp(summary_lines_final.name,'secci');
idx1=find(~cellfun(@isempty,idx));
No_of_inter=length(idx1);
SysLevel.No_of_Sectionalizers=No_of_inter;

idx=regexp(summary_lines_final.name,'switch');
idx1=find(~cellfun(@isempty,idx));
No_of_inter=length(idx1);
SysLevel.No_of_Switches=No_of_inter;

idx=regexp(summary_lines_final.name,'break');
idx1=find(~cellfun(@isempty,idx));
No_of_inter=length(idx1);
SysLevel.No_of_Breakers=No_of_inter;

idx=regexp(summary_lines_final.name,'interruptor');
idx1=find(~cellfun(@isempty,idx));
No_of_inter=length(idx1);
SysLevel.No_of_Interruptors=No_of_inter;


variables = {'SysLevel'};
for iV = 1:length(variables)
    saveMat = fullfile(saveWorkspace, [variables{iV} '.mat']);
    save(saveMat, variables{iV});
end

writetable(SysLevel, fullfile(char(CaseFolder_Cr), 'System_Level.csv'));

disp('Created System Level Metrics');


