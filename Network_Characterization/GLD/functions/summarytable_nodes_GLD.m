function [summary_nodes_table_GLD] = summarytable_nodes_GLD(outputsTable)

    %% FIRST: READ IN COMPONENTS AND CLEAN STRINGS
    %% Pull Data into Arrays (columns of table)
    %combine both types

    %can we ignore meters for now
    node_types = {'node','load','capacitor','meter','triplex_node'...
        'triplex_meter','triplex_load'};

    all_types = [node_types];

    gen_str_fields = {'name','parent','to','from','phases','bustype','load_class'};
    gen_num_fields = {'length', 'emergency_rating'};

    %% fields for nodes
    % doesn't see like node types include voltage as an output
    % different fields are used in the xml output for different objects,
    % however, within each category, only one in each category should be
    % applicable for each object type
    
%     V_fields= {'voltage_A','voltage_B','voltage_C','voltage_1','voltage_2',...
%         'voltage_N','nominal_voltage','continuous_rating', 'measured_voltage_A',...
%         'measured_voltage_B', 'measured_voltage_C'};
    V_fields = {'voltage_A','voltage_B','voltage_C',...
        'voltage_N','nominal_voltage','continuous_rating', 'measured_voltage_A',...
        'measured_voltage_B', 'measured_voltage_C'};
    V_fields_triplex = {'voltage_1','voltage_2'};    
%     P_fields = {'power_A','power_B','power_C', 'constant_power_A',...
%         'constant_power_B', 'constant_power_C', 'power_1', 'power_2',...
%         'measured_reactive_power', 'measured_real_power'}; %testing these last two 
    
    P_fields = {'power_A','power_B','power_C', 'constant_power_A',...
        'constant_power_B', 'constant_power_C'}; %testing these last two 
    P_fields_triplex = {'power_1', 'power_2'}; %testing these last two 
    P_fields_meter = {'measured_reactive_power', 'measured_real_power'}; %testing these last two     
%     i_fields= {'current_A','current_B','current_C', 'current_1', 'current_2'};
    i_fields = {'current_A','current_B','current_C'};
    i_fields_triplex = {'current_1', 'current_2'};


    %% Start Pulling Data from the XML data structure
    rowNum = 1;
    gen_fields = struct;

    for iType = 1:length(all_types) %for each component type
        type = all_types{iType};
        
        if isempty(outputsTable.(type))
            continue;
        end 
        sheet = struct2table(outputsTable.(type)); %keep as a data stucture so can iterate through it

        for iNum = 2:size(sheet,2) %for each component of type
             gen_fields(rowNum).type = type;

             %% General fields
             for iField = 1:length(gen_str_fields)
                 field = gen_str_fields{iField};
                 fieldHeaders = sheet{:,1};
                 row_index = find(cellfun(@(x)strcmp(x,{field}), fieldHeaders));
                 if isempty(row_index)
                    gen_fields(rowNum).(field) = {'empty'}; 
                    continue;
                 end

                 thisStr = sheet{row_index,iNum}{1,1};             
                 gen_fields(rowNum).(field) = thisStr;

             end 

             %% Numerical gen fields
             for iField = 1:length(gen_num_fields)
                 field = gen_num_fields{iField};
                 fieldHeaders = sheet{:,1};
                 row_index = find(cellfun(@(x)strcmp(x,{field}), fieldHeaders));
                 if isempty(row_index)
                     gen_fields(rowNum).(field) = 0;

                    continue;
                 end

                 thisStr = sheet{row_index,iNum}{1,1};
                 [value, units] = strtok(cleanStr,' ');


                 gen_fields(rowNum).(field) = str2double(value);

             end 
             %% Voltage fields: non-triplex
             for iField = 1:length(V_fields)  %for each field
                field = V_fields{iField};
                fieldHeaders = sheet{:,1}; 
                row_index = find(cellfun(@(x)strcmp(x,{field}), fieldHeaders));
                voltage_fields(rowNum).type = gen_fields(rowNum).type;
                voltage_fields(rowNum).name = gen_fields(rowNum).name;

                if isempty(row_index)
                    voltage_fields(rowNum).([field '_mag']) = 0; %iNum refers to rows now
                    voltage_fields(rowNum).([field '_deg']) = 0;                
                    continue;
                end            

                thisStr = sheet{row_index,iNum}{1,1};
                [cleanStr] = cleanstrings(thisStr); %call function to clean strings

                [Vmag, leftover] = strtok(cleanStr,' ');
                [Vdeg, leftover] = strtok(leftover, 'd');


                voltage_fields(rowNum).([field '_mag']) = str2double(Vmag); %iNum refers to rows now
                voltage_fields(rowNum).([field '_deg']) = str2double(Vdeg);

             end
             %% Voltage fields: Triplex
             for iField = 1:length(V_fields_triplex)  %for each field
                field = V_fields_triplex{iField};
                fieldHeaders = sheet{:,1}; 
                row_index = find(cellfun(@(x)strcmp(x,{field}), fieldHeaders));
                voltage_fields_triplex(rowNum).type = gen_fields(rowNum).type;
                voltage_fields_triplex(rowNum).name = gen_fields(rowNum).name;

