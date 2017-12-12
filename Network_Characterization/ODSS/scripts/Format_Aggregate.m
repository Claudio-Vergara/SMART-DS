
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
load(fullfile(saveWorkspace, 'Feeder'));
load(fullfile(saveWorkspace, 'inputsTable'));
load(fullfile(saveWorkspace, 'circuit'));
FeederData = table;
%FeederData.Feeder_Number = Feeder.Feeder_Summary.To_Node;
%FeederData.Substation_Name = Feeder.Feeder_Summary.From_Node;
for i=1:Feeder.Total_No_Feeders;
    i
    filename = sprintf('%s_%d','FeederNo',i);
    aa = strtok(Feeder.summary_feeder_lines.(filename).from,'.');
    [bb cc dd] = intersect(Feeder.Feeder_Summary.To_Node,aa);
    FeederData.Feeder_Number(i,1) = bb(1);
    FeederData.Substation_Name(i,1) = Feeder.Feeder_Summary.From_Node(cc(1));
    idx=regexp(Feeder.summary_propbable_substations.to,Feeder.Feeder_Summary.From_Node(i));
    Idx1=find(~cellfun(@isempty,idx));
    FeederData.Substation_Capacity_MVA(i) = unique((Feeder.summary_propbable_substations.cont_rating_amps_or_kVA(Idx1))/1000);
end
tab_string=repmat('No Info',Feeder.Total_No_Feeders,1); %remove this part if type of substation info is available
FeederData.Substation_Type = tab_string;
%HV Volatge > 36kV
for i=1:Feeder.Total_No_Feeders;
    filename = sprintf('%s_%d','FeederNo',i);
    idx = find(Feeder.summary_feeder_nodes.(filename).nominalV > 36);
    maxV = max(Feeder.summary_feeder_nodes.(filename).nominalV(idx));
    if isempty(maxV)
    FeederData.NominalVoltage_HV_kV(i) = 0; 
    else
    FeederData.NominalVoltage_HV_kV(i) = maxV; 
    end
end

%MV Volatge 1kV-36kV
for i=1:Feeder.Total_No_Feeders;
    filename = sprintf('%s_%d','FeederNo',i);
    idx = find(Feeder.summary_feeder_nodes.(filename).nominalV < 36 & Feeder.summary_feeder_nodes.(filename).nominalV > 1);
    maxV = max(Feeder.summary_feeder_nodes.(filename).nominalV(idx));
    if isempty(maxV)
    FeederData.NominalVoltage_MV_kV(i) = 0; 
    else
    FeederData.NominalVoltage_MV_kV(i) = maxV; 
    end
end


%LV Volatge < 1kV
for i=1:Feeder.Total_No_Feeders;
    filename = sprintf('%s_%d','FeederNo',i);
    idx = find(Feeder.summary_feeder_nodes.(filename).nominalV < 1);
    maxV = max(Feeder.summary_feeder_nodes.(filename).nominalV(idx));
    if isempty(maxV)
    FeederData.NominalVoltage_LV_kV(i) = 0; %no voltage at this level
    else
    FeederData.NominalVoltage_LV_kV(i) = maxV; 
    end
end

%%Total Demand
for i=1:Feeder.Total_No_Feeders;
    filename = sprintf('%s_%d','FeederNo',i);
    PA = sum(Feeder.summary_feeder_nodes.(filename).power_in_A_P);
    PB = sum(Feeder.summary_feeder_nodes.(filename).power_in_B_P);
    PC = sum(Feeder.summary_feeder_nodes.(filename).power_in_C_P);
    P=sum(PA+PB+PC);
    FeederData.Active_Power_Demand_kW(i) = P;
end
% total 3-ph length
for i=1:Feeder.Total_No_Feeders;
    filename = sprintf('%s_%d','FeederNo',i);
    idx = find(Feeder.summary_feeder_lines.(filename).phasecount == 3);
    idx1 = regexp(Feeder.summary_feeder_lines.(filename).linecode(idx),'oh');
    idx2=find(~cellfun(@isempty,idx1));
    aa=Feeder.summary_feeder_lines.(filename).length(idx);
    if isempty(idx)
        len_3ph = 0;
    else
        len_3ph = sum(Feeder.summary_feeder_lines.(filename).length(idx));
    end
    if isempty(idx2)
        len_3ph_oh = 0;
    else
        len_3ph_oh = sum(Feeder.summary_feeder_lines.(filename).length(idx2));
        len_3ph_oh = sum(aa(idx2));
    end
    FeederData.Length_3ph_miles(i) = len_3ph*dist_mult; %in miles
    FeederData.Length_OH_3ph_miles(i) = len_3ph_oh*dist_mult; %in miles
end

% total 2-ph length
for i=1:Feeder.Total_No_Feeders;
    filename = sprintf('%s_%d','FeederNo',i);
    idx = find(Feeder.summary_feeder_lines.(filename).phasecount == 2);
    idx1 = regexp(Feeder.summary_feeder_lines.(filename).linecode(idx),'oh');
    idx2=find(~cellfun(@isempty,idx1));
    aa=Feeder.summary_feeder_lines.(filename).length(idx);
    if isempty(idx)
        len_2ph = 0;
    else
        len_2ph = sum(Feeder.summary_feeder_lines.(filename).length(idx));
    end
    if isempty(idx2)
        len_2ph_oh = 0;
    else
        len_2ph_oh = sum(Feeder.summary_feeder_lines.(filename).length(idx2));
        len_2ph_oh = sum(aa(idx2));
    end
    FeederData.Length_2ph_miles(i) = len_2ph*dist_mult; %in miles
    FeederData.Length_OH_2ph_miles(i) = len_2ph_oh*dist_mult; %in miles
end

% total 1-ph length
for i=1:Feeder.Total_No_Feeders;
    filename = sprintf('%s_%d','FeederNo',i);
    idx = find(Feeder.summary_feeder_lines.(filename).phasecount == 1);
    idx1 = regexp(Feeder.summary_feeder_lines.(filename).linecode(idx),'oh');
    idx2=find(~cellfun(@isempty,idx1));
    aa=Feeder.summary_feeder_lines.(filename).length(idx);
    if isempty(idx)
        len_1ph = 0;
    else
        len_1ph = sum(Feeder.summary_feeder_lines.(filename).length(idx));
    end
    if isempty(idx2)
        len_1ph_oh = 0;
    else
        len_1ph_oh = sum(Feeder.summary_feeder_lines.(filename).length(idx2));
        len_1ph_oh = sum(aa(idx2));
    end
    FeederData.Length_1ph_miles(i) = len_1ph*dist_mult; %in miles
    FeederData.Length_OH_1ph_miles(i) = len_1ph_oh*dist_mult; %in miles
