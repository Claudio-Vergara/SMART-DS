function [summary_nodes_table, summary_lines_table, inputsTable] =...
    summarytable_ODSS(file, circuit, repeat_elements)

%% Convert circuit  to table form
    inputsTable = struct2table(circuit.element);

    %% remove repeats (keep only the first)
    unique_rpt_elements = unique(repeat_elements);
    for i = 1:length(unique_rpt_elements) 
        this_rpt = unique_rpt_elements(i);
        row = find(strcmp(inputsTable.name, this_rpt));
        inputsTable(row(2:end),:) = [];
    end
%% Extract power, voltage, and current measurements for each element
    column_name = 'powers';
    [~, terminalP] = findIndices_3phases_COM(inputsTable, column_name);

    %% voltage table
    column_name = 'voltages';
    [~, terminalV] = findIndices_3phases_COM(inputsTable, column_name);

    %% current table
    column_name = 'currents';
    [ ~, terminalI] = findIndices_3phases_COM(inputsTable, column_name);

    %% ratings
    ratings = inputsTable.normal_rating; %this is in amps
    %replace ratings with kVA for transfomers, ss, and regulators
    
    reg_rows = strcmp(inputsTable.type, 'regulator');
    xfm_rows = strcmp(inputsTable.type, 'transformer');
    ss_rows = strcmp(inputsTable.type, 'substation');
    
    all_xfm_type = find(reg_rows + xfm_rows + ss_rows);
    
    ratings(all_xfm_type) = inputsTable{all_xfm_type, 'kVA'};

    %% find rows of each component 
    names = lower(inputsTable.name); % change to all lower case

%% Identify the subtype of each element 
    original_type = inputsTable.type;
    %% Find subtype
    for i = 1:length(names)
        this_name = names{i};

            %% ID SUBTYPE 
            if regexp(this_name, 'sw')
                inputsTable{i,'type'} = {'switch'};
            elseif regexp(this_name, 'tpx')
                inputsTable{i,'type'} = {'triplex_line'};
            elseif regexp(this_name, 'reg')
                inputsTable{i,'type'} = {'regulator'};
            elseif any(regexp(this_name, 'sub')) && any(regexp(this_name, 'transformer'))
                inputsTable{i,'type'} = {'substation'};
            end
    end

%%  Estimate the nominal voltage (ID one phase to use) of each element
    for iRow = 1:size(inputsTable, 1) 
        this_type = inputsTable{iRow, 'type'};
        
        if strcmp(this_type, 'load') || strcmp(this_type, 'transformer')...
                || strcmp(this_type, 'regulator') || strcmp(this_type, 'substation')
            
            nominalV_array(iRow,1) = inputsTable{iRow, 'kV'};
            
        elseif strcmp(this_type, 'vsource')     
            nominalV_array(iRow,1) = inputsTable{iRow, 'basekV'};
        else %use voltage in because doesn't seem like capacitor has output terminal
%             col = max(find(abs(terminalV.part1_in(iRow,:)) > 0)); %just find one
            col = max(abs(terminalV.part1_in(iRow,:)) > 0); %just find one
            
            if isempty(col) || col == 0
                nominalV_array(iRow,1) = 0;
            else
                nominalV_array(iRow,1) = terminalV.part1_in(iRow,col)/1000; 
            end
        end 
    end
    
%% Losses
    losses_table = table;
    losses_table.names = lower(circuit.all_elements.element_names);
    evens = 2;
    even_array = [];
    
    while 1
        even_array = [even_array evens];
        evens = evens + 2;
        if evens > length(circuit.all_elements.element_losses)
            break;
        end            
    end
    
    odd_array = even_array - 1;
    if max(odd_array) < length(losses_table.names)
        odd_array = [odd_array (max(odd_array)+2)];
    end 
    losses_table.losses_P = circuit.all_elements.element_losses(odd_array)';
    losses_table.losses_Q = circuit.all_elements.element_losses(even_array)';

    % organize in the order of names of the inputs file
    for i = 1:length(names)
        this_name = names(i);
        row = strcmp(losses_table.names, this_name);
        if sum(row) == 0
            continue;
        end 
        losses_P_array(i) = losses_table{row, 'losses_P'};
        losses_Q_array(i) = losses_table{row, 'losses_Q'};
    end 
    
 