%                 voltage_fields_triplex(rowNum).([field '_A_mag']) = 0; %iNum refers to rows now
%                 voltage_fields_triplex(rowNum).([field '_A_deg']) = 0; 
%                 voltage_fields_triplex(rowNum).([field '_B_mag']) = 0; %iNum refers to rows now
%                 voltage_fields_triplex(rowNum).([field '_B_deg']) = 0; 
%                 voltage_fields_triplex(rowNum).([field '_C_mag']) = 0; %iNum refers to rows now
%                 voltage_fields_triplex(rowNum).([field '_C_deg']) = 0; 
                    
                if isempty(row_index)              
                    continue;
                end            

                thisStr = sheet{row_index,iNum}{1,1};
                [cleanStr] = cleanstrings(thisStr); %call function to clean strings

                [Vmag, leftover] = strtok(cleanStr,' ');
                [Vdeg, leftover] = strtok(leftover, 'd');
                
                %ID the phase
%                 phase_index = (cellfun(@(x)strcmp(x,{'phases'}),fieldHeaders));
%                 this_phase = sheet{phase_index, iNum}{1,1};
%                 this_phase(regexp(this_phase, '[sS]')) = [];

                if isempty(i_real) || isempty(i_imag)
                    continue;
                else
                    voltage_fields_triplex(rowNum).([field '_mag']) = str2double(Vmag); %iNum refers to rows now
                    voltage_fields_triplex(rowNum).([field '_deg']) = str2double(Vdeg);                    
%                     voltage_fields_triplex(rowNum).([field '_' this_phase '_mag']) = str2double(Vmag); %iNum refers to rows now
%                     voltage_fields_triplex(rowNum).([field '_' this_phase '_deg']) = str2double(Vdeg);
                end 
             end

            %% Estimate nominal V for loads, use nominal V for rest
             if strcmp(type,'load')
                 row_V = [voltage_fields(rowNum).measured_voltage_A_mag,...
                     voltage_fields(rowNum).measured_voltage_B_mag,...
                     voltage_fields(rowNum).measured_voltage_C_mag];

%                  anyV = row_V(row_V > 0);
                 voltage_fields(rowNum).measured_nomV = max(row_V);
             else 
                 voltage_fields(rowNum).measured_nomV =...
                     voltage_fields(rowNum).nominal_voltage_mag;
             end

             %% power fields