end
%new update mv/lv line lengths
% total 3-ph MV-length
for i=1:Feeder.Total_No_Feeders;
    filename = sprintf('%s_%d','FeederNo',i);
    idxmv = find(Feeder.summary_feeder_lines.(filename).nominalV < 36 & Feeder.summary_feeder_lines.(filename).nominalV > 1 & ...
        Feeder.summary_feeder_lines.(filename).phasecount == 3);
    if isempty(idxmv)
        len_3ph = 0;
    else
        len_3ph = sum(Feeder.summary_feeder_lines.(filename).length(idxmv));
    end
    idxoh = regexp(Feeder.summary_feeder_lines.(filename).linecode,'oh');
    idxoh1=find(~cellfun(@isempty,idxoh));
    idx_oh = intersect(idxoh1,idxmv);
    if isempty(idx_oh)
        len_3ph_oh = 0;
    else
        len_3ph_oh = sum(Feeder.summary_feeder_lines.(filename).length(idx_oh));
    end
    FeederData.Length_mv3ph_miles(i) = len_3ph*dist_mult; %in miles
    FeederData.Length_OH_mv3ph_miles(i) = len_3ph_oh*dist_mult; %in miles
end

% total 2-ph MV-length
for i=1:Feeder.Total_No_Feeders;
    filename = sprintf('%s_%d','FeederNo',i);
    idxmv = find(Feeder.summary_feeder_lines.(filename).nominalV < 36 & Feeder.summary_feeder_lines.(filename).nominalV > 1 & ...
        Feeder.summary_feeder_lines.(filename).phasecount == 2);
    if isempty(idxmv)
        len_3ph = 0;
    else
        len_3ph = sum(Feeder.summary_feeder_lines.(filename).length(idxmv));
    end
    idxoh = regexp(Feeder.summary_feeder_lines.(filename).linecode,'oh');
    idxoh1=find(~cellfun(@isempty,idxoh));
    idx_oh = intersect(idxoh1,idxmv);
    if isempty(idx_oh)
        len_3ph_oh = 0;
    else
        len_3ph_oh = sum(Feeder.summary_feeder_lines.(filename).length(idx_oh));
    end
    FeederData.Length_mv2ph_miles(i) = len_3ph*dist_mult; %in miles
    FeederData.Length_OH_mv2ph_miles(i) = len_3ph_oh*dist_mult; %in miles
end

% total 1-ph MV-length
for i=1:Feeder.Total_No_Feeders;
    filename = sprintf('%s_%d','FeederNo',i);
    idxmv = find(Feeder.summary_feeder_lines.(filename).nominalV < 36 & Feeder.summary_feeder_lines.(filename).nominalV > 1 & ...
        Feeder.summary_feeder_lines.(filename).phasecount == 1);
    if isempty(idxmv)
        len_3ph = 0;
    else
        len_3ph = sum(Feeder.summary_feeder_lines.(filename).length(idxmv));
    end
    idxoh = regexp(Feeder.summary_feeder_lines.(filename).linecode,'oh');
    idxoh1=find(~cellfun(@isempty,idxoh));
    idx_oh = intersect(idxoh1,idxmv);
    if isempty(idx_oh)
        len_3ph_oh = 0;
    else
        len_3ph_oh = sum(Feeder.summary_feeder_lines.(filename).length(idx_oh));
    end
    FeederData.Length_mv1ph_miles(i) = len_3ph*dist_mult; %in miles
    FeederData.Length_OH_mv1ph_miles(i) = len_3ph_oh*dist_mult; %in miles
end

% total 3-ph LV-length
for i=1:Feeder.Total_No_Feeders;
    filename = sprintf('%s_%d','FeederNo',i);
    idxmv = find(Feeder.summary_feeder_lines.(filename).nominalV < 1 & ...
        Feeder.summary_feeder_lines.(filename).phasecount == 3);
    if isempty(idxmv)
        len_3ph = 0;
    else
        len_3ph = sum(Feeder.summary_feeder_lines.(filename).length(idxmv));
    end
    idxoh = regexp(Feeder.summary_feeder_lines.(filename).linecode,'oh');
    idxoh1=find(~cellfun(@isempty,idxoh));
    idx_oh = intersect(idxoh1,idxmv);
    if isempty(idx_oh)
        len_3ph_oh = 0;
    else
        len_3ph_oh = sum(Feeder.summary_feeder_lines.(filename).length(idx_oh));
    end
    FeederData.Length_lv3ph_miles(i) = len_3ph*dist_mult; %in miles
    FeederData.Length_OH_lv3ph_miles(i) = len_3ph_oh*dist_mult; %in miles
end

% total 2-ph LV-length
for i=1:Feeder.Total_No_Feeders;
    filename = sprintf('%s_%d','FeederNo',i);
    idxmv = find(Feeder.summary_feeder_lines.(filename).nominalV < 1 & ...
        Feeder.summary_feeder_lines.(filename).phasecount == 2);
    if isempty(idxmv)
        len_3ph = 0;
    else
        len_3ph = sum(Feeder.summary_feeder_lines.(filename).length(idxmv));
    end
    idxoh = regexp(Feeder.summary_feeder_lines.(filename).linecode,'oh');
    idxoh1=find(~cellfun(@isempty,idxoh));
    idx_oh = intersect(idxoh1,idxmv);
    if isempty(idx_oh)
        len_3ph_oh = 0;
    else
        len_3ph_oh = sum(Feeder.summary_feeder_lines.(filename).length(idx_oh));
    end
    FeederData.Length_lv2ph_miles(i) = len_3ph*dist_mult; %in miles
    FeederData.Length_OH_lv2ph_miles(i) = len_3ph_oh*dist_mult; %in miles
end

% total 1-ph LV-length
for i=1:Feeder.Total_No_Feeders;
    filename = sprintf('%s_%d','FeederNo',i);
    idxmv = find(Feeder.summary_feeder_lines.(filename).nominalV < 1 & ...
        Feeder.summary_feeder_lines.(filename).phasecount == 1);
    if isempty(idxmv)
        len_3ph = 0;
    else
        len_3ph = sum(Feeder.summary_feeder_lines.(filename).length(idxmv));
    end
    idxoh = regexp(Feeder.summary_feeder_lines.(filename).linecode,'oh');
    idxoh1=find(~cellfun(@isempty,idxoh));
    idx_oh = intersect(idxoh1,idxmv);
    if isempty(idx_oh)
        len_3ph_oh = 0;
    else
        len_3ph_oh = sum(Feeder.summary_feeder_lines.(filename).length(idx_oh));
    end
    FeederData.Length_lv1ph_miles(i) = len_3ph*dist_mult + FeederData.Length_lv2ph_miles(i); %in miles % LV 2-ph lines are treated as 1-ph line due to cneter tap
    FeederData.Length_OH_lv1ph_miles(i) = len_3ph_oh*dist_mult + FeederData.Length_OH_lv2ph_miles(i); %in miles
end
%new update mv and lv line length

for il = 1:Feeder.Total_No_Feeders
    total_len = FeederData.Length_1ph_miles(il)+FeederData.Length_2ph_miles(il)+FeederData.Length_3ph_miles(il);
    FeederData.Ratio_1phtototal_length(il,1) = FeederData.Length_1ph_miles(il)/total_len;
    FeederData.Ratio_2phtototal_length(il,1) = FeederData.Length_2ph_miles(il)/total_len;
    FeederData.Ratio_3phtototal_length(il,1) = FeederData.Length_3ph_miles(il)/total_len;
