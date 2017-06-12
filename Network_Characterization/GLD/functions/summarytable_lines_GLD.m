function [summary_lines_table_GLD] = summarytable_lines_GLD(outputsTable, powerFlow)
    %For GLM files (GridlabD) and XML outputs

    %% FIRST: READ IN COMPONENTS AND CLEAN STRINGS
    %% Pull Data into Arrays (columns of table)

    line_types = {'overhead_line', 'underground_line',...
        'fuse', 'recloser','regulator','switch', 'transformer', 'triplex_line'};

    all_types = [line_types];

    line_list = {'overhead_line', 'underground_line', 'triplex_line'};

    gen_str_fields = {'name','parent','to','from','phases','bustype','load_class'};
    gen_num_fields = {'length', 'emergency_rating', 'current_limit'};

    %% fields for lines
    % doesn't see like line types include voltage as an output
    V_fields = {'voltage_A','voltage_B','voltage_C','nominal_voltage',...
        'continuous_rating'};
    P_fields = {'power_in_A','power_in_B','power_in_C'};
    i_fields = {'current_in_A','current_in_B','current_in_C'};


    %% Should call line_detials_GLD function to generate the strcutures with data
    %only applicable to lines -- Turn this into a function 
    config_field = {'configuration'};

    [line_details] = line_details_GLD(powerFlow);

    %this gets created in the make table function
    line_config_struct = line_details.line_config_struct;
    OL_config_types = line_details.overhead_line_conductor_struct;
    UG_config_types = line_details.underground_line_conductor_struct;
    tri_config_types = line_details.triplex_line_conductor_struct;

    spacing_struct = line_details.line_spacing_struct;
    
    
    %% find secondary V of transformers from the configuration sheet
    
    xfm_config_table = struct2table(outputsTable.transformer_configuration);
    xfm_table = struct2table(outputsTable.transformer);
    config_row = find(strcmp(xfm_table.rowLabels, 'configuration'));
    name_row = (strcmp(xfm_table.rowLabels, 'name')); 
    xfm_names = xfm_table{name_row,2:end};
    
    xfm = table;
    for iX = 1:length(xfm_names)%2:size(xfm_table,2)
        name = xfm_names{iX};
        xformer_col = find(strcmp(xfm_names, name));
        this_config = xfm_table{config_row, xformer_col};

        name_row = find(strcmp(xfm_config_table.rowLabels, 'name'));
        secondary_row = find(strcmp(xfm_config_table.rowLabels,...
            'secondary_voltage'));

        xfm_configs = xfm_config_table{name_row,:};
        i_config_col = regexp(xfm_configs, this_config);
        config_col = find(not(cellfun('isempty', i_config_col)));        
        second_V = xfm_config_table{secondary_row, config_col}{1,1};
        second_V(regexp(second_V, '[A-Za-z+]')) = [];
        xfm_2ndV = str2double(second_V);

        xfm_secondV(iX) = xfm_2ndV;
        
    end
    
    xfm{:,'name'} = xfm_names';
    xfm{:,'secondV'} = xfm_secondV';

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

                 %% General fields - for each type of object, will run through each loop, during which a set of values will be pulled out for each type element of the object type
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
                     [value, units] = strtok(thisStr,' ');

                     gen_fields(rowNum).(field) = str2double(value);

                 end 
                 %% Voltage fields
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
                 
                 %% tranformer config: if the object is a transformer,...
                 %  find the voltage at the secondary winding

                 
                 if strcmp(type,'transformer')
                     
                    i_2ndV = strcmp(xfm.name, gen_fields(rowNum).name);

                    secondaryV(rowNum,1) = xfm{i_2ndV, 'secondV'};
                 else
                    secondaryV(rowNum,1) = 0;
                 end 

                 %% power fields
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

                 %% current fields
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

                    if any(regexp(cleanStr,'j'))
                        [i_real, leftover] = strtok(cleanStr,' ');
                        [i_imag, leftover2] = strtok(leftover, 'j');
                    end 

                    if any(regexp(cleanStr, 'i'))
                        [i_real, leftover] = strtok(cleanStr,' ');
                        [i_imag, leftover2] = strtok(leftover, 'i');
                    end 
                    current_fields(rowNum).([field '_real']) = str2double(i_real); %iNum refers to rows now
                    current_fields(rowNum).([field '_im']) = str2double(i_imag);
                 end 
                %% Phase details - find number of phases (all line type)
                 %% Calculate num phases
                fieldHeaders = sheet{:,1}; 
                row_index = find(cellfun(@(x)strcmp(x,'phases'), fieldHeaders));
                
                if isempty(row_index)
                    phasecount = 0;
                    continue;
                end 
                thisStr = sheet{row_index,iNum}{1,1};
                
                if strcmp(thisStr, 'S') %is a split phase
                    thisPhase = [];
                    if power_fields(rowNum).power_out_A_P ~=0 
                       thisPhase = [thisPhase 'A'];
                       keepCol(1) = 1;
                    end

                    if power_fields(rowNum).power_out_B_P ~= 0
                       thisPhase = [thisPhase 'B'];
                       keepCol(2) = 1;
                    end

                    if power_fields(rowNum).power_out_C_P ~= 0                        
                        thisPhase = [thisPhase 'C'];   
                        keepCol(3) = 1;
                    end                   
                    phasecount = length(thisPhase);
                else
                    phasecount = length(gen_fields(rowNum).phases)-1;


                end 
                gen_fields(rowNum).phasecount = phasecount;
                 
                %% line details
                inline_list = regexp(type, line_list);
                isline = any(find(~cellfun('isempty',inline_list)));

                if ~isline
                    summary_lines(rowNum).suseptance_B = 0; %B;
                    summary_lines(rowNum).resistance_R = 0;
                    summary_lines(rowNum).reactance_X = 0;

                else
                    for iField = 1:length(config_field)

                        summary_lines(rowNum).type = gen_fields(rowNum).type;
                        summary_lines(rowNum).name = gen_fields(rowNum).name;
                        field = config_field{iField};
                        row_index = find(cellfun(@(x)strcmp(x,{field}), fieldHeaders));                

                        thisStr = sheet{row_index,iNum}{1,1}; %iNum refers to each component type
                        line_config_row = find(cellfun(@(x)strcmp(x,{thisStr}),...
                        {line_config_struct.name})); %index is the row in line_config_struct

                        % line conductor type
                        conductor_type = line_config_struct(line_config_row).conductor_N;

                        % line spacing
                        spacing_type = line_config_struct(line_config_row).spacing;
                        iSpace = find(cellfun(@(x)strcmp(x,spacing_type),...
                            {spacing_struct.name}));

                        if ~any(regexp(conductor_type, 'triplex'))
                            d_AB = spacing_struct(iSpace).distance_AB;
                            d_AC = spacing_struct(iSpace).distance_AC;
                            d_BC = spacing_struct(iSpace).distance_BC;
                            
                            d_AN = spacing_struct(iSpace).distance_AN;
                            d_BN = spacing_struct(iSpace).distance_BN;
                            d_CN = spacing_struct(iSpace).distance_CN;
                        end


                        if any(regexp(conductor_type, 'overhead'))
                            icond = find(cellfun(@(x)strcmp(x,conductor_type),...
                                {OL_config_types.name}));
                            gmr = OL_config_types(icond).geometric_mean_radius;
                            resistance = OL_config_types(icond).resistance;

                        elseif any(regexp(conductor_type, 'under'))
                            icond = find(cellfun(@(x)strcmp(x,conductor_type),...
                                {UG_config_types.name}));
                            gmr = UG_config_types(icond).conductor_gmr;
                            resistance = UG_config_types(icond).conductor_resistance;
                        else % is this for triplex
                            icond = find(cellfun(@(x)strcmp(x,conductor_type),...
                                {tri_config_types.name}));
                            gmr = tri_config_types.geometric_mean_radius;
                            resistance = tri_config_types.resistance;                    
                        end
                        
                      
                
                        %% calclulate reactance and susceptance
                        % need to edit this equation for n<3 phases
                        if phasecount == 3
                            Deq = (d_AB*d_BC*d_AC)^(1/3);
                            X = 4*pi*60*10^-4*log(Deq/(2*gmr)); %is GMR the same as diameter?
                            B = 0; %pi*60/9/log(Deq/gmr);
                        elseif phasecount == 2                        
                            Deq = max([d_AB d_BC d_AC]); 
                            B = 0; %pi*60/9/log(Deq/gmr);
                            X = 4*pi*60*10^-4*log(Deq/(2*gmr)); 
                        elseif phasecount == 1
                            X = 0;
                        end 
                 
                        %% save into the summary structure
                        summary_lines(rowNum).suseptance_B = 0; %B;
                        summary_lines(rowNum).resistance_R = resistance;
                        summary_lines(rowNum).reactance_X = X;                        

                    end  %end if is line
                end

                %% Piece together the continuous rating
                              
                % if transformer type - to get units in kVA
                if strcmp(type, 'transformer')
                    continuous_rating(rowNum) = voltage_fields(rowNum).continuous_rating_mag*1000;
                elseif strcmp(type, 'fuse')
                    continuous_rating(rowNum) = gen_fields(rowNum).current_limit;
                else % if line type 
                    continuous_rating(rowNum) = voltage_fields(rowNum).continuous_rating_mag;    
                end
                
                
                rowNum = rowNum+1;
            end 
        end



    %% ID the rows that are line type vs. node type
    line_types = {'overhead_line', 'underground_line',...
        'fuse', 'recloser','regulator','switch', 'transformer', 'triplex_line'};
    table_type = 'line_type'; %{'line_type'};

    line_rows = [];

    for iType = 1:length(line_types)
        type = line_types{iType};
        component_names = {gen_fields.type};
        i_rows = regexp(type, component_names);
        new_line_rows = find(~cellfun('isempty',i_rows));
        line_rows = [line_rows new_line_rows];
    end

    line_rows = unique(line_rows);
    rows_by_type(1,1:length(line_rows)) = line_rows;



    %% generate a 0 matrix for each type (to keep things in order) 
    fields_cell = {'component','name', 'type', 'bus', 'to', 'from',...
        'linecode','parent','phases'}; %, 'bus_winding1', 'bus_winding2'}; %assume 2 bus windings for each xformer
    fields_num = {'phasecount','length', 'nominalV', 'nominalV_2nd_xfm',...
        'cont_rating_amps_or_kVA',...
        'resistence_R', 'reactance_X','susceptance_B', 'power_in_A_P',...
        'power_in_A_Q','power_in_B_P','power_in_B_Q','power_in_C_P',...
        'power_in_C_Q','current_in_A_real', 'current_in_A_im',...
        'current_in_B_real','current_in_B_im', 'current_in_C_real',...
        'current_in_C_im', 'voltage_in_A_mag', 'voltage_in_A_deg'...
        'voltage_in_B_mag', 'voltage_in_B_deg', 'voltage_in_C_mag'...
        'voltage_in_C_deg', 'x', 'y',  'measured_real_power', 'measured_reactive_power'}; 


    %% Start pulling together the matrix 

    %% for line_types

        tableName = table_type; %{iType};
        index_listType = rows_by_type; %(iType,rows_by_type(iType,:) > 0);

        %cell arrays
        for iField = 1:length(fields_cell)
            field = fields_cell{iField};
            num_components = size(index_listType,2);
            newcell = cell(1, num_components)';
            newcell(:) = {'empty'};
            summ_struct_L.(tableName).(field) = newcell;
        end
        %doubles
        for iField = 1:length(fields_num)
            field = fields_num{iField};
            num_components = size(index_listType,2);
            summ_struct_L.(tableName).(field) = zeros(1, num_components)';
        end

        summ_struct_L.(tableName).component = component_names(index_listType)';
        summ_struct_L.(tableName).name = {gen_fields(index_listType).name}';
        summ_struct_L.(tableName).type = {gen_fields(index_listType).type}';
        summ_struct_L.(tableName).parent = {gen_fields(index_listType).parent}';
        summ_struct_L.(tableName).to = {gen_fields(index_listType).to}';
        summ_struct_L.(tableName).from = {gen_fields(index_listType).from}';
        summ_struct_L.(tableName).length = [gen_fields(index_listType).length]';

        summ_struct_L.(tableName).resistence_R = [summary_lines(index_listType).resistance_R]';
        summ_struct_L.(tableName).reactance_X = [summary_lines(index_listType).reactance_X]';
        summ_struct_L.(tableName).susceptance_B = [summary_lines(index_listType).suseptance_B]';

        summ_struct_L.(tableName).power_in_A_P = [power_fields(index_listType).power_in_A_P]'/1000;
        summ_struct_L.(tableName).power_in_A_Q = [power_fields(index_listType).power_in_A_Q]'/1000;
        summ_struct_L.(tableName).power_in_B_P = [power_fields(index_listType).power_in_B_P]'/1000;
        summ_struct_L.(tableName).power_in_B_Q = [power_fields(index_listType).power_in_B_Q]'/1000;
        summ_struct_L.(tableName).power_in_C_P = [power_fields(index_listType).power_in_C_P]'/1000;
        summ_struct_L.(tableName).power_in_C_Q = [power_fields(index_listType).power_in_C_Q]'/1000;

        summ_struct_L.(tableName).current_in_A_real = [current_fields(index_listType).current_in_A_real]';
        summ_struct_L.(tableName).current_in_A_im = [current_fields(index_listType).current_in_A_im]';
        summ_struct_L.(tableName).current_in_B_real = [current_fields(index_listType).current_in_B_real]';
        summ_struct_L.(tableName).current_in_B_im = [current_fields(index_listType).current_in_B_im]';
        summ_struct_L.(tableName).current_in_C_real = [current_fields(index_listType).current_in_C_real]';
        summ_struct_L.(tableName).current_in_C_im = [current_fields(index_listType).current_in_C_im]';

        summ_struct_L.(tableName).voltage_in_A_mag = [voltage_fields(index_listType).voltage_A_mag]'/1000;
        summ_struct_L.(tableName).voltage_in_A_deg = [voltage_fields(index_listType).voltage_A_deg]'/1000;
        summ_struct_L.(tableName).voltage_in_B_mag = [voltage_fields(index_listType).voltage_B_mag]'/1000;
        summ_struct_L.(tableName).voltage_in_B_deg = [voltage_fields(index_listType).voltage_B_deg]'/1000;
        summ_struct_L.(tableName).voltage_in_C_mag = [voltage_fields(index_listType).voltage_C_mag]'/1000;
        summ_struct_L.(tableName).voltage_in_C_deg = [voltage_fields(index_listType).voltage_C_deg]'/1000;
        summ_struct_L.(tableName).cont_rating_amps_or_kVA = continuous_rating(index_listType)'/1000;
        summ_struct_L.(tableName).nominalV = [voltage_fields(index_listType).nominal_voltage_mag]'/1000;
        summ_struct_L.(tableName).nominalV_2nd_xfm = secondaryV; %2nd V for  transformers
        
        summ_struct_L.(tableName).phases = {gen_fields(index_listType).phases}';
        summ_struct_L.(tableName).phasecount = {gen_fields(index_listType).phasecount}';

    %% save the table
    summary_lines_table_GLD = struct2table(summ_struct_L.line_type);
end 