%% pull out secondary voltage for transformers and SS
xfm_rows = strcmp(inputsTable.type, 'transformer');
ss_rows = strcmp(inputsTable.type, 'substation');
xfm_type_rows = find(xfm_rows + ss_rows);

secondary_V = zeros(length(nominalV_array), 1);
secondary_V(xfm_type_rows) = nominalV_array(xfm_type_rows);

%%  For each item type, piece together the data for the summary table from the raw data in the circuit table
    fields_cell = {'component', 'name','type', 'bus', 'to','from',...
    'linecode','parent', 'phases'}; %, 'bus_windings1', 'bus_windings2'};


    fields_num = {'phasecount', 'length', 'nominalV', 'nominalV_2nd_xfm', ...
        'cont_rating_amps_or_kVA',...
        'resistence_R', 'reactance_X','susceptance_B', 'power_in_A_P',...
        'power_in_A_Q','power_in_B_P','power_in_B_Q','power_in_C_P',...
        'power_in_C_Q','current_in_A_real', 'current_in_A_im',...
        'current_in_B_real','current_in_B_im', 'current_in_C_real',...
        'current_in_C_im', 'voltage_in_A_mag', 'voltage_in_A_deg'...
        'voltage_in_B_mag', 'voltage_in_B_deg', 'voltage_in_C_mag'...
        'voltage_in_C_deg', 'x', 'y', 'measured_real_power', 'measured_reactive_power'};

%% Some info for buses
    name_bus = circuit.buses.names;
    x_bus = circuit.buses.x;
    y_bus = circuit.buses.y;
    meanV_bus = circuit.buses.mean_V_node;
    
    len_buses = length(name_bus);

    %% generate a 0 matrix for each type (to keep things in order)
    %cell arrays
    for iField = 1:length(fields_cell)
        field = fields_cell{iField};
%         num_components = length(names);
        num_components = length(names)+len_buses;
        newcell = cell(num_components, 1);
        newcell(:) = {'empty'};
        summ_struct.(field) = newcell;
    end

    %doubles
    for iField = 1:length(fields_num)
        field = fields_num{iField};
%         num_components = length(names);
        num_components = length(names)+len_buses;
        summ_struct.(field) = zeros(num_components, 1);
    end
    
    zeros_bus = zeros(len_buses, 1);
    zeros_orig_components = zeros(length(names), 1);
    
    cell_bus = cell(len_buses, 1);
    cell_bus(:) = {'node'}; %this is really a bus, but to maintain terminology
    cell_bus_zeros = cell(len_buses, 1);
%     cell_bus_zeros(:) =  {'0'};
    cell_bus_empty = cell(len_buses, 1);
    cell_bus_empty(:) = {'empty'};
    
    %% convert current from magnitude and degrees to real and imaginary
    i_im_A = terminalI.part1_in(:,1).*sin(terminalI.part2_in(:,1));
    i_re_A = terminalI.part1_in(:,1).*cos(terminalI.part2_in(:,1));
    i_im_B = terminalI.part1_in(:,2).*sin(terminalI.part2_in(:,2));
    i_re_B = terminalI.part1_in(:,2).*cos(terminalI.part2_in(:,2));
    i_im_C = terminalI.part1_in(:,3).*sin(terminalI.part2_in(:,3));
    i_re_C = terminalI.part1_in(:,3).*cos(terminalI.part2_in(:,3));    
    
    %% Create summary structure
    summ_struct.component = [original_type; cell_bus];