end

tab_string=repmat('No Info',Feeder.Total_No_Feeders,1); %no SCADA info
FeederData.SCADA_Breaker = tab_string;

%Distribution T/F Capacity and no of line regulators
for i=1:Feeder.Total_No_Feeders;
    filename = sprintf('%s_%d','FeederNo',i);
    idx=strcmp(Feeder.summary_feeder_lines.(filename).type,'transformer');
    idx1=find(idx==1);
    No_of_TF = length(idx1);
    idxr=strcmp(Feeder.summary_feeder_lines.(filename).type,'regulator');
    idx1r=find(idxr==1);
    No_of_reg = length(idx1r);
    if isempty(idx1)
    DistCap = 0;  
    else
    DistCap = sum(Feeder.summary_feeder_lines.(filename).cont_rating_amps_or_kVA(idx1));    
    end
    FeederData.Distribution_Tranformer_Total_Capacity_MVA(i) = DistCap/1000;
    FeederData.No_of_Distribution_Transformer(i) = No_of_TF;
    FeederData.No_of_Regulators(i) = No_of_reg;
end

%No of Cap Banks
for i=1:Feeder.Total_No_Feeders;
    filename = sprintf('%s_%d','FeederNo',i);
    idx=strcmp(Feeder.summary_feeder_nodes.(filename).type,'capacitor');
    idx1=find(idx==1);
    No_of_Cap = length(idx1);    
    FeederData.No_of_CapacitorBanks(i) = No_of_Cap;
end
% NO of swithcing devices
for i=1:Feeder.Total_No_Feeders;
        
    idx=regexp(Feeder.summary_feeder_lines.(filename).name,'boos');
    idx1=find(~cellfun(@isempty,idx));
    No_of_inter=length(idx1);
    FeederData.No_of_Boosters(i)=No_of_inter;
    
    idx=regexp(Feeder.summary_feeder_lines.(filename).name,'fuse');
    idx1=find(~cellfun(@isempty,idx));
    No_of_inter=length(idx1);
    FeederData.No_of_Fuses(i)=No_of_inter;
    
    idx=regexp(Feeder.summary_feeder_lines.(filename).name,'recloser');
    idx1=find(~cellfun(@isempty,idx));
    No_of_inter=length(idx1);
    FeederData.No_of_Reclosers(i)=No_of_inter;
    
    idx=regexp(Feeder.summary_feeder_lines.(filename).name,'secci');
    idx1=find(~cellfun(@isempty,idx));
    No_of_inter=length(idx1);
    FeederData.No_of_Sectionalizers(i)=No_of_inter;
    
    idx=regexp(Feeder.summary_feeder_lines.(filename).name,'switch');
    idx1=find(~cellfun(@isempty,idx));
    No_of_inter=length(idx1);
    FeederData.No_of_Switches(i)=No_of_inter;
    
    idx=regexp(Feeder.summary_feeder_lines.(filename).name,'break');
    idx1=find(~cellfun(@isempty,idx));
    No_of_inter=length(idx1);
    FeederData.No_of_Breakers(i)=No_of_inter;
    
    filename = sprintf('%s_%d','FeederNo',i);
    idx=regexp(Feeder.summary_feeder_lines.(filename).name,'interruptor');
    idx1=find(~cellfun(@isempty,idx));
    No_of_inter=length(idx1);
    FeederData.No_of_Interruptors(i)=No_of_inter;
    
    idx=strcmp(Feeder.summary_feeder_lines.(filename).type,'transformer');
    idx1=find(idx==1);
    No_of_TF = length(idx1);
    FeederData.No_of_StepDowns(i)=No_of_TF;
end



%m=input('If loveland utility data type Y, Y/N [Y]:','s')
if m=='Y'
    %%Loveland Start
    Devfile = fullfile(file.ODSS.loc,'Device.dss');
    A = importdata(Devfile);
    A = lower(A);
    xx = length(A);
    %fuses
    Idx=regexp(A,'fuse');    Idx1=find(~cellfun(@isempty,Idx));
    Afuse = A(Idx1);
    %ckt breaker
    Idx=regexp(A,'circuit');
    Idx2=find(~cellfun(@isempty,Idx));
    Acktbrk = A(Idx2);
    %recloser
    Idx=regexp(A,'recloser');
    Idx3=find(~cellfun(@isempty,Idx));
    Arecl = A(Idx3);
    %switches
    Idx4 = [Idx1;Idx2;Idx3];
    Idx5=1:xx;
    Idx5=Idx5.';
    Idx6 = setdiff(Idx5,Idx4);
    Aswit = A(Idx6);

    for ig = 1:Feeder.Total_No_Feeders;
        nfuse = 0;
        ncktbrk = 0;
        nrecl=0;
        nswit = 0;
        filename = sprintf('%s_%d','FeederNo',ig);
        len = length(Feeder.Bus_Sub_Names.(filename));
        for il = 1:len
           Idx=regexp(Afuse,Feeder.Bus_Sub_Names.(filename)(il));
           Idx1=find(~cellfun(@isempty,Idx));
          if isempty(Idx1)
              continue
          else
              nfuse =nfuse + 1;
          end
        end

        for il = 1:len
           Idx=regexp(Acktbrk,Feeder.Bus_Sub_Names.(filename)(il));
           Idx1=find(~cellfun(@isempty,Idx));
          if isempty(Idx1)
              continue
          else
              ncktbrk =ncktbrk + 1;
          end
        end

        for il = 1:len
           Idx=regexp(Arecl,Feeder.Bus_Sub_Names.(filename)(il));
           Idx1=find(~cellfun(@isempty,Idx));
          if isempty(Idx1)
              continue
          else
              nrecl =nrecl + 1;
          end
        end

        for il = 1:len
           Idx=regexp(Aswit,Feeder.Bus_Sub_Names.(filename)(il));
           Idx1=find(~cellfun(@isempty,Idx));
          if isempty(Idx1)
              continue
          else
              nswit =nswit + 1;
          end
        end

FeederData.No_of_Fuses(ig)=nfuse;
FeederData.No_of_Reclosers(ig)=nrecl;
FeederData.No_of_Switches(ig)=nswit; %includes ckt breaker
FeederData.No_of_Breakers(ig)=ncktbrk;
    end
%No of Customers
for i=1:Feeder.Total_No_Feeders;
    filename = sprintf('%s_%d','FeederNo',i);
    idx = strcmp(Feeder.summary_feeder_nodes.(filename).type,'load');
    idx1= find(idx == 1);
    loadname=Feeder.summary_feeder_nodes.(filename).name(idx1);
    lenload=length(loadname);
    NumCusto = 0;
    if lenload == 0
        NumCusto = 0;
    else
        for j=1:lenload;
            idx2 = strcmp(lower(inputsTable.name),loadname(j));
            idx3 = find(idx2 == 1);
            NumCusto = NumCusto + inputsTable.NumCust{idx3};
        end
    end
    FeederData.No_of_Customers(i) = NumCusto;  
