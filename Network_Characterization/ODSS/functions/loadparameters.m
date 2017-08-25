function [Loads1, Ratio_Y_D_Load, Total_No_Customers]=loadparameters(DSSCircuit)
DSSLoads=DSSCircuit.Loads;
start_obj=DSSLoads;
start_obj.First;
Loads1=struct;
TotalDelta_Load=0;
Total_No_Customers=0;
if DSSCircuit.Loads.Count==0
    Total_Loads=0;
    Total_Y_loads=0;
    Ratio_Y_D_Load=0;
else    
    for i=1:DSSCircuit.Loads.Count
    Loads1.Load(i).Name=DSSLoads.Name;
    Loads1.Load(i).kV=DSSLoads.kV;
    Loads1.Load(i).Delta=DSSLoads.IsDelta;
    Loads1.Load(i).Model=DSSLoads.Model;
    Loads1.Load(i).NumCust=DSSLoads.NumCust;
    Loads1.Load(i).PF=DSSLoads.PF;
    Loads1.Load(i).kW=DSSLoads.kW;
    Loads1.Load(i).kva=DSSLoads.kva;
    Loads1.Load(i).kvar=DSSLoads.kvar;
    Loads1.Load(i).NumCust=DSSLoads.NumCust;
    Total_No_Customers=Total_No_Customers+DSSLoads.NumCust;
        if DSSLoads.IsDelta;
            TotalDelta_Load=TotalDelta_Load+1;
        end
        start_obj.Next;
    end
Total_Loads=DSSCircuit.Loads.Count;
Total_Y_loads=Total_Loads-TotalDelta_Load;
Ratio_Y_D_Load=Total_Y_loads/TotalDelta_Load;
Loads=struct2table(Loads1.Load);

Idx_line=find(Loads.kV < 75.9 & Loads.kV > 2.16);
summary_MV_Load=Loads(Idx_line,:);
No_of_MV_Cust=sum(summary_MV_Load.NumCust);
No_of_MV_Loads=length(summary_MV_Load.Name);

Idx_line=find(Loads.kV < 0.66);
summary_LV_Load=Loads(Idx_line,:);
No_of_LV_Cust=sum(summary_LV_Load.NumCust);
No_of_LV_Loads=length(summary_LV_Load.Name);

Idx_line=find(Loads.kV > 110);
summary_HV_Load=Loads(Idx_line,:);
No_of_HV_Cust=sum(summary_HV_Load.NumCust);
No_of_HV_Loads=length(summary_HV_Load.Name);

Loads1.No_of_MV_Cust=No_of_MV_Cust;
Loads1.No_of_HV_Cust=No_of_HV_Cust;
Loads1.No_of_LV_Cust=No_of_LV_Cust;
Loads1.No_of_MV_Loads=No_of_MV_Loads;
Loads1.No_of_HV_Loads=No_of_HV_Loads;
Loads1.No_of_LV_Loads=No_of_LV_Loads;
Loads1.Summary_of_LV_Loads=summary_LV_Load;
Loads1.Summary_of_MV_Loads=summary_MV_Load;
Loads1.Summary_of_HV_Loads=summary_HV_Load;
end
%%Capacitors
DSSXfrm=DSSCircuit.Capacitors;
start_obj=DSSXfrm;
start_obj.First;
Xfrm1=struct;
for i=1:DSSCircuit.Capacitors.Count
Xfrm1.Line(i).Name=DSSXfrm.Name;
Xfrm1.Line(i).kV=DSSXfrm.kV;
Xfrm1.Line(i).kvar=DSSXfrm.kvar;
Xfrm1.Line(i).IsDelta=DSSXfrm.IsDelta;
start_obj.Next;
end

Loads1.No_of_Capacitors=DSSCircuit.Capacitors.Count;
Loads1.Capacitor_Summary=Xfrm1;

%% Capcontrols
DSSXfrm1=DSSCircuit.CapControls;
start_obj=DSSXfrm1;
start_obj.First;
Xfrm2=struct;
for i=1:DSSCircuit.CapControls.Count
Xfrm2.Line(i).Name=DSSXfrm1.Name;
Xfrm2.Line(i).Capacitor=DSSXfrm1.Capacitor;
Xfrm2.Line(i).Delay=DSSXfrm1.Delay;
Xfrm2.Line(i).CTratio=DSSXfrm1.CTratio;
Xfrm2.Line(i).PTratio=DSSXfrm1.PTratio;
Xfrm2.Line(i).Vmax=DSSXfrm1.Vmax;
Xfrm2.Line(i).Vmin=DSSXfrm1.Vmin;
Xfrm2.Line(i).Mode=DSSXfrm1.Mode;
Xfrm2.Line(i).MonitoredObj=DSSXfrm1.MonitoredObj;
Xfrm2.Line(i).MonitoredTerm=DSSXfrm1.MonitoredTerm;
Xfrm2.Line(i).OFFSetting=DSSXfrm1.OFFSetting;
Xfrm2.Line(i).ONSetting=DSSXfrm1.ONSetting;
start_obj.Next;
end

Loads1.Capacitor_controls_Summary=Xfrm2;
clear Xfrm2
%% Regcontrols
DSSXfrm1=DSSCircuit.RegControls;
start_obj=DSSXfrm1;
start_obj.First;
Xfrm2=struct;
Xfrm3=struct;
for i=1:DSSCircuit.RegControls.Count
Xfrm2.Line(i).Name=DSSXfrm1.Name;
Xfrm2.Line(i).Transformer=DSSXfrm1.Transformer;
Xfrm2.Line(i).Delay=DSSXfrm1.Delay;
%Xfrm2.Line(i).CTratio=DSSXfrm1.CTratio;
Xfrm2.Line(i).PTratio=DSSXfrm1.PTratio;
Xfrm2.Line(i).MaxTapChange=DSSXfrm1.MaxTapChange;
Xfrm2.Line(i).MonitoredBus=DSSXfrm1.MonitoredBus;
Xfrm2.Line(i).TapWinding=DSSXfrm1.TapWinding;
Xfrm2.Line(i).VoltageLimit=DSSXfrm1.VoltageLimit;
Xfrm2.Line(i).Winding=DSSXfrm1.Winding;
Xfrm3.Line(i).TapNumber=DSSXfrm1.TapNumber;
start_obj.Next;
end
Loads1.Reg_operational_Summary=Xfrm3;
Loads1.Reg_controls_Summary=Xfrm2;
end