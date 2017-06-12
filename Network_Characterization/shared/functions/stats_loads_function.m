function [ stats_loads, opsLoad, load_all] = stats_loads_function(file, summary_nodes_table)
% stats_loads_function
% Description: takes data from the summary nodes table and calculates
% additional metrics specific to lines. 

% Arguments:
% file: holds the paths and settings for this case
% summary_nodes_table: Relevant data pulled from input and output files...
% for node type components (loads, capacitors). 
% This refers to the preliminary summary_lines_table

% Outputs:
% stats_loads: descriptive stats of the lines
% opsLoad: operational measures of the lines 
% load_all: the additional calculated descriptive and operational stats...
% combined into one structure
%% ID row for each node type 
    components = summary_nodes_table{:, 'component'};
%% For each component in summary nodes table
    phases = {'A', 'B', 'C'};
    for iRow = 1:length(components)
        for iPhase = 1:3 % for each phase
            phase = phases{iPhase};
            type = components{iRow};
%% Apparent Power
            p_name_re = ['power_in_' phase '_P'];
            p_name_im = ['power_in_' phase '_Q'];
            loadName = summary_nodes_table{iRow,'name'}{1,1};
            loadBus = summary_nodes_table{iRow, 'bus'}{1,1};
            load_Q = summary_nodes_table{iRow, p_name_re};
            load_P = summary_nodes_table{iRow, p_name_im};
            
            %summary for each load
            load_S = sqrt(load_Q.^2.+load_P.^2); %for each phase on each load
            load_S_record(iPhase) = load_S;
            
            %save to data structure
            opsLoad.(type)(iRow).name = loadName;
            opsLoad.(type)(iRow).bus = loadBus;
            opsLoad.(type)(iRow).(['S_phase_' phase]) = load_S;
            
            %aggregated table
            load_all(iRow).name = loadName;
            load_all(iRow).bus = loadBus;
            load_all(iRow).(['S_phase_' phase]) = load_S;
            

        end 
%% Phase Count         
        opsLoad.(type)(iRow).S_total = sum(load_S_record(:));
        load_all(iRow).S_total = sum(load_S_record(:));
        
        if regexp(type, 'triplex')
            stats_loads.(type)(iRow).name = loadName;
            stats_loads.(type)(iRow).phasecount = sum(load_S_record ~= 0);
            load_all(iRow).phasecount = sum(load_S_record ~= 0);
        else
            if file.data_type == 1
                numPhase = length(summary_nodes_table{iRow,'phases'}{1,1})-1;
                stats_loads.(type)(iRow).name = loadName;
                stats_loads.(type)(iRow).phasecount = numPhase;
                load_all(iRow).phasecount = numPhase;
                
            else %if file.data_type == 2 (ODSS)
                numPhase = summary_nodes_table{iRow,'phasecount'};
                stats_loads.(type)(iRow).name = loadName;
                stats_loads.(type)(iRow).phasecount = numPhase;
                load_all(iRow).phasecount = numPhase;
                
            end 
        end 

%% mean V
        sumV = 0;
        magV_array = [];
        for iPhase = 1:3
            phase = phases{iPhase};
            v_field = ['voltage_in_' phase '_mag'];
            v_field_mag = summary_nodes_table{iRow, v_field};
            opsLoad.(type)(iRow).(['Vmag_phase_' phase]) = v_field_mag;
            load_all(iRow).(['Vmag_phase_' phase]) = v_field_mag;
            
            sumV = sumV + v_field_mag;
            magV_array = [magV_array; v_field_mag];
        end 

        meanV = sumV/numPhase; %total S for each load
        opsLoad.(type)(iRow).meanV = meanV;
        load_all(iRow).meanV = meanV;
    
%% Loads: Imbalance
        % ID index of non zero phases (to neglect the phases not in use)
        % and set the deviation in those indices to 0
        indexP_unused = find(magV_array == 0);
        devV = abs(magV_array - ones((length(magV_array)),1)*meanV);
        devV(indexP_unused) = 0;
        maxDev = max(devV);

        opsLoad.(type)(iRow).maxDev_V = maxDev;

        load_all(iRow).imbalance = maxDev/meanV;
        load_all(iRow).maxDev_V = maxDev;

    end
    
   
end 
        