end
else
    %number of Customers
%No of Customers
Devfile_cust = fullfile(file.ODSS.loc,'Loads_IntermediateFormat.csv')
A_cust = importdata(Devfile_cust);
A_cust = lower(A_cust);
numloads = length(lower(A_cust.textdata(2:end,1)));
ll = repmat('load.',numloads,1);
load_node = strcat(ll,lower(A_cust.textdata(2:end,1)));
Cust_Data = A_cust.data(:,11);
for i=1:Feeder.Total_No_Feeders;
    filename = sprintf('%s_%d','FeederNo',i);
    idx = strcmp(Feeder.summary_feeder_nodes.(filename).type,'load');
    idx1= find(idx == 1);
    loadname=Feeder.summary_feeder_nodes.(filename).name(idx1);
    lenload=length(loadname);
    [C,ia,ib] = intersect(loadname,load_node);
    if lenload == 0
        NumCusto = 0;
    else
        NumCusto = sum(Cust_Data(ib));
    end
    FeederData.No_of_Customers(i) = NumCusto;
end   
end
 %Loveland End

%Connected Service TF Capacity

% for i=1:Feeder.Total_No_Feeders;
%     filename = sprintf('%s_%d','FeederNo',i);
%     idx=strcmp(Feeder.summary_feeder_lines.(filename).type,'transformer');
%     idx1=find(idx==1);
%     if isempty(idx1)
%     DistCap = 0;  
%     else
%     DistCap = sum(Feeder.summary_feeder_lines.(filename).cont_rating_amps_or_kVA(idx1));    
%     end
%     FeederData.Distribution_Tranformer_Total_Capacity_KVA(i) = DistCap;
% end

%Feeder Peak Load
%%Total Demand
for i=1:Feeder.Total_No_Feeders;
    filename = sprintf('%s_%d','FeederNo',i);
    
    IA = abs(Feeder.summary_feeder_nodes.(filename).current_in_A_real+sqrt(-1)*Feeder.summary_feeder_nodes.(filename).current_in_A_im);
    IB = abs(Feeder.summary_feeder_nodes.(filename).current_in_B_real+sqrt(-1)*Feeder.summary_feeder_nodes.(filename).current_in_B_im);
    IC = abs(Feeder.summary_feeder_nodes.(filename).current_in_C_real+sqrt(-1)*Feeder.summary_feeder_nodes.(filename).current_in_C_im);
    I=sum(IA+IB+IC);
    FeederData.Toal_Demand_Amps(i) = I;
end

FeederData.PeakLoad_Date = tab_string;
FeederData.PeakLoad_Time = tab_string;

No_of_MV_Loops_nearbyHVMV = 0; %Number of MV loops with a nearby HV/MV substation
No_of_MV_Loops_sameHVMV_sameFeeder = 0; %Number of MV loops with the same HV/MV substation, with the same feeder
No_of_MV_Loops_sameHVMV_sameFeeder = 0; %Number of MV loops with the same HV/MV substation, with different feeders

FeederData.CustomerType = tab_string;
FeederData.Total_annual_Energy_Consumption_kWh =tab_string;

%%Total Demand
for i=1:Feeder.Total_No_Feeders;
    filename = sprintf('%s_%d','FeederNo',i);
    PA = sum(Feeder.summary_feeder_nodes.(filename).power_in_A_P);
    PB = sum(Feeder.summary_feeder_nodes.(filename).power_in_B_P);
    PC = sum(Feeder.summary_feeder_nodes.(filename).power_in_C_P);
    Pfull = Feeder.summary_feeder_nodes.(filename).power_in_A_P+Feeder.summary_feeder_nodes.(filename).power_in_B_P+...
            Feeder.summary_feeder_nodes.(filename).power_in_C_P;
    LarDem = max(Pfull);
    P=sum(PA+PB+PC);
    TP = (PA+PB+PC)/3;
    QA = sum(Feeder.summary_feeder_nodes.(filename).power_in_A_Q);
    QB = sum(Feeder.summary_feeder_nodes.(filename).power_in_B_Q);
    QC = sum(Feeder.summary_feeder_nodes.(filename).power_in_C_Q);
    Qfull = Feeder.summary_feeder_nodes.(filename).power_in_A_Q+Feeder.summary_feeder_nodes.(filename).power_in_B_Q+...
            Feeder.summary_feeder_nodes.(filename).power_in_C_Q;
    Q=sum(QA+QB+QC);
    FeederData.Total_Demand_kW(i) = P;
    FeederData.Total_Reactive_Power_kVAr(i) = Q;
    FeederData.MaxDemand_kW(i) = LarDem;
    FeederData.Avg_Typical_Demand_kW(i) = TP;
end

nodetrim = strtok(circuit.Nodes_Dis,'.');
%
Sub_Id = table;
for j = 1:Feeder.Total_No_Feeders
    to_node = Feeder.Feeder_Summary.To_Node(j);
    for i = 1:Feeder.Total_No_Feeders
        filename = sprintf('%s_%d','FeederNo',i);
        idx=strcmp(strtok(Feeder.summary_feeder_lines.(filename).from,'.'),to_node);
        idx1=find(idx == 1);
        if ~isempty(idx1)
            Sub_Id.Feed_No(j,1) = i;
            SubName = Feeder.Feeder_Summary.SubStn_Name(j);
            for k = 1:Feeder.No_of_Substations  
                idx_s=strcmp(Feeder.summary_propbable_substations.name,SubName);
                idx1_s = find(idx_s == 1);
                if ~isempty(idx1_s)
                    Sub_Id.Sub_Node(j,1) = Feeder.summary_propbable_substations.to(idx1_s);
                    break
                end
            end
            break
        end
    end
    idx_d = strcmp(nodetrim,strtok(Sub_Id.Sub_Node(j,1),'.'));
    idx1_d = find(idx_d == 1);
    idx1_d = idx1_d(1);
    Sub_Id.Distance(j,1) = (circuit.Distance(idx1_d));
end
%
for i = 1:Feeder.Total_No_Feeders
    filename = sprintf('%s_%d','FeederNo',i);
    idxdis = find(Sub_Id.Feed_No == i);
    disdiff = Sub_Id.Distance(idxdis(1));
    for j = 1 : length(Feeder.summary_feeder_lines.(filename).from)
    idx=strcmp(nodetrim,strtok(Feeder.summary_feeder_lines.(filename).from(j),'.'));
    idx1=find(idx == 1);
    idx1=idx1(1);
    Feeder.summary_feeder_lines.(filename).distance(j) = (circuit.Distance(idx1))-disdiff;
    end
    for j = 1 : length(Feeder.summary_feeder_nodes.(filename).bus)
    idx=strcmp(nodetrim,strtok(Feeder.summary_feeder_nodes.(filename).bus(j),'.'));
    idx1=find(idx == 1);
    idx1=idx1(1);
    Feeder.summary_feeder_nodes.(filename).distance(j) = (circuit.Distance(idx1))-disdiff;
    end
