function [Xfrm1, Lines1, ug_cable, oh_line, misc, ug_oh_ratio]=lineparameters(DSSCircuit)
DSSLines=DSSCircuit.Lines;
start_obj=DSSLines;
start_obj.First;
Lines1=struct;
for i=1:DSSCircuit.Lines.Count
Lines1.Line(i).Name=DSSLines.Name;
Lines1.Line(i).Bus1=DSSLines.Bus1;
Lines1.Line(i).Bus2=DSSLines.Bus2;
Lines1.Line(i).LineCode=DSSLines.LineCode;
Lines1.Line(i).Length_km=DSSLines.Length;
Lines1.Line(i).Rmatrix_ohmperkm=DSSLines.Rmatrix;
Lines1.Line(i).Xmatrix_ohmperkm=DSSLines.Xmatrix;
Lines1.Line(i).Cmatrix_nFperkm=DSSLines.Cmatrix;
Lines1.Line(i).R1_ohmperkm=DSSLines.R1;
Lines1.Line(i).R0_ohmperkm=DSSLines.R0;
Lines1.Line(i).X1_ohmperkm=DSSLines.X1;
Lines1.Line(i).X0_ohmperkm=DSSLines.X0;
Lines1.Line(i).C1_nFperkm=DSSLines.C1;
Lines1.Line(i).C0_nFperkm=DSSLines.C0;

start_obj.Next;
end



lindata=struct2table(Lines1.Line);
Cap11=cellfun(@(x) x(1), lindata.Cmatrix_nFperkm(1:DSSCircuit.Lines.Count));
idx=find(Cap11 <= 0);
rn=length(idx);
lindata1=table2struct(lindata);
jj=1;
jj1=1;
for k=1:DSSCircuit.Lines.Count
    if any(ismember(k, idx))
        misc(jj1,:)=lindata1(k,:);
        jj1=jj1+1;
    else
       lindata2(jj,:)=lindata1(k,:);
       jj=jj+1;
    end
end
lindata3=struct2table(lindata2);
clear Cap11
if iscell(lindata3.Cmatrix_nFperkm(1:DSSCircuit.Lines.Count-rn,:))
Cap11=cellfun(@(x) x(1), (lindata3.Cmatrix_nFperkm(1:DSSCircuit.Lines.Count-rn,:)));
else
Cap11=lindata3.Cmatrix_nFperkm(1:DSSCircuit.Lines.Count-rn,1);
end
idx1=find(Cap11 > 10);
lindata4=table2struct(lindata3);
kk=1;
mm=1;
no_of_ug=length(idx1);
no_of_oh=DSSCircuit.Lines.Count-rn-no_of_ug;
n_fields=length(fieldnames(lindata4));
fld=fieldnames(lindata4);
for k1=1:DSSCircuit.Lines.Count-rn
    if any(ismember(k1, idx1))
        ug_cable(kk,:)=lindata4(k1,:);
        kk=kk+1;
    else
        oh_line(mm,:)=lindata4(k1,:);
        mm=mm+1;
    end
end
if no_of_ug == 0
    ug_cable=struct();
 
elseif no_of_oh == 0
        oh_line=struct();
end

ug_oh_ratio=no_of_ug/no_of_oh;
if isempty(idx)
misc=struct();
end
%%Transformers
DSSXfrm=DSSCircuit.Transformers;
start_obj=DSSXfrm;
start_obj.First;
Xfrm1=struct;
for i=1:DSSCircuit.Transformers.Count
Xfrm1.Line(i).Name=DSSXfrm.Name;
Xfrm1.Line(i).kV=DSSXfrm.kV;
Xfrm1.Line(i).kva=DSSXfrm.kva;
Xfrm1.Line(i).MaxTap=DSSXfrm.MaxTap;
Xfrm1.Line(i).MinTap=DSSXfrm.MinTap;
Xfrm1.Line(i).NumTaps=DSSXfrm.NumTaps;
Xfrm1.Line(i).NumWindings=DSSXfrm.NumWindings;
Xfrm1.Line(i).R=DSSXfrm.R;
Xfrm1.Line(i).Rneut=DSSXfrm.Rneut;
Xfrm1.Line(i).Tap=DSSXfrm.Tap;
Xfrm1.Line(i).Wdg=DSSXfrm.Wdg;
Xfrm1.Line(i).Xhl=DSSXfrm.Xhl;
Xfrm1.Line(i).Xht=DSSXfrm.Xht;
Xfrm1.Line(i).Xlt=DSSXfrm.Xlt;
Xfrm1.Line(i).Xneut=DSSXfrm.Xneut;
start_obj.Next;
end

LC=struct2table(Lines1.Line);
lenc=length(LC.LineCode);
count_oh = 0;
count_ug = 0;
for ik = 1:lenc
    idx_oh = regexp(LC.LineCode(ik),'oh');
    if idx_oh{1} > 0
        count_oh = count_oh + 1;
    end
    idx_ug = regexp(LC.LineCode(ik),'ug');
    if idx_ug{1} > 0
        count_ug = count_ug + 1;
    end
end
ug_oh_ratio = count_ug/count_oh;


end