function [line_details] = line_details_GLD(powerFlow)

    line_fields = {'line_spacing_list', 'overhead_line_conductor_list',...
            'underground_line_conductor_list', 'line_configuration_list'...
            'triplex_line_configuration_list', 'triplex_line_conductor_list'};
    iConfig = 1;
    for iField = 1:length(line_fields)
        field_list = line_fields{iField};
        field = field_list(1:end-5);
        struct_name = [field '_struct'];
        
        if ~isfield(powerFlow.(field_list), field)
             line_details.(struct_name) = [];
            continue;
        end 
        
        sheet = powerFlow.(field_list).(field);
        num_components = size(sheet,2); % number of compnents of type field

        for iComp = 1:num_components %for each component
            if num_components == 1
                component = sheet;
            else
                component = sheet{1,iComp};
            end 
            comp_name = component.name.Text(2:end-1);
            comp_fields = fieldnames(component);
            line_details.(struct_name)(iComp).name = comp_name;        

            %% Depending on the type, the components will have different fields
            %% The field types are IDed below
            %% For line spacing
            if any(regexp(field, 'line_spacing'))
                % specify fields of interest
                i_all_details_index = regexp(comp_fields, 'distance_'); %for each field
                i_all_details = find(~cellfun('isempty',i_all_details_index));

                for iDetails = 1:length(i_all_details) %for each distance field
                    index = i_all_details(iDetails);
                    phase_name = comp_fields{index};
                    phase_dist = component.(phase_name).Text;
                    [dist_val, unit] = strtok(phase_dist, ' ');
                    line_details.(struct_name)(iComp).(phase_name) = str2double(dist_val(2:end));

                end

                line_details.(struct_name)(iComp).unit = unit;
            end 

            %% For conductor_lists
            if any(regexp(field, 'line_conductor'))
                details = {'geometric_mean_radius','resistance','diameter',...
                    'conductor_resistance','conductor_gmr','conductor_diameter'};
                for iDetails = 1:length(details)
                    thisDetail = details{iDetails};
                    if sum(strcmp(thisDetail, comp_fields)) == 0
                        continue;
                    end 
                    detail_val = component.(thisDetail).Text;
                    [detail_val, unit] = strtok(detail_val, ' ');
                    line_details.(struct_name)(iComp).(thisDetail) = str2double(detail_val(2:end));
                    line_details.(struct_name)(iComp).([thisDetail '_unit']) = unit;

                end 

            end

            %% For line configuration
            if regexp(field, 'line_configuration')
                %instead of indexing with iComp, use another index (because
                %there are triplex and regular line configurations
                
                line_details = rmfield(line_details, struct_name);
                
                
                i_all_details_index = regexp(comp_fields, 'conductor'); %for each field
                i_all_details = find(~cellfun('isempty',i_all_details_index));
                
                %find the conductor types
                for iDetails = 1:length(i_all_details) %for each distance field
                    thisDetail = i_all_details(iDetails);
                    phase_name = comp_fields{thisDetail};
                    phase_conductor = component.(phase_name).Text;
                    line_details.line_config_struct(iConfig).name = comp_name;        

                    line_details.line_config_struct(iConfig).line_type = field;
                    line_details.line_config_struct(iConfig).(phase_name) = phase_conductor;
                    
                end
                
                %find the z matrices (if any)
                i_matrices_index = regexp(comp_fields, '[zc][123][123]');
                i_matrices = find(~cellfun('isempty',i_matrices_index));
                for iMatrices = 1:length(i_matrices)
                    thisIndex = i_matrices(iMatrices);
                    matrix_name = comp_fields{thisIndex};
                    mat_value = component.(matrix_name).Text;
                    [value_str, unit] = strtok(mat_value, ' ');
                    line_details.line_config_struct(iConfig).(matrix_name) = value_str;
                    line_details.line_config_struct(iConfig).([matrix_name '_units']) = unit;
                end 
                
                is_spacing = regexp(comp_fields, 'spacing');
                spacing_exist = any(~cellfun('isempty',is_spacing));
                
                if spacing_exist
                    spacing = component.spacing.Text;
                    line_details.line_config_struct(iConfig).spacing = spacing;
                else
                    line_details.line_config_struct(iConfig).spacing = nan;
                end
                
                iConfig = iConfig + 1;

            end 

        end 
    end 
end 