%              for iField = 1:length(P_fields)
% 
%                 field = P_fields{iField};
%                 fieldHeaders = sheet{:,1}; 
%                 row_index = find(cellfun(@(x)strcmp(x,{field}), fieldHeaders));
%                 power_fields(rowNum).type = gen_fields(rowNum).type;
%                 power_fields(rowNum).name = gen_fields(rowNum).name;  
% 
%                 if isempty(row_index)
%                     power_fields(rowNum).([field '_P']) = 0; %iNum refers to rows now
%                     power_fields(rowNum).([field '_Q']) = 0;
%                     continue;
%                 end                
%                 thisStr = sheet{row_index,iNum}{1,1};
%                 [cleanStr] = cleanstrings(thisStr);
% 
%                 [P, leftover] = strtok(cleanStr,' ');
%                 [Q, leftover2] = strtok(leftover, 'i');
%                 if isnan(str2double(Q))
%                     [Q, leftover2] = strtok(leftover, 'j');
%                 end
% 
%                 power_fields(rowNum).([field '_P']) = str2double(P); %iNum refers to rows now
%                 power_fields(rowNum).([field '_Q']) = str2double(Q);
%                 
%              end

            %% power fields - nodes and loads: measured power at nodes and loads
             for iField = 1:length(P_fields)

                field = P_fields{iField};
                fieldHeaders = sheet{:,1}; 
                row_index = find(cellfun(@(x)strcmp(x,{field}), fieldHeaders));
                power_fields(rowNum).type = gen_fields(rowNum).type;
                power_fields(rowNum).name = gen_fields(rowNum).name;  

                if isempty(row_index)
                    power_fields(rowNum).([field '_P']) = 0; %iNum refers to rows now
                    power_fields(rowNum).([field '_Q']) = 0;
                    continue;
                end                
                thisStr = sheet{row_index,iNum}{1,1};
                [cleanStr] = cleanstrings(thisStr);

                [P, leftover] = strtok(cleanStr,' ');
                [Q, leftover2] = strtok(leftover, 'i');
                if isnan(str2double(Q))
                    [Q, leftover2] = strtok(leftover, 'j');
                end

                power_fields(rowNum).([field '_P']) = str2double(P); %iNum refers to rows now
                power_fields(rowNum).([field '_Q']) = str2double(Q);
                
             end
             
             %% power fields - triplex nodes: measured power at triplex nodes
             
             for iField = 1:length(P_fields_triplex)

                field = P_fields_triplex{iField};
                fieldHeaders = sheet{:,1}; 
                row_index = find(cellfun(@(x)strcmp(x,{field}), fieldHeaders));
                power_fields_triplex(rowNum).type = gen_fields(rowNum).type;
                power_fields_triplex(rowNum).name = gen_fields(rowNum).name;  
%                 power_fields_triplex(rowNum).([field '_A' '_P']) = 0; %iNum refers to rows now
%                 power_fields_triplex(rowNum).([field '_A' '_Q']) = 0;
%                 power_fields_triplex(rowNum).([field '_B' '_P']) = 0; %iNum refers to rows now
%                 power_fields_triplex(rowNum).([field '_B' '_Q']) = 0;
%                 power_fields_triplex(rowNum).([field '_C' '_P']) = 0; %iNum refers to rows now
%                 power_fields_triplex(rowNum).([field '_C' '_Q']) = 0;
                
                if isempty(row_index)
                    continue;
                end                
                thisStr = sheet{row_index,iNum}{1,1};
                [cleanStr] = cleanstrings(thisStr);

                [P, leftover] = strtok(cleanStr,' ');
                [Q, leftover2] = strtok(leftover, 'i');
                if isnan(str2double(Q))
                    [Q, leftover2] = strtok(leftover, 'j');
                end
                
%                 %ID the phase
%                 phase_index = (cellfun(@(x)strcmp(x,{'phases'}),fieldHeaders));
%                 this_phase = sheet{phase_index, iNum}{1,1};
%                 this_phase(regexp(this_phase, '[sS]')) = [];
                
                if isempty(P) || isempty(Q)
                    continue;
                else 
                    power_fields_triplex(rowNum).([field '_P']) = str2double(P); %iNum refers to rows now
                    power_fields_triplex(rowNum).([field '_Q']) = str2double(Q);                   