%     summ_struct.name = names;    
    summ_struct.name = [names; name_bus];
    summ_struct.type = [inputsTable.type; cell_bus]; 
    
    summ_struct.power_in_A_P = [terminalP.part1_in(:,1); zeros_bus];
    summ_struct.power_in_A_Q = [terminalP.part2_in(:,1); zeros_bus];
    summ_struct.power_in_B_P = [terminalP.part1_in(:,2); zeros_bus];
    summ_struct.power_in_B_Q = [terminalP.part2_in(:,2); zeros_bus];
    summ_struct.power_in_C_P = [terminalP.part1_in(:,3); zeros_bus];
    summ_struct.power_in_C_Q = [terminalP.part2_in(:,3); zeros_bus];
    summ_struct.current_in_A_real = [i_re_A; zeros_bus];
    summ_struct.current_in_A_im = [i_im_A; zeros_bus];
    summ_struct.current_in_B_real = [i_re_B; zeros_bus];
    summ_struct.current_in_B_im = [i_im_B; zeros_bus];
    summ_struct.current_in_C_real = [i_re_C; zeros_bus];
    summ_struct.current_in_C_im = [i_im_C; zeros_bus];    
    summ_struct.voltage_in_A_mag = [terminalV.part1_in(:,1); zeros_bus];
    summ_struct.voltage_in_A_deg = [terminalV.part2_in(:,1); zeros_bus];
    summ_struct.voltage_in_B_mag = [terminalV.part1_in(:,2); zeros_bus];
    summ_struct.voltage_in_B_deg = [terminalV.part2_in(:,2); zeros_bus];
    summ_struct.voltage_in_C_mag = [terminalV.part1_in(:,3); zeros_bus];
    summ_struct.voltage_in_C_deg = [terminalV.part2_in(:,3); zeros_bus];
    summ_struct.x = [zeros_orig_components; circuit.buses.x];
    summ_struct.y = [zeros_orig_components; circuit.buses.y];
    

    
    summ_struct.losses_re = [losses_P_array'; zeros_bus];
    summ_struct.losses_im = [losses_Q_array'; zeros_bus];
    
    
    
    summ_struct.phasecount = [inputsTable.phases; zeros_bus];
    summ_struct.nominalV = [nominalV_array; meanV_bus]; %find their voltage level (MV vs. LV)    
    summ_struct.nominalV_2nd_xfm = [secondary_V; zeros_bus];
    %     summ_struct.nominalV = nominalV_array; %find their voltage level (MV vs. LV)
    summ_struct.cont_rating_amps_or_kVA = [ratings; zeros_bus];
    summ_struct.from = [inputsTable.bus1; cell_bus_empty];
    summ_struct.to = [inputsTable.bus2; cell_bus_empty];
    summ_struct.linecode = [inputsTable.linecode; cell_bus_empty];
    summ_struct.length = [inputsTable.length; zeros_bus];
    summ_struct.resistence_R = [inputsTable.R0; cell_bus_zeros];
    summ_struct.reactance_X = [inputsTable.X0; zeros_bus];
    
    %% for xfms, replace to and from with buses col in inputsTable
    xfm_rows = find(strcmp(original_type, 'transformer'));
    
    for i=1:length(xfm_rows)
        this_row = xfm_rows(i);
        buses = inputsTable{this_row, 'buses'}{1,1};
        summ_struct.from(this_row) = buses(1);
        summ_struct.to(this_row) = buses(2);
    end 
        
    %% for load types, ID the bus the load is on
    load_rows = find(strcmp(original_type, 'load'));
    
    for i = 1:length(load_rows)
        this_row = load_rows(i);
        buses = inputsTable{this_row, 'buses'}{1,1};
        summ_struct.bus(this_row) = buses;
    end 
    

    %% for capacitor types, ID the bus
    cap_rows = find(strcmp(original_type, 'capacitor'));
    for i=1:length(cap_rows)
        this_row = cap_rows(i);
        buses = inputsTable{this_row, 'buses'}{1,1};
        summ_struct.bus(this_row) = buses(1);
    end 
    
    summary_table = struct2table(summ_struct);
       
    
%% Seperate the data into one table for node types and one table for line types
    %% line type: lines, transformers, fuse
    l1 = strcmp(original_type, 'line');
    l2 = strcmp(original_type, 'transformer');
    l3 = strcmp(original_type, 'fuse');

    line_rows = find((l1 + l2 + l3)>0);
    line_table = summary_table(line_rows,:);
    
    
    summary_lines_table = line_table;
    %% node type: loads, capacitor
    n1 = strcmp([original_type; cell_bus], 'load');
    n2 = strcmp([original_type; cell_bus], 'capacitor');
    n3 = strcmp([original_type; cell_bus], 'node');

    node_rows = find((n1 + n2 + n3)>0);
    node_table = summary_table(node_rows,:);
    
    summary_nodes_table = node_table;
    
end      