end
% Additional Metrics
capdist=[];
line_data1=struct;
feeder_name =[];
for ip = 1:Feeder.Total_No_Feeders
   filename = sprintf('%s_%d','FeederNo',ip);
   id_1 = find(Feeder.summary_feeder_lines.(filename).phasecount == 1);
   id_2 = find(Feeder.summary_feeder_lines.(filename).phasecount == 2);
   id_3 = find(Feeder.summary_feeder_lines.(filename).phasecount == 3);
   ph1_Aphase = length(find(Feeder.summary_feeder_lines.(filename).power_in_A_P(id_1) ~= 0));
   ph1_Bphase = length(find(Feeder.summary_feeder_lines.(filename).power_in_B_P(id_1) ~= 0));
   ph1_Cphase = length(find(Feeder.summary_feeder_lines.(filename).power_in_C_P(id_1) ~= 0));
   ph2_ABphase = length(find(Feeder.summary_feeder_lines.(filename).power_in_A_P(id_2) ~= 0 & Feeder.summary_feeder_lines.(filename).power_in_B_P(id_2) ~= 0));
   ph2_ACphase = length(find(Feeder.summary_feeder_lines.(filename).power_in_A_P(id_2) ~= 0 & Feeder.summary_feeder_lines.(filename).power_in_C_P(id_2) ~= 0));
   ph2_BCphase = length(find(Feeder.summary_feeder_lines.(filename).power_in_B_P(id_2) ~= 0 & Feeder.summary_feeder_lines.(filename).power_in_C_P(id_2) ~= 0));
   ph3_ABCphase = length(id_3);
   Total_lin = ph1_Aphase+ph1_Bphase+ph1_Cphase+ph2_ABphase+ph2_ACphase+ph2_BCphase+ph3_ABCphase;
   FeederData.ph_A_lines_percentage(ip,1) = (ph1_Aphase/Total_lin)*100;
   FeederData.ph_AB_lines_percentage(ip,1) = (ph2_ABphase/Total_lin)*100;
   FeederData.ph_AC_lines_percentage(ip,1) = (ph2_ACphase/Total_lin)*100;
   FeederData.ph_BC_lines_percentage(ip,1) = (ph2_BCphase/Total_lin)*100;
   FeederData.ph_ABC_lines_percentage(ip,1) = (ph3_ABCphase/Total_lin)*100;
   
   tf_1a = find(Feeder.summary_feeder_lines.(filename).phasecount == 1);
   tf_1b = strcmp(Feeder.summary_feeder_lines.(filename).type(tf_1a),'transformer');
   tf_1 = length(find(tf_1b == 1));
   tf_3a = find(Feeder.summary_feeder_lines.(filename).phasecount == 3);
   tf_3b = strcmp(Feeder.summary_feeder_lines.(filename).type(tf_3a),'transformer');
   tf_3 = length(find(tf_3b == 1));
   FeederData.Ratio_1phto3ph_Xfrm(ip,1) = tf_1/tf_3;
   
%    icap1 =strcmp(Feeder.summary_feeder_nodes.(filename).type,'capacitor');
%    icap = find(icap1==1);
%    capbus = Feeder.summary_feeder_nodes.(filename).bus(icap);
%    cap_distance =[];
%    for ik = 1:length(icap)
%    icapdis1 = strcmp(strtok(circuit.Nodes_Dis,'.'),capbus(ik));
%    icapdis = (find(icapdis1 == 1));
%    cap_distance(1,ik) = circuit.Distance(icapdis(1))*0.000189394;
%    end
%    capdist=[capdist;cellstr(num2str(cap_distance))];
   
   % change here customer == no of loads with actual customer numbers
   %LV Volatge < 1kV
   ivload1 =strcmp(Feeder.summary_feeder_nodes.(filename).type,'load');
   ivload = find(ivload1==1);
   ilvlo = find(Feeder.summary_feeder_nodes.(filename).nominalV(ivload) < 1 & Feeder.summary_feeder_nodes.(filename).phasecount(ivload) == 1);
   cust_1ph_lv = length(ilvlo);
   ilvlo = find(Feeder.summary_feeder_nodes.(filename).nominalV(ivload) < 1 & Feeder.summary_feeder_nodes.(filename).phasecount(ivload) == 2);
   cust_2ph_lv = length(ilvlo);
   ilvlo = find(Feeder.summary_feeder_nodes.(filename).nominalV(ivload) < 1 & Feeder.summary_feeder_nodes.(filename).phasecount(ivload) == 3);
   cust_3ph_lv = length(ilvlo);
   ilvlo = find(Feeder.summary_feeder_nodes.(filename).nominalV(ivload) < 36 & Feeder.summary_feeder_nodes.(filename).nominalV(ivload) > 1 & Feeder.summary_feeder_nodes.(filename).phasecount(ivload) == 3);
   cust_3ph_mv = length(ilvlo);
   FeederData.No_Loads_LV_1ph(ip,1) = cust_1ph_lv+cust_2ph_lv;
%   FeederData.No_Loads_LV_2ph(ip,1) = cust_2ph_lv;
   FeederData.No_Loads_LV_3ph(ip,1) = cust_3ph_lv;
   FeederData.No_Loads_MV_3ph(ip,1) = cust_3ph_mv;
   FeederData.No_Loads_per_Xfrm(ip,1) = (cust_1ph_lv+cust_2ph_lv+cust_3ph_lv+cust_3ph_mv)/FeederData.No_of_Distribution_Transformer(ip);
   
   
   %length lv vs mv
   ilv1 = strcmp(Feeder.summary_feeder_lines.(filename).type,'line');
   ilv = find(ilv1 == 1);
   aa = Feeder.summary_feeder_lines.(filename).nominalV(ilv);
   bb = Feeder.summary_feeder_lines.(filename).length(ilv);
   ilvlen1 = find(aa < 1);
   FeederData.lv_length_miles(ip,1) = sum(bb(ilvlen1))*dist_mult;
   ilvlen1 = find(aa < 36 & aa > 1);
   FeederData.mv_length_miles(ip,1) = sum(bb(ilvlen1))*dist_mult;
   idx_fut = find(Feeder.summary_feeder_nodes.(filename).phasecount == 3);
   dis_fur = Feeder.summary_feeder_nodes.(filename).distance(idx_fut);
   if isempty(dis_fur)
       FeederData.furtherest_node_miles(ip,1) = 0;
   else
       FeederData.furtherest_node_miles(ip,1) = (max(dis_fur))*0.621371;
   end
 %  FeederData.Avg_Degree(ip,1)=Feeder.Feeder_Agg_Metrics.(filename).ave_deg;
   %FeederData.Degree_Assortivity(ip,1)=Feeder.Feeder_Agg_Metrics.(filename).deg_assort;
  % FeederData.Char_Path_Length(ip,1)=Feeder.Feeder_Agg_Metrics.(filename).char_path_len;
  % FeederData.Graph_Diameter(ip,1)=Feeder.Feeder_Agg_Metrics.(filename).diameter;
   
   FeederData.Avg_Degree(ip,1)=0;
   %FeederData.Degree_Assortivity(ip,1)=Feeder.Feeder_Agg_Metrics.(filename).deg_assort;
   FeederData.Char_Path_Length(ip,1)=0;
   FeederData.Graph_Diameter(ip,1)=0;
   
   %linecodes
  % ilin1 = strcmp(Feeder.summary_feeder_lines.(filename).type,'line');
  % ilin = find(ilin1 == 1);
   ilin = find(Feeder.summary_feeder_lines.(filename).length > 1e-3);
   %line_data = [];
   line_data1.(filename) = Feeder.summary_feeder_lines.(filename).linecode(ilin);
   feeder_name = [feeder_name;FeederData.Feeder_Number(ip)];
   
   %load nodes