%                     power_fields_triplex(rowNum).([field '_' this_phase '_P']) = str2double(P); %iNum refers to rows now
%                     power_fields_triplex(rowNum).([field '_' this_phase '_Q']) = str2double(Q);
                end 
             end
             
              %% power fields - meters
             
             for iField = 1:length(P_fields_meter)

                field = P_fields_meter{iField};
                fieldHeaders = sheet{:,1}; 
                row_index = find(cellfun(@(x)strcmp(x,{field}), fieldHeaders));
                power_fields_meters(rowNum).type = gen_fields(rowNum).type;
                power_fields_meters(rowNum).name = gen_fields(rowNum).name;  

                if isempty(row_index)
                    power_fields_meters(rowNum).(field) = 0; %iNum refers to rows now
                    continue;
                end                
                thisStr = sheet{row_index,iNum}{1,1};
                thisStr(regexp(thisStr, '[VArW+-]')) = [];

                power_fields_meters(rowNum).(field) = str2double(thisStr); %iNum refers to rows now
                
             end 
             %% current fields
             %non-triplex objects
             for iField = 1:length(i_fields)
                field = i_fields{iField};
                fieldHeaders = sheet{:,1}; 
                row_index = find(cellfun(@(x)strcmp(x,{field}), fieldHeaders));
                current_fields(rowNum).type = gen_fields(rowNum).type;
                current_fields(rowNum).name = gen_fields(rowNum).name;

                if isempty(row_index)
                    current_fields(rowNum).([field '_real']) = 0; %iNum refers to rows now
                    current_fields(rowNum).([field '_im']) = 0;                
                    continue;
                end                
                thisStr = sheet{row_index,iNum}{1,1};
                [cleanStr] = cleanstrings(thisStr);

                cleanStr(regexp(cleanStr, '[ijAa+-]')) = [];
                [i_real, i_imag] = strtok(cleanStr,' ');
                
                current_fields(rowNum).([field '_real']) = str2double(i_real); %iNum refers to rows now
                current_fields(rowNum).([field '_im']) = str2double(i_imag);
             end
            
            %triplex node objects (current for split phase is listed only
            %as in phase 1 or 2 in the outputs. For each triplex line,
            %the actual phases are extracted from the xml outputs (is
            %listed as AS, BS, etc). Current in phase 1 is assumed to be 
            %the current in A/B/C, while the current in phase 2 is assumed
            %to be the one in the S (neutral) and is ignored... 
            for iField = 1:length(i_fields_triplex)
                field = i_fields_triplex{iField};
                fieldHeaders = sheet{:,1}; 
                row_index = find(cellfun(@(x)strcmp(x,{field}), fieldHeaders));
                current_fields_triplex(rowNum).type = gen_fields(rowNum).type;
                current_fields_triplex(rowNum).name = gen_fields(rowNum).name;
                
                
                
%                 current_fields_triplex(rowNum).([field '_A_real']) = 0; %iNum refers to rows now
%                 current_fields_triplex(rowNum).([field '_A_im']) = 0; 
%                 current_fields_triplex(rowNum).([field '_B_real']) = 0; %iNum refers to rows now
%                 current_fields_triplex(rowNum).([field '_B_im']) = 0; 
%                 current_fields_triplex(rowNum).([field '_C_real']) = 0; %iNum refers to rows now
%                 current_fields_triplex(rowNum).([field '_C_im']) = 0;                 
%                 
                
                if isempty(row_index)                
                    continue;
                end                
                thisStr = sheet{row_index,iNum}{1,1};
                [cleanStr] = cleanstrings(thisStr);


                cleanStr(regexp(cleanStr, '[ijAa+-]')) = [];
                [i_real, i_imag] = strtok(cleanStr,' ');
%                 %ID the phase
%                 phase_index = (cellfun(@(x)strcmp(x,{'phases'}),fieldHeaders));
%                 this_phase = sheet{phase_index, iNum}{1,1};
%                 this_phase(regexp(this_phase, '[sS]')) = [];
                
                if isempty(i_real) || isempty(i_imag)
                    continue;
                else
                    current_fields_triplex(rowNum).([field '_real']) = str2double(i_real);
                    current_fields_triplex(rowNum).([field '_im']) = str2double(i_imag);
                    
%                     current_fields_triplex(rowNum).([field '_' this_phase '_real']) = str2double(i_real); %iNum refers to rows now
%                     current_fields_triplex(rowNum).([field '_' this_phase '_im']) = str2double(i_imag);
                end 
             end 

            summary_lines(rowNum).suseptance_B = 0; %B;
            summary_lines(rowNum).resistance_R = 0;
            summary_lines(rowNum).reactance_X = 0;

            rowNum = rowNum+1;
        end 
    end


    %% ID the rows that are line type vs. node type
    node_types = {'node','load','meter','capacitor'};
    triplex_node_types = {'triplex_node','triplex_load', 'triplex_meter'};
    table_type = {'node_types', 'triplex_node_types'};


    triplex_node_rows = [];
    component_names = {gen_fields.type};

    total_i_row = zeros(1,length(component_names));

    for iType = 1:length(triplex_node_types)
        type = triplex_node_types{iType};
        component_names = {gen_fields.type};
        i_rows = strcmp(component_names, type);
        new_tri_rows = find(i_rows);
        total_i_row = total_i_row + i_rows;
        triplex_node_rows = [triplex_node_rows new_tri_rows];  
    end

    node_rows = find(~total_i_row);
    triplex_node_rows = unique(triplex_node_rows);

    rows_by_type = zeros(2, max(length(node_rows), length(triplex_node_rows)));
    rows_by_type(1,1:length(node_rows)) = node_rows;
    rows_by_type(2,length(node_rows)+1:length(node_rows)+length(triplex_node_rows)) = triplex_node_rows;



    %% generate a 0 matrix for each type (to keep things in order) 
    fields_cell = {'component','name', 'type', 'bus', 'to', 'from',...
        'linecode','parent','phases'}; %, 'bus_winding1', 'bus_winding2'};
    fields_num = {'phasecount', 'length', 'nominalV', 'nominalV_2nd_xfm', ...
        'cont_rating_amps_or_kVA',...
        'resistence_R', 'reactance_X','susceptance_B', 'power_in_A_P',...
        'power_in_A_Q','power_in_B_P','power_in_B_Q','power_in_C_P',...
        'power_in_C_Q','current_in_A_real', 'current_in_A_im',...
        'current_in_B_real','current_in_B_im', 'current_in_C_real',...
        'current_in_C_im', 'voltage_in_A_mag', 'voltage_in_A_deg'...
        'voltage_in_B_mag', 'voltage_in_B_deg', 'voltage_in_C_mag'...
        'voltage_in_C_deg', 'x', 'y', 'measured_real_power', 'measured_reactive_power'}; 


    %% Start pulling together the matrix 

    %% for nodes
    tableName = table_type{1};

    %cell arrays
    for iField = 1:length(fields_cell)
        field = fields_cell{iField};
    %         num_components = size(index_listType,2);
        num_components = size(component_names,2);

        newcell = cell(1, num_components)';
        newcell(:) = {'empty'};
        summ_struct.(tableName).(field) = newcell;
    end
    %doubles
    for iField = 1:length(fields_num)
        field = fields_num{iField};
        num_components = size(component_names,2);
        summ_struct.(tableName).(field) = zeros(1, num_components)';
    end


    for iType = 1:2 %type 1= nodes, type2 = triplex nodes

        index_listType = rows_by_type(iType,rows_by_type(iType,:) > 0);

        summ_struct.(tableName).component(index_listType) = component_names(index_listType)';
        summ_struct.(tableName).name(index_listType) = {gen_fields(index_listType).name}';
        summ_struct.(tableName).type(index_listType) = {gen_fields(index_listType).type}';
        summ_struct.(tableName).parent(index_listType) = {gen_fields(index_listType).parent}';
        summ_struct.(tableName).to(index_listType) = [gen_fields(index_listType).to]';
        summ_struct.(tableName).from(index_listType) = [gen_fields(index_listType).from]';
        summ_struct.(tableName).length(index_listType) = [gen_fields(index_listType).length]';

        summ_struct.(tableName).resistence_R(index_listType) = [summary_lines(index_listType).resistance_R]';
        summ_struct.(tableName).reactance_X(index_listType) = [summary_lines(index_listType).reactance_X]';
        summ_struct.(tableName).susceptance_B(index_listType) = [summary_lines(index_listType).suseptance_B]';

        if iType == 1
            summ_struct.(tableName).power_in_A_P(index_listType) = [power_fields(index_listType).power_A_P]'/1000;
            summ_struct.(tableName).power_in_A_Q(index_listType) = [power_fields(index_listType).power_A_Q]'/1000;
            summ_struct.(tableName).power_in_B_P(index_listType) = [power_fields(index_listType).power_B_P]'/1000;
            summ_struct.(tableName).power_in_B_Q(index_listType) = [power_fields(index_listType).power_B_Q]'/1000;
            summ_struct.(tableName).power_in_C_P(index_listType) = [power_fields(index_listType).power_C_P]'/1000;
            summ_struct.(tableName).power_in_C_Q(index_listType) = [power_fields(index_listType).power_C_Q]'/1000;

            summ_struct.(tableName).current_in_A_real(index_listType) = [current_fields(index_listType).current_A_real]';
            summ_struct.(tableName).current_in_A_im(index_listType) = [current_fields(index_listType).current_A_im]';
            summ_struct.(tableName).current_in_B_real(index_listType) = [current_fields(index_listType).current_B_real]';
            summ_struct.(tableName).current_in_B_im(index_listType) = [current_fields(index_listType).current_B_im]';
            summ_struct.(tableName).current_in_C_real(index_listType) = [current_fields(index_listType).current_C_real]';
            summ_struct.(tableName).current_in_C_im(index_listType) = [current_fields(index_listType).current_C_im]';

            summ_struct.(tableName).voltage_in_A_mag(index_listType) = [voltage_fields(index_listType).voltage_A_mag]'/1000;
            summ_struct.(tableName).voltage_in_A_deg(index_listType) = [voltage_fields(index_listType).voltage_A_deg]'/1000;
            summ_struct.(tableName).voltage_in_B_mag(index_listType) = [voltage_fields(index_listType).voltage_B_mag]'/1000;
            summ_struct.(tableName).voltage_in_B_deg(index_listType) = [voltage_fields(index_listType).voltage_B_deg]'/1000;
            summ_struct.(tableName).voltage_in_C_mag(index_listType) = [voltage_fields(index_listType).voltage_C_mag]'/1000;
            summ_struct.(tableName).voltage_in_C_deg(index_listType) = [voltage_fields(index_listType).voltage_C_deg]'/1000;
            
            summ_struct.(tableName).nominalV(index_listType) = [voltage_fields(index_listType).measured_nomV]'/1000;
        
        end 

        summ_struct.(tableName).cont_rating_amps_or_kVA(index_listType) = [voltage_fields(index_listType).continuous_rating_mag]'/1000;
        summ_struct.(tableName).phases(index_listType) = {gen_fields(index_listType).phases}';
        summ_struct.(tableName).measured_real_power(index_listType) = [power_fields_meters(index_listType).measured_real_power]'/1000;
        summ_struct.(tableName).measured_reactive_power(index_listType) = [power_fields_meters(index_listType).measured_reactive_power]'/1000;
        
        %% triplex nodes - should only over-write the index_types of triplex nodes
        % note: A = 1 and B = 2 (phases)
        if iType == 2
            summ_struct.(tableName).power_in_A_P(index_listType) = [power_fields_triplex(index_listType).power_1_P]'/1000;
            summ_struct.(tableName).power_in_A_Q(index_listType) = [power_fields_triplex(index_listType).power_1_Q]'/1000;
            summ_struct.(tableName).power_in_B_P(index_listType) = [power_fields_triplex(index_listType).power_2_P]'/1000;
            summ_struct.(tableName).power_in_B_Q(index_listType) = [power_fields_triplex(index_listType).power_2_Q]'/1000;
