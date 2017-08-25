addpath('C:\Users\athakall\Desktop\FEEDER_CODES\SMART-DS-master\Network_Characterization\ODSS\functions');
addpath('C:\Users\athakall\Desktop\FEEDER_CODES\SMART-DS-master\Network_Characterization\ODSS\functions\matlab-networks-toolbox-master');
set_up1_MLX;
MainFolder='C:\Users\athakall\Desktop\FEEDER_CODES\Validation_CSV_Files';
CaseFolder=file.caseName;
CaseFolder_Cr = fullfile(MainFolder,file.caseName)

load(fullfile(saveWorkspace, 'Feeder'));
load(fullfile(saveWorkspace, 'inputsTable'));
FeederData = table;
FeederData.Feeder_Number = Feeder.Feeder_Summary.To_Node;
FeederData.Substation_Name = Feeder.Feeder_Summary.From_Node;
for i=1:Feeder.Total_No_Feeders;
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
    if isempty(idx)
        len_3ph = 0;
    else
        len_3ph = sum(Feeder.summary_feeder_lines.(filename).length(idx));
    end
    if isempty(idx2)
        len_3ph_oh = 0;
    else
        len_3ph_oh = sum(Feeder.summary_feeder_lines.(filename).length(idx2));
    end
    FeederData.Length_3ph_miles(i) = len_3ph*0.000189394; %in miles
    FeederData.Length_OH_3ph_miles(i) = len_3ph_oh*0.000189394; %in miles
end

% total 2-ph length
for i=1:Feeder.Total_No_Feeders;
    filename = sprintf('%s_%d','FeederNo',i);
    idx = find(Feeder.summary_feeder_lines.(filename).phasecount == 2);
    idx1 = regexp(Feeder.summary_feeder_lines.(filename).linecode(idx),'oh');
    idx2=find(~cellfun(@isempty,idx1));
    if isempty(idx)
        len_2ph = 0;
    else
        len_2ph = sum(Feeder.summary_feeder_lines.(filename).length(idx));
    end
    if isempty(idx2)
        len_2ph_oh = 0;
    else
        len_2ph_oh = sum(Feeder.summary_feeder_lines.(filename).length(idx2));
    end
    FeederData.Length_2ph_miles(i) = len_2ph*0.000189394; %in miles
    FeederData.Length_OH_2ph_miles(i) = len_2ph_oh*0.000189394; %in miles
end

% total 1-ph length
for i=1:Feeder.Total_No_Feeders;
    filename = sprintf('%s_%d','FeederNo',i);
    idx = find(Feeder.summary_feeder_lines.(filename).phasecount == 1);
    idx1 = regexp(Feeder.summary_feeder_lines.(filename).linecode(idx),'oh');
    idx2=find(~cellfun(@isempty,idx1));
    if isempty(idx)
        len_1ph = 0;
    else
        len_1ph = sum(Feeder.summary_feeder_lines.(filename).length(idx));
    end
    if isempty(idx2)
        len_1ph_oh = 0;
    else
        len_1ph_oh = sum(Feeder.summary_feeder_lines.(filename).length(idx2));
    end
    FeederData.Length_1ph_miles(i) = len_1ph*0.000189394; %in miles
    FeederData.Length_OH_1ph_miles(i) = len_1ph_oh*0.000189394; %in miles
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
    
    idx=regexp(Feeder.summary_feeder_lines.(filename).name,'recl');
    idx1=find(~cellfun(@isempty,idx));
    No_of_inter=length(idx1);
    FeederData.No_of_Reclosers(i)=No_of_inter;
    
    idx=regexp(Feeder.summary_feeder_lines.(filename).name,'secci');
    idx1=find(~cellfun(@isempty,idx));
    No_of_inter=length(idx1);
    FeederData.No_of_Sectionalizers(i)=No_of_inter;
    
    idx=regexp(Feeder.summary_feeder_lines.(filename).name,'switc');
    idx1=find(~cellfun(@isempty,idx));
    No_of_inter=length(idx1);
    FeederData.No_of_Switches(i)=No_of_inter;
    
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


m=input('If loveland utility data type Y, Y/N [Y]:','s')
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
FeederData.No_of_Switches(ig)=nswit+ncktbrk; %includes ckt breaker

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

writetable(FeederData, fullfile(char(CaseFolder_Cr), 'FeederData.csv'));