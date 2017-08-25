function [fuse_summary no_of_recl recl_data]=recl_summary_nrel(DSSCircuit)
no_of_recl=DSSCircuit.Reclosers.Count;
recl_data=struct;
DSSXfrm1=DSSCircuit.Reclosers;
start_obj=DSSXfrm1;
start_obj.First;
Xfrm2=struct;
Xfrm3=struct;
for i=1:DSSCircuit.Reclosers.Count
Xfrm2.Line(i).Name=DSSXfrm1.Name;
Xfrm2.Line(i).MonitoredObj=DSSXfrm1.MonitoredObj;
Xfrm2.Line(i).MonitoredObj=DSSXfrm1.MonitoredTerm;
Xfrm2.Line(i).PhaseTrip=DSSXfrm1.PhaseTrip;
Xfrm2.Line(i).Shots=DSSXfrm1.Shots;
start_obj.Next;
end
recl_data=Xfrm2;


%%Fuses
no_of_fuse=DSSCircuit.Fuses.Count;
fuse_data=struct;
DSSXfrm1=DSSCircuit.Fuses;
start_obj=DSSXfrm1;
start_obj.First;
Xfrm2=struct;
for i=1:DSSCircuit.Fuses.Count
Xfrm2.Line(i).Name=DSSXfrm1.Name;
Xfrm2.Line(i).MonitoredObj=DSSXfrm1.MonitoredObj;
Xfrm2.Line(i).MonitoredObj=DSSXfrm1.MonitoredTerm;
Xfrm2.Line(i).Dealy=DSSXfrm1.Delay;
Xfrm2.Line(i).RatedCurrent=DSSXfrm1.RatedCurrent;
start_obj.Next;
end
fuse_data=Xfrm2;

fuse_summary.no_of_fuse=no_of_fuse;
fuse_summary.fuse_data=fuse_data;


end


      