%             summ_struct.(tableName).power_in_C_P(index_listType) = [power_fields_triplex(index_listType).power_1_C_P]'/1000;
%             summ_struct.(tableName).power_in_C_Q(index_listType) = [power_fields_triplex(index_listType).power_1_C_Q]'/1000;
            
%             summ_struct.(tableName).power_in_A_P(index_listType) = [power_fields(index_listType).power_1_P]'/1000;
%             summ_struct.(tableName).power_in_A_Q(index_listType) = [power_fields(index_listType).power_1_Q]'/1000;
%             summ_struct.(tableName).power_in_B_P(index_listType) = [power_fields(index_listType).power_2_P]'/1000;
%             summ_struct.(tableName).power_in_B_Q(index_listType) = [power_fields(index_listType).power_2_Q]'/1000;
%             summ_struct.(tableName).current_in_A_real(index_listType) = [current_fields(index_listType).current_1_real]';
%             summ_struct.(tableName).current_in_A_im(index_listType) = [current_fields(index_listType).current_1_im]';
%             summ_struct.(tableName).current_in_B_real(index_listType) = [current_fields(index_listType).current_2_real]';
%             summ_struct.(tableName).current_in_B_im(index_listType) = [current_fields(index_listType).current_2_im]';
            summ_struct.(tableName).current_in_A_real(index_listType) = [current_fields_triplex(index_listType).current_1_real]; %current_1_A_real]';
            summ_struct.(tableName).current_in_A_im(index_listType) = [current_fields_triplex(index_listType).current_1_im]; %current_1_A_im]';
            summ_struct.(tableName).current_in_B_real(index_listType) = [current_fields_triplex(index_listType).current_2_real]; %current_1_B_real]';
            summ_struct.(tableName).current_in_B_im(index_listType) = [current_fields_triplex(index_listType).current_2_im]; %current_1_B_im]';