%    ie = strcmp(Feeder.summary_feeder_nodes.(filename).type,'load');
%    ie1 = find(ie==1);
%    loadnode.(filename) = strtok(Feeder.summary_feeder_nodes.(filename).bus(ie1),'.');
%    
%    it = strcmp(Feeder.summary_feeder_lines.(filename).type,'transformer');
%    it1 = find(it==1);
%    tfnode.(filename).from = strtok(Feeder.summary_feeder_lines.(filename).from(it1),'.');
%    tfnode.(filename).to = strtok(Feeder.summary_feeder_lines.(filename).to(it1),'.');
%    tflen = length(tfnode.(filename).from);
%    amat=a_matrix;
%    for itf=1:tflen
%        frm1=strcmp(bus_names,tfnode.(filename).from{itf});
%        frm = find(frm1==1);
%        to1=strcmp(bus_names,tfnode.(filename).to{itf});
%        too = find(to1==1);
%        amat(frm,too) = 0;
%        [S1,C1] = tarjan(amat);
%        idx1 = find(C1==2);
%        tf_node = bus_names(idx1);
%        nod = setdiff(tf_node,loadnode.(filename));
%        totloads(itf,1) = length(tf_node)-length(nod);
%    end
   
   
   
end
%FeederData.Cap_Distance_fromsrc_mile = capdist;

Devfile = fullfile(file.ODSS.loc,'LineCodes.dss');
A = importdata(Devfile);
A = lower(A);
D = regexp(A, ' ', 'split');
hk = 1;
%m=input('If loveland utility data type Y, Y/N [Y]:','s')
if m=='Y'
for hi=1:(length(D)/4) %loveland format
    D1(hi,1)=D(hk);
    hk = hk+4;
end
D=D1;
end
D = vertcat(D{:});
lin_cod = [];
[mm nn] = size(D);
for kk = 1:mm
    zz=D{kk,2};
    yy = strsplit(zz,'.');
    yy = yy{1,2};
    lin_cod= [lin_cod;cellstr(yy)];
end
lin_cod = unique(lin_cod);
mkdir(char(CaseFolder_Cr));
cd(fullfile(char(CaseFolder_Cr)))

%linecode excel
for ij = 1:1:Feeder.Total_No_Feeders
    filename = sprintf('%s_%d','FeederNo',ij);
    lena(ij)=length(line_data1.(filename));
end
maxlen = max(lena);
h1 = 'Feeder_Number';
h2    = lin_cod;
% h2(:) = {'line_code'};
h3 = [h1;h2];
cd(fullfile(char(CaseFolder_Cr)))
xlswrite('linecode_feeder_wise',h3,1,'A1')
for ij = 1:1:Feeder.Total_No_Feeders
filename = sprintf('%s_%d','FeederNo',ij);
line_data2=[];
for kk =1:length(lin_cod)
    xy=strcmp(Feeder.summary_feeder_lines.(filename).linecode,lin_cod{kk, 1})
    yx=length(find(xy==1));
    line_data2(kk,1)=yx;    
end
CC=num2cell(line_data2);
CCC=[feeder_name{ij};CC];
column = ij+1;
columnLetters = char(ExcelCol(column));
% Convert to Excel A1 format
cellReference = sprintf('%s1', columnLetters);
xlswrite('linecode_feeder_wise', CCC,1,cellReference)
ij
end

h11 = 'Feeder_Number';
h22    = feeder_name;
h33 = [h11;h22];
xlswrite('capacitor_distance_miles',h33,1,'A1')
h44    = cell(1, 10);
h44(:) = {'distance_miles'};
h55 = [h11 h44];
xlswrite('capacitor_distance_miles',h55,1,'A1')
for ic = 1:Feeder.Total_No_Feeders
%capdistance
    filename = sprintf('%s_%d','FeederNo',ic);
   icap1 =strcmp(Feeder.summary_feeder_nodes.(filename).type,'capacitor');
   icap = find(icap1==1);
   capbus = Feeder.summary_feeder_nodes.(filename).bus(icap);
   cap_distance =[];
   if isempty(capbus)
   %xlswrite('capacitor_distance_miles',cap_distance,1,rc)  
   else
   for ik = 1:length(icap)
       ik
       ic
   icapdis1 = strcmp(strtok(circuit.Nodes_Dis,'.'),strtok(capbus(ik),'.'));
   icapdis = (find(icapdis1 == 1));
   cap_distance = circuit.Distance(icapdis(1))*0.621371;
  % capdist=['distance_miles';cellstr(num2str(cap_distance))];
   columnLetters = char(ExcelCol(ik+1));
   rc=sprintf('%s%d',columnLetters,ic+1);
   xlswrite('capacitor_distance_miles',cap_distance,1,rc);
   end
   end
end

