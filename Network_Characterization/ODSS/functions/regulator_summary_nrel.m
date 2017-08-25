function [regulator_data]=regulator_summary_nrel(DSSCircuit)
if DSSCircuit.RegControls.Count > 0
types1 = {'RegControls' , 'Transformers'};
clean_types1 = {'regcontrols' , 'transformers'};
circuit_reg = struct;
 count = 1;

    repeat_elements = {};
    last_name = 'empty';
    for iType = 1:length(types1)
        thisType = types1{iType};
        thisCleanType = clean_types1{iType};
        start_obj = DSSCircuit.(thisType);
        start_obj.First;


        n = DSSCircuit.(thisType).Count;
        this_name = [];

        
        for i = 1:n
            
            if strcmp(DSSCircuit.ActiveCktElement.Name, last_name)
                repeat_elements = [repeat_elements {last_name}];
%                 continue;
            end

            if strcmp(thisType, 'Transformers')
                circuit1_reg.element(count-DSSCircuit.('RegControls').Count).Name = DSSCircuit.Transformers.Name;
                circuit1_reg.element(count-DSSCircuit.('RegControls').Count).IsDelta = DSSCircuit.Transformers.IsDelta;
                circuit1_reg.element(count-DSSCircuit.('RegControls').Count).MaxTap = DSSCircuit.Transformers.MaxTap;
                circuit1_reg.element(count-DSSCircuit.('RegControls').Count).MinTap = DSSCircuit.Transformers.MinTap;
                circuit1_reg.element(count-DSSCircuit.('RegControls').Count).NumTaps = DSSCircuit.Transformers.NumTaps;
                circuit1_reg.element(count-DSSCircuit.('RegControls').Count).NumWindings = DSSCircuit.Transformers.NumWindings;
                circuit1_reg.element(count-DSSCircuit.('RegControls').Count).R = DSSCircuit.Transformers.R;
                circuit1_reg.element(count-DSSCircuit.('RegControls').Count).Tap = DSSCircuit.Transformers.Tap;
                circuit1_reg.element(count-DSSCircuit.('RegControls').Count).Wdg = DSSCircuit.Transformers.Wdg;
                circuit1_reg.element(count-DSSCircuit.('RegControls').Count).Xhl = DSSCircuit.Transformers.Xhl;
                circuit1_reg.element(count-DSSCircuit.('RegControls').Count).Xht = DSSCircuit.Transformers.Xht;
                circuit1_reg.element(count-DSSCircuit.('RegControls').Count).Xlt = DSSCircuit.Transformers.Xlt;
                circuit1_reg.element(count-DSSCircuit.('RegControls').Count).Xneut = DSSCircuit.Transformers.Xneut;
                circuit1_reg.element(count-DSSCircuit.('RegControls').Count).kV = DSSCircuit.Transformers.kV;
                circuit1_reg.element(count-DSSCircuit.('RegControls').Count).kva = DSSCircuit.Transformers.kva;
                
            end
            
            if strcmp(thisType, 'RegControls')
                circuit_reg.element(count).Name = DSSCircuit.RegControls.Name;
                circuit_reg.element(count).Transformer = DSSCircuit.RegControls.Transformer;
                circuit_reg.element(count).CTPrimary = DSSCircuit.RegControls.CTPrimary;
                circuit_reg.element(count).MaxTapChange = DSSCircuit.RegControls.MaxTapChange;
                circuit_reg.element(count).MonitoredBus = DSSCircuit.RegControls.MonitoredBus;
                circuit_reg.element(count).PTratio = DSSCircuit.RegControls.PTratio;
                circuit_reg.element(count).TapDelay = DSSCircuit.RegControls.TapDelay;
                circuit_reg.element(count).TapNumber = DSSCircuit.RegControls.TapNumber;
                circuit_reg.element(count).TapWinding = DSSCircuit.RegControls.TapWinding;
                circuit_reg.element(count).VoltageLimit = DSSCircuit.RegControls.VoltageLimit;
                circuit_reg.element(count).Winding = DSSCircuit.RegControls.Winding;
            end
         
            last_name = DSSCircuit.ActiveCktElement.Name;

            start_obj.Next;
            count = count + 1;  
            end
            
    end
    regulator_data=table;
    ckt_tf=struct2table(circuit1_reg.element);
    ckt_reg=struct2table(circuit_reg.element);
    for j=1:DSSCircuit.('Transformers').Count
    for i=1:DSSCircuit.('RegControls').Count
  if cell2mat(strfind(ckt_tf.Name(j) , ckt_reg.Transformer(i)))
   regulator_data.Reg_Cont(i,1)=ckt_reg.Name(i);
   regulator_data.Tf_Name(i,1)=ckt_tf.Name(j);
   regulator_data.CTPri(i,1)=ckt_reg.CTPrimary(i);
   regulator_data.PTRatio(i,1)=ckt_reg.PTratio(i);
   regulator_data.MaxTap(i,1)=ckt_tf.MaxTap(j);
   regulator_data.MinTap(i,1)=ckt_tf.MinTap(j);
   regulator_data.NumTaps(i,1)=ckt_tf.NumTaps(j);
   regulator_data.Tap(i,1)=ckt_tf.Tap(j);
   regulator_data.R(i,1)=ckt_tf.R(j);
   regulator_data.Xhl(i,1)=ckt_tf.Xhl(j);
   regulator_data.Xht(i,1)=ckt_tf.Xht(j);
   regulator_data.Xlt(i,1)=ckt_tf.Xlt(j);
   regulator_data.kV(i,1)=ckt_tf.kV(j);
   regulator_data.kva(i,1)=ckt_tf.kva(j);
    end
    end
    end
    else
   regulator_data=[];
end
end


      