%             summ_struct.(tableName).current_in_C_im(index_listType) = [current_fields_triplex(index_listType).current_1_C_im]';
%             summ_struct.(tableName).current_in_C_real(index_listType) = [current_fields_triplex(index_listType).current_1_C_real]';
            
            summ_struct.(tableName).voltage_in_A_mag(index_listType) = [voltage_fields_triplex(index_listType).voltage_1_mag]/1000;
            summ_struct.(tableName).voltage_in_A_deg(index_listType) = [voltage_fields_triplex(index_listType).voltage_1_deg]/1000;
            summ_struct.(tableName).voltage_in_B_mag(index_listType) = [voltage_fields_triplex(index_listType).voltage_2_mag]/1000;
            summ_struct.(tableName).voltage_in_B_deg(index_listType) = [voltage_fields_triplex(index_listType).voltage_2_deg]/1000;
%             summ_struct.(tableName).voltage_in_C_mag(index_listType) = [voltage_fields_triplex(index_listType).voltage_1_C_mag]/1000;
%             summ_struct.(tableName).voltage_in_C_deg(index_listType) = [voltage_fields_triplex(index_listType).voltage_1_C_deg]/1000;            
            
            summ_struct.(tableName).nominalV(index_listType) = [voltage_fields(index_listType).nominal_voltage_mag]'/1000;

        end 

    end 
    %%
    summary_nodes_table_GLD = struct2table(summ_struct.node_types); 
%     writetable(summary_nodes_table_GLD, 'summary_nodes_GLD.csv');
end 