%%added on oct 12th
% for ip = 1:Feeder.Total_No_Feeders  % lv mv A,B,C 1-ph lines perecentage
%    filename = sprintf('%s_%d','FeederNo',ip);
%    id_1mv = find(Feeder.summary_feeder_lines.(filename).phasecount == 1 & Feeder.summary_feeder_lines.(filename).nominalV < 36 & ...
%        Feeder.summary_feeder_lines.(filename).nominalV > 1); %1-ph for mv only in mv 2-phase should not be cosidered as 1-ph
%    id_1lv = find(Feeder.summary_feeder_lines.(filename).phasecount == 1 & ...
%        Feeder.summary_feeder_lines.(filename).nominalV < 1);
%    id_2lv = find(Feeder.summary_feeder_lines.(filename).phasecount == 2 & ...
%        Feeder.summary_feeder_lines.(filename).nominalV < 1);
%    ph1_Aphase_mv = length(find(Feeder.summary_feeder_lines.(filename).power_in_A_P(id_1mv) ~= 0));
%    ph1_Bphase_mv = length(find(Feeder.summary_feeder_lines.(filename).power_in_B_P(id_1mv) ~= 0));
%    ph1_Cphase_mv = length(find(Feeder.summary_feeder_lines.(filename).power_in_C_P(id_1mv) ~= 0));
%    ph1_Aphase_lv = length(find(Feeder.summary_feeder_lines.(filename).power_in_A_P(id_1lv) ~= 0));
%    ph1_Bphase_lv = length(find(Feeder.summary_feeder_lines.(filename).power_in_B_P(id_1lv) ~= 0));
%    ph1_Cphase_lv = length(find(Feeder.summary_feeder_lines.(filename).power_in_C_P(id_1lv) ~= 0));
%    ph2_ABphase_lv = length(find(Feeder.summary_feeder_lines.(filename).power_in_A_P(id_2lv) ~= 0 & Feeder.summary_feeder_lines.(filename).power_in_B_P(id_2lv) ~= 0));
%    ph2_ACphase_lv = length(find(Feeder.summary_feeder_lines.(filename).power_in_A_P(id_2lv) ~= 0 & Feeder.summary_feeder_lines.(filename).power_in_C_P(id_2lv) ~= 0));
%    ph2_BCphase_lv = length(find(Feeder.summary_feeder_lines.(filename).power_in_B_P(id_2lv) ~= 0 & Feeder.summary_feeder_lines.(filename).power_in_C_P(id_2lv) ~= 0));
%    Total_lv_1ph = ph1_Aphase_lv+ph1_Bphase_lv+ph1_Cphase_lv+ph2_ABphase_lv+ph2_BCphase_lv+ph2_ACphase_lv;
%    Total_mv_1ph = ph1_Aphase_mv+ph1_Bphase_mv+ph1_Cphase_mv;
%    FeederData.lv_ph_A_lines_percentage(ip,1) = ((ph1_Aphase_lv+ph2_ABphase_lv)/Total_lv_1ph)*100;
%    FeederData.lv_ph_B_lines_percentage(ip,1) = ((ph1_Bphase_lv+ph2_BCphase_lv)/Total_lv_1ph)*100;
%    FeederData.lv_ph_C_lines_percentage(ip,1) = ((ph1_Cphase_lv+ph2_ACphase_lv)/Total_lv_1ph)*100;
%    FeederData.mv_ph_A_lines_percentage(ip,1) = ((ph1_Aphase_mv)/Total_mv_1ph)*100;
%    FeederData.mv_ph_B_lines_percentage(ip,1) = ((ph1_Bphase_mv)/Total_mv_1ph)*100;
%    FeederData.mv_ph_C_lines_percentage(ip,1) = ((ph1_Cphase_mv)/Total_mv_1ph)*100;
% end

for ip = 1:Feeder.Total_No_Feeders  % lv mv A,B,C 1-ph lines perecentage
   filename = sprintf('%s_%d','FeederNo',ip);
   idx_tf = strcmp(Feeder.summary_feeder_lines.(filename).type,'transformer');
   idx_tf1 = find(idx_tf == 1);
   idx_1lv = find(Feeder.summary_feeder_lines.(filename).phasecount == 1 & ...
       Feeder.summary_feeder_lines.(filename).nominalV < 1);
   idx_1phlvtf = intersect(idx_tf1,idx_1lv);
   From_Node = Feeder.summary_feeder_lines.(filename).from;
   [tf_node tf_phase] = strtok(From_Node,'.');
   tf_phase1 = strtok(tf_phase,'.');
   
   idx_A = strcmp(tf_phase1,'1');
   idx_Aph = find(idx_A == 1);
   Aph = intersect(idx_Aph,idx_1phlvtf);
   power_P_A = sum(Feeder.summary_feeder_lines.(filename).power_in_A_P(Aph));
   
   idx_B = strcmp(tf_phase,'2');
   idx_Bph = find(idx_B == 1);
   Bph = intersect(idx_Bph,idx_1phlvtf);
   power_P_B = sum(Feeder.summary_feeder_lines.(filename).power_in_A_P(Bph));
   
   idx_C = strcmp(tf_phase,'3');
   idx_Cph = find(idx_C == 1);
   Cph = intersect(idx_Cph,idx_1phlvtf);
   power_P_C = sum(Feeder.summary_feeder_lines.(filename).power_in_A_P(Cph));
   
   Total_1ph = power_P_A + power_P_B + power_P_C
   

 %  FeederData.lv_ph_A_loads_percentage(ip,1) = (power_P_A/Total_1ph)*100;
 %  FeederData.lv_ph_B_loads_percentage(ip,1) = (power_P_B/Total_1ph)*100;
 %  FeederData.lv_ph_C_loads_percentage(ip,1) = (power_P_C/Total_1ph)*100;
end

for ip = 1:Feeder.Total_No_Feeders  % lv mv A,B,C 1-ph lines perecentage
   filename = sprintf('%s_%d','FeederNo',ip);
   [a b c]=intersect(strtok(Feeder.summary_feeder_lines.(filename).from,'.'),FeederData.Substation_Name(ip));
   b=b(1);
   power_P_A = sum(Feeder.summary_feeder_lines.(filename).power_in_A_P(b));
   power_P_B = sum(Feeder.summary_feeder_lines.(filename).power_in_B_P(b));
   power_P_C = sum(Feeder.summary_feeder_lines.(filename).power_in_C_P(b));
   
   Total_1ph = power_P_A + power_P_B + power_P_C;
 
   FeederData.lv_ph_A_load_kw_percentage(ip,1) = (power_P_A/Total_1ph)*100;
   FeederData.lv_ph_B_load_kw_percentage(ip,1) = (power_P_B/Total_1ph)*100;
   FeederData.lv_ph_C_load_kw_percentage(ip,1) = (power_P_C/Total_1ph)*100;
end

%type of feeder
for itp = 1:Feeder.Total_No_Feeders
    tpe = strtok(FeederData.Substation_Name(itp),'_');
    if tpe{1} == 'u'
        FeederData.Feeder_Type{itp} = 'Urban';
    elseif tpe{1} == 'i'
        FeederData.Feeder_Type{itp} = 'Industrial';
    elseif tpe{1} == 'r'
        FeederData.Feeder_Type{itp} = 'Rural';
    else
        FeederData.Feeder_Type{itp} = 'No Info';
    end
end

