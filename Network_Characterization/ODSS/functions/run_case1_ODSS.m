function [circuit, repeat_elements] = run_case1_ODSS(file)

%% Start up the Solver
compile_message = ['Compile "' file.ODSS_inputs];
DSSObj = actxserver('OpenDSSEngine.DSS');


    if ~DSSObj.Start(0)
        disp('Unable to start the OpenDSS Engine')
    return
    end
    % Set up the Text, Circuit, and Solution Interfaces
    DSSText = DSSObj.Text;
    DSSCircuit = DSSObj.ActiveCircuit;
    DSSSolution = DSSCircuit.Solution;

    % Load in an example circuit
    DSSText.Command = compile_message;

    if DSSSolution.Converged
        disp('The Circuit Solved Successfully')
    end

    
    
%% Retrieiving useful values: 
%% Extract circuit level data from the DSSCircuit object
    circuit = struct;
    circuit.total_loss = DSSCircuit.Losses;
    circuit.all_elements.element_losses = DSSCircuit.allElementLosses;
    circuit.all_elements.element_names = DSSCircuit.allElementNames;
    circuit.buses.names = DSSCircuit.allBusNames;
    circuit.buses.AllNodeNames = DSSCircuit.AllNodeNames;
    circuit.buses.bus_Vmag = DSSCircuit.allBusVmag'/1000;
    
    bus_names = [circuit.buses.names];
    
    for i = 1:length(circuit.buses.names)
        this_bus = bus_names(i);
        DSSCircuit.SetActiveBus(this_bus{1,1});
        active_bus_name{i} = DSSCircuit.ActiveBus.Name;
        active_bus_kVBase{i} = DSSCircuit.ActiveBus.kVBase;
        active_bus_x(i) = DSSCircuit.ActiveBus.x;
        active_bus_y(i) = DSSCircuit.ActiveBus.y; 
    end
    
    circuit.buses.x = active_bus_x';
    circuit.buses.y = active_bus_y';

%% Clean buses:
%% Remove the part of the bus name that specifies the nodes (removes everything that comes after the period)
    clean_node_names = strtok(circuit.buses.AllNodeNames, '.');
%     unique_node_names = unique(clean_node_names);
   
    
    for i = 1:length(bus_names)
        this_name = bus_names(i);
        i_rows = find(strcmp(clean_node_names, this_name));
        mean_V_node(i) = mean(circuit.buses.bus_Vmag(i_rows));
    end 
    
    circuit.buses.mean_V_node = mean_V_node';

%% Gather per component data from active circuit:
%% For each element type, cycle through all objects of that type and extract the necessary information
    types = {'Lines', 'Loads', 'Capacitors', 'Transformers',...
        'Fuses', 'Generators', 'Vsources'};
    clean_types = {'line', 'load', 'capacitor', 'transformer',...
        'fuse', 'generator', 'vsource'};
    count = 1;
    repeat_elements = {};
    last_name = 'empty';
    for iType = 1:length(types)
        thisType = types{iType};
        thisCleanType = clean_types{iType};
        start_obj = DSSCircuit.(thisType);
        start_obj.First;


        n = DSSCircuit.(thisType).Count;
        this_name = [];

        
        for i = 1:n
            
            if strcmp(DSSCircuit.ActiveCktElement.Name, last_name)
                repeat_elements = [repeat_elements {last_name}];
%                 continue;
            end
            circuit.element(count).name = DSSCircuit.ActiveCktElement.Name;
            circuit.element(count).type = thisCleanType;
            circuit.element(count).powers = DSSCircuit.ActiveElement.Powers;
            circuit.element(count).phases = DSSCircuit.ActiveElement.NumPhases;
            circuit.element(count).n_conductors = DSSCircuit.ActiveElement.NumConductors;
            circuit.element(count).n_terminals = DSSCircuit.ActiveElement.NumTerminals;
            circuit.element(count).currents = DSSCircuit.ActiveElement.Currents;
            circuit.element(count).voltages = DSSCircuit.ActiveElement.VoltagesMagAng;
            circuit.element(count).normal_rating = DSSCircuit.ActiveElement.NormalAmps; %in amps
            circuit.element(count).is_enabled = DSSCircuit.ActiveElement.Enabled;
            circuit.element(count).buses = DSSCircuit.ActiveCktElement.BusNames;
