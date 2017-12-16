addpath('C:\Users\athakall\Desktop\FEEDER_CODES\SMART-DS-master\Network_Characterization\ODSS\functions');
addpath('C:\Users\athakall\Desktop\FEEDER_CODES\SMART-DS-master\Network_Characterization\ODSS\functions\matlab-networks-toolbox-master');
set_up1_MLX;
MainFolder='C:\Users\athakall\Desktop\FEEDER_CODES\Validation_CSV_Files';
CaseFolder=file.caseName;
CaseFolder_Cr = fullfile(MainFolder,file.caseName)

load(fullfile(saveWorkspace, 'FeederData'));

SubLevel = table;
sub_names = unique(FeederData.Substation_Name);
SubLevel.Substation_Name = sub_names;
tab_string=repmat('No Info',length(sub_names),1);

for i = 1 : length(sub_names)
Idx = strcmp(FeederData.Substation_Name,sub_names(i));
Idx1 = find(Idx == 1);
SubLevel.No_of_Feeders(i) = length(Idx1);
SubLevel.Substation_Capacity_MVA(i) = FeederData.Substation_Capacity_MVA(Idx1(1));
SubLevel.Substation_Type = tab_string;
SubLevel.NominalVolatge_HV_kV(i) = max(FeederData.NominalVoltage_HV_kV(Idx1));
SubLevel.NominalVolatge_MV_kV(i) = max(FeederData.NominalVoltage_MV_kV(Idx1));
SubLevel.NominalVolatge_LV_kV(i) = max(FeederData.NominalVoltage_LV_kV(Idx1));
SubLevel.Active_Power_Demand_kW(i) = sum(FeederData.Active_Power_Demand_kW(Idx1));
SubLevel.Length_3ph_miles(i) = sum(FeederData.Length_3ph_miles(Idx1));
SubLevel.Length_OH_3ph_miles(i) = sum(FeederData.Length_OH_3ph_miles(Idx1));
SubLevel.Length_2ph_miles(i) = sum(FeederData.Length_2ph_miles(Idx1));
SubLevel.Length_OH_2ph_miles(i) = sum(FeederData.Length_OH_2ph_miles(Idx1));
SubLevel.Length_1ph_miles(i) = sum(FeederData.Length_1ph_miles(Idx1));
SubLevel.Length_OH_1ph_miles(i) = sum(FeederData.Length_OH_1ph_miles(Idx1));
SubLevel.SCADA_Breaker = tab_string;
SubLevel.Distribution_Transformer_Total_Capacity_MVA(i) = sum(FeederData.Distribution_Tranformer_Total_Capacity_MVA(Idx1));
SubLevel.No_of_Distribution_Transformer(i) = sum(FeederData.No_of_Distribution_Transformer(Idx1));
SubLevel.No_of_Regulators(i) = sum(FeederData.No_of_Regulators(Idx1));
SubLevel.No_of_CapacitorBanks(i) = sum(FeederData.No_of_CapacitorBanks(Idx1));
SubLevel.No_of_Boosters(i) = sum(FeederData.No_of_Boosters(Idx1));
SubLevel.No_of_Fuses(i) = sum(FeederData.No_of_Fuses(Idx1));
SubLevel.No_of_Reclosers(i) = sum(FeederData.No_of_Reclosers(Idx1));
SubLevel.No_of_Sectionalizers(i) = sum(FeederData.No_of_Sectionalizers(Idx1));
SubLevel.No_of_Switches(i) = sum(FeederData.No_of_Switches(Idx1));
SubLevel.No_of_Interruptors(i) = sum(FeederData.No_of_Interruptors(Idx1));
SubLevel.No_of_StepDowns(i) = sum(FeederData.No_of_StepDowns(Idx1));
SubLevel.Total_Demand_Amps(i) = sum(FeederData.Toal_Demand_Amps(Idx1));
SubLevel.PeakLoad_Date = tab_string;
SubLevel.PeakLoad_Time = tab_string;
SubLevel.No_of_Customers(i) = sum(FeederData.No_of_Customers(Idx1));
SubLevel.CustomerType = tab_string;
SubLevel.Total_annual_Energy_Consumption_kWh= tab_string;
SubLevel.Total_Demand_kW(i) = sum(FeederData.Total_Demand_kW(Idx1));
SubLevel.Total_Reactive_Power_kVAr(i) = sum(FeederData.Total_Reactive_Power_kVAr(Idx1));
SubLevel.MaxDemand_kW(i) = sum(FeederData.MaxDemand_kW(Idx1));
SubLevel.Avg_Typical_Demand_kW(i) = sum(FeederData.Avg_Typical_Demand_kW(Idx1));
end

variables = {'SubLevel'};
for iV = 1:length(variables)
    saveMat = fullfile(saveWorkspace, [variables{iV} '.mat']);
    save(saveMat, variables{iV});
end

writetable(SubLevel, fullfile(char(CaseFolder_Cr), 'Substation_Level.csv'));

disp('Created Substation Level Metrics'); 