FeederData1 = table;
FeederData1.Feeder_Number	=	FeederData.Feeder_Number	;
FeederData1.Substation_Name	=	FeederData.Substation_Name	;
FeederData1.Feeder_Type	=	FeederData.Feeder_Type	;
FeederData1.Substation_Capacity_MVA	=	FeederData.Substation_Capacity_MVA	;
FeederData1.Substation_Type	=	FeederData.Substation_Type	;
FeederData1.Distribution_Tranformer_Total_Capacity_MVA	=	FeederData.Distribution_Tranformer_Total_Capacity_MVA	;
FeederData1.No_of_Distribution_Transformer	=	FeederData.No_of_Distribution_Transformer	;
FeederData1.No_of_Customers	=	FeederData.No_of_Customers	;
FeederData1.Ratio_1phto3ph_Xfrm	=	FeederData.Ratio_1phto3ph_Xfrm	;
FeederData1.lv_length_miles	=	FeederData.lv_length_miles	;
FeederData1.mv_length_miles	=	FeederData.mv_length_miles	;
FeederData1.furtherest_node_miles	=	FeederData.furtherest_node_miles	;
%FeederData1.Length_3ph_miles	=	FeederData.Length_3ph_miles	;
%FeederData1.Length_OH_3ph_miles	=	FeederData.Length_OH_3ph_miles	;
%FeederData1.Length_2ph_miles	=	FeederData.Length_2ph_miles	;
%FeederData1.Length_OH_2ph_miles	=	FeederData.Length_OH_2ph_miles	;
%FeederData1.Length_1ph_miles	=	FeederData.Length_1ph_miles	;
%FeederData1.Length_OH_1ph_miles	=	FeederData.Length_OH_1ph_miles	;
FeederData1.Length_mv3ph_miles	=	FeederData.Length_mv3ph_miles				;
FeederData1.Length_OH_mv3ph_miles	=	FeederData.Length_OH_mv3ph_miles				;
FeederData1.Length_mv2ph_miles	=	FeederData.Length_mv2ph_miles				;
FeederData1.Length_OH_mv2ph_miles	=	FeederData.Length_OH_mv2ph_miles				;
FeederData1.Length_mv1ph_miles	=	FeederData.Length_mv1ph_miles				;
FeederData1.Length_OH_mv1ph_miles	=	FeederData.Length_OH_mv1ph_miles				;
FeederData1.Length_lv3ph_miles	=	FeederData.Length_lv3ph_miles				;
FeederData1.Length_OH_lv3ph_miles	=	FeederData.Length_OH_lv3ph_miles				;
%FeederData1.Length_lv2ph_miles	=	FeederData.Length_lv2ph_miles				;
%FeederData1.Length_OH_lv2ph_miles	=	FeederData.Length_OH_lv2ph_miles				;
FeederData1.Length_lv1ph_miles	=	FeederData.Length_lv1ph_miles				;
FeederData1.Length_OH_lv1ph_miles	=	FeederData.Length_OH_lv1ph_miles				;
FeederData1.lv_ph_A_load_kw_percentage	=	FeederData.lv_ph_A_load_kw_percentage				;
FeederData1.lv_ph_B_load_kw_percentage	=	FeederData.lv_ph_B_load_kw_percentage				;
FeederData1.lv_ph_C_load_kw_percentage	=	FeederData.lv_ph_C_load_kw_percentage				;
%FeederData1.mv_ph_A_lines_percentage	=	FeederData.mv_ph_A_lines_percentage				;
%FeederData1.mv_ph_B_lines_percentage	=	FeederData.mv_ph_B_lines_percentage				;
%FeederData1.mv_ph_C_lines_percentage	=	FeederData.mv_ph_C_lines_percentage				;
%FeederData1.Ratio_1phtototal_length	=	FeederData.Ratio_1phtototal_length	;
%FeederData1.Ratio_2phtototal_length	=	FeederData.Ratio_2phtototal_length	;
%FeederData1.Ratio_3phtototal_length	=	FeederData.Ratio_3phtototal_length	;
%FeederData1.ph_A_lines_percentage	=	FeederData.ph_A_lines_percentage	;
%FeederData1.ph_AB_lines_percentage	=	FeederData.ph_AB_lines_percentage	;
%FeederData1.ph_AC_lines_percentage	=	FeederData.ph_AC_lines_percentage	;
%FeederData1.ph_BC_lines_percentage	=	FeederData.ph_BC_lines_percentage	;
%FeederData1.ph_ABC_lines_percentage	=	FeederData.ph_ABC_lines_percentage	;
%FeederData1.Toal_Demand_Amps	=	FeederData.Toal_Demand_Amps	;
%FeederData1.PeakLoad_Date	=	FeederData.PeakLoad_Date	;
%FeederData1.PeakLoad_Time	=	FeederData.PeakLoad_Time	;
%FeederData1.CustomerType	=	FeederData.CustomerType	;
%FeederData1.Total_annual_Energy_Consumption_kWh	=	FeederData.Total_annual_Energy_Consumption_kWh	;
FeederData1.Total_Demand_kW	=	FeederData.Total_Demand_kW	;
FeederData1.Total_Reactive_Power_kVAr	=	FeederData.Total_Reactive_Power_kVAr	;
%FeederData1.MaxDemand_kW	=	FeederData.MaxDemand_kW	;
%FeederData1.Avg_Typical_Demand_kW	=	FeederData.Avg_Typical_Demand_kW	;
%FeederData1.Active_Power_Demand_kW	=	FeederData.Active_Power_Demand_kW	;
FeederData1.No_Loads_LV_1ph	=	FeederData.No_Loads_LV_1ph	;
%FeederData1.Customer_LV_2ph	=	FeederData.Customer_LV_2ph	;
FeederData1.No_Loads_LV_3ph	=	FeederData.No_Loads_LV_3ph	;
FeederData1.No_Loads_MV_3ph	=	FeederData.No_Loads_MV_3ph	;
FeederData1.No_Loads_per_Xfrm	=	FeederData.No_Loads_per_Xfrm	;
FeederData1.No_of_Regulators	=	FeederData.No_of_Regulators	;
FeederData1.No_of_CapacitorBanks	=	FeederData.No_of_CapacitorBanks	;
FeederData1.No_of_Boosters	=	FeederData.No_of_Boosters	;
FeederData1.NominalVoltage_HV_kV	=	FeederData.NominalVoltage_HV_kV	;
FeederData1.NominalVoltage_MV_kV	=	FeederData.NominalVoltage_MV_kV	;
FeederData1.NominalVoltage_LV_kV	=	FeederData.NominalVoltage_LV_kV	;
FeederData1.No_of_Fuses	=	FeederData.No_of_Fuses	;
FeederData1.No_of_Reclosers	=	FeederData.No_of_Reclosers	;
FeederData1.No_of_Sectionalizers	=	FeederData.No_of_Sectionalizers	;
FeederData1.No_of_Switches	=	FeederData.No_of_Switches	;
FeederData1.No_of_Breakers	=	FeederData.No_of_Breakers	;
FeederData1.No_of_Interruptors	=	FeederData.No_of_Interruptors	;
FeederData1.Avg_Degree	=	FeederData.Avg_Degree	;
%FeederData1.Degree_Assortivity	=	FeederData.Degree_Assortivity	;
FeederData1.Char_Path_Length	=	FeederData.Char_Path_Length	;
FeederData1.Graph_Diameter	=	FeederData.Graph_Diameter	;


writetable(FeederData1, fullfile(char(CaseFolder_Cr), 'FeederData1.csv'));

variables = {'FeederData'};
for iV = 1:length(variables)
    saveMat = fullfile(saveWorkspace, [variables{iV} '.mat']);
    save(saveMat, variables{iV});
end

disp('Created Feeder Level Metrics'); 