%             circuit.element(count).active_bus_name = DSSCircuit.ActiveBus.Name;
%             circuit.element(count).active_bus_basekv = DSSCircuit.ActiveBus.kVBase;

            if strcmp(thisType, 'Lines')
                circuit.element(count).length = DSSCircuit.Lines.Length;
                circuit.element(count).X0 = DSSCircuit.Lines.X0;
                circuit.element(count).X1 = DSSCircuit.Lines.X1;
                circuit.element(count).R0 = DSSCircuit.Lines.R0;
                circuit.element(count).R1 = DSSCircuit.Lines.R1;            
                circuit.element(count).bus1 = DSSCircuit.Lines.Bus1;
                circuit.element(count).bus2 = DSSCircuit.Lines.Bus2;
                circuit.element(count).linecode = DSSCircuit.Lines.LineCode;
                
                %%TESTING
%                 circuit.element(count).parent = DSSCircuit.Lines.Parent;
                DSSObj.AllowForms=false;
                get(DSSCircuit.Lines, 'Parent');
                if DSSObj.Error.Number %check if error in parent
                    errorString = DSSObj.Error.Description;
                    className = regexp(errorString,'.^?Class=(\w+).^?','Tokens');
                    objectName = regexp(errorString,'.^?name=(\w+)','Tokens');
                    circuit.element(count).parent = [className{1}{1},'.',objectName{1}{1}];
                else
%                     circuit.element(count).parent = get(DSSCircuit.Lines, 'Name');
                    circuit.element(count).parent = DSSCircuit.Lines.Parent;

                end

                %% END TESTING
                circuit.element(count).total_cust = DSSCircuit.Lines.TotalCust;
                circuit.element(count).n_customers = DSSCircuit.Lines.NumCust;
            else 
                circuit.element(count).length = 0;
                circuit.element(count).X0 = 0;
                circuit.element(count).X1 = 0;
                circuit.element(count).bus1 = 'empty';
                circuit.element(count).bus2 = 'empty';
                circuit.element(count).linecode = 'empty';
                circuit.element(count).parent = 'empty';
                circuit.element(count).n_customers = 0;
            end

            if strcmp(thisType, 'Loads')
                circuit.element(count).kV = DSSCircuit.Loads.kV;
                circuit.element(count).kW = DSSCircuit.Loads.kW;
                circuit.element(count).kVAr = DSSCircuit.Loads.kvar;
                circuit.element(count).kVA = DSSCircuit.Loads.kva;
                circuit.element(count).kWh = DSSCircuit.Loads.kwh;
            else 
                circuit.element(count).kV = 0;
                circuit.element(count).kW = 0;
                circuit.element(count).kVAr = 0;
                circuit.element(count).kVA = 0;
                circuit.element(count).kWh = 0;
            end 

            if strcmp(thisType, 'Transformers')
               circuit.element(count).kV = DSSCircuit.Transformers.kV;
               circuit.element(count).kVA = DSSCircuit.Transformer.kva;
               circuit.element(count).xfm_code = DSSCircuit.Transformer.XfmrCode;
               circuit.element(count).winding = DSSCircuit.Transformer.Wdg;
            end 

            if strcmp(thisType, 'Generators')
                circuit.element(count).kV = DSSCircuit.Loads.kV;
                circuit.element(count).kW = DSSCircuit.Loads.kW;
                circuit.element(count).kVAr = DSSCircuit.Loads.kvar;
%                 circuit.element(count).kVA_rated = DSSCircuit.Loads.kVArated;
            end

            if strcmp(thisType, 'Vsources')
                circuit.element(count).basekV = DSSCircuit.Vsources.BasekV;
            else
                circuit.element(count).basekV = 0;
            end 
            
            last_name = DSSCircuit.ActiveCktElement.Name;

            start_obj.Next;
            count = count + 1;
        end

    end

%% close and delete server object
delete(DSSObj)
end 