%set_up1_MLX;

[DSSStartOK, DSSObj, DSSText] = DSSStartup;


if DSSStartOK
    compile_message = ['Compile "' file.ODSS_inputs];
    DSSText.Command = compile_message;
    % Set up the interface variables
    DSSCircuit=DSSObj.ActiveCircuit;
    DSSSolution=DSSCircuit.Solution;
    
    % Add an EnergyMeter object so the distances down the feeder are
    % computed
   DSSText.Command='New EnergyMeter.Main Line.CInterruptor(CRamaEE():ST_MAT->nST3_69)__18538';    

    
    % Limit regulator tap changes to 1 tap per change to better
    % approximate the published results
%     DSSText.Command='RegControl.creg1a.maxtapchange=1  Delay=15  !Allow only one tap change per solution. This one moves first';
%     DSSText.Command='RegControl.creg2a.maxtapchange=1  Delay=30  !Allow only one tap change per solution';
%     DSSText.Command='RegControl.creg3a.maxtapchange=1  Delay=30  !Allow only one tap change per solution';
%     DSSText.Command='RegControl.creg4a.maxtapchange=1  Delay=30  !Allow only one tap change per solution';
%     DSSText.Command='RegControl.creg3c.maxtapchange=1  Delay=30  !Allow only one tap change per solution';
%     DSSText.Command='RegControl.creg4b.maxtapchange=1  Delay=30  !Allow only one tap change per solution';
%     DSSText.Command='RegControl.creg4c.maxtapchange=1  Delay=30  !Allow only one tap change per solution';

    DSSText.Command='Set MaxControlIter=30';

    % Solve executes the solution for the present solution mode, which is "snapshot" and 
    % establishes the bus list.

    DSSSolution.Solve;
    
    % Now load in the bus coordinates so we can execute a circuit plot if
    % we want to
    DSSText.Command='Buscoords BusCoord.dss   ! load in bus coordinates';
    
 
   

    % Get bus voltage magnitudes in pu and distances from energy meter and
    % plot in a scatter plot
    
    % Get Voltage and Distances Array
    V1 = DSSCircuit.AllNodeVmagPUByPhase(1);
    Dist1 = DSSCircuit.AllNodeDistancesByPhase(1);
    V2 = DSSCircuit.AllNodeVmagPUByPhase(2);
    Dist2 = DSSCircuit.AllNodeDistancesByPhase(2);
    V3 = DSSCircuit.AllNodeVmagPUByPhase(3);
    Dist3 = DSSCircuit.AllNodeDistancesByPhase(3);

    % Make Plot
    
    plot(Dist1, V1,'k*');  % black *
    hold on;
    plot(Dist2, V2, 'r+');  % red +
    plot(Dist3, V3, 'bd');  % diamond Marker
    legend('phase A','phase B','phase C','Location','SouthEast'); %put the legend
    title('Voltage Profile Plot'); %plot title
        
    ylim([0.95 1.05]);
    ylabel('Volts(pu)');
    xlabel('Distance from Substation');
    
    hold off
    
    delete(DSSObj);
    
else
    a='DSS Did Not Start'
    disp(a)
end
Voltage.V1 = V1;
Voltage.V2 = V2;
Voltage.V3 = V3;
Voltage.Dist1 = Dist1;
Voltage.Dist2 = Dist2;
Voltage.Dist3 = Dist3;

%% Voltage Drop
Voltage.Voltage_Drop_Phase_A = (V1-V1(1)).';
Voltage.Voltage_Drop_Phase_B = (V2-V2(1)).';
Voltage.Voltage_Drop_Phase_C = (V3-V3(1)).';

variables = {'Voltage'};
for iV = 1:length(variables)
    saveMat = fullfile(saveWorkspace, [variables{iV} '.mat']);
    save(saveMat, variables{iV});
end
disp('Created Voltage Table');

%% Voltage Drop
Voltage.Voltage_Drop_Phase_A = V1-V1(1)
