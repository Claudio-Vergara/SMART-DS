function [summary_nodes_table, summary_lines_table] = print_final_metrics(load_all, line_all, ...
     total_components, summary_lines_table, summary_nodes_table, file, coord)

%% Build tables
    load_table = struct2table(load_all);
    line_table = struct2table(line_all);
    if isfield(total_components, 'switch')
        total_components.switches = total_components.switch;
        total_components = rmfield(total_components, 'switch');
    end 
    general_count = struct2table(total_components);

    %% ID the headers of the lines and loads tables: find all the fields
    %% of both line and node types that are new (currently not in the summary tables)
    new_line_fields = line_table.Properties.VariableNames;
    new_load_fields = load_table.Properties.VariableNames;
    add_fields = unique([new_line_fields new_load_fields]);
    add_fields = sort(add_fields);
    
    %% ID the headers ofthe summary lines table
    summary_lines_fields = summary_lines_table.Properties.VariableNames;
    summary_nodes_fields = summary_nodes_table.Properties.VariableNames; 
    
    %% line types - add new metrics to summary lines table
    % if the additional field is a not already in summary lines table,
    % and is a new line field, then add the relevant values from the lines table
    % to it; Otherwise, add the field and fill it with zeros
    for iField = 1:length(add_fields)
        field = add_fields{iField};
              
%         if any(strcmp(summary_lines_fields, field)) == 0
        if ~any(strcmp(summary_lines_fields, field))          
            if any(strcmp(new_line_fields, field))
                summary_lines_table.(field) = line_table{:,field};
            else
                summary_lines_table.(field) = zeros(size(line_table,1),1);
            end
        end
            
    end
    

    %%  Node types - add metrics to summary nodes table 
    % if the additional field is a not already in summary nodes table,
    % and is a new node field, then add the relevant values from the nodes...
    % table to it; Otherwise, add the field and fill it with zeros
    
    for iField = 1:length(add_fields)
        field = add_fields{iField};
%         if any(strcmp(summary_nodes_fields, field)) == 0
        if ~any(strcmp(summary_nodes_fields, field))           
            if any(strcmp(new_load_fields, field))
                summary_nodes_table.(field) = load_table{:,field};
            else
                summary_nodes_table.(field) = zeros(size(load_table,1),1);
            end
        end
            
    end 
%%
    %% add arbitrary_x and arbitrary_y to headers when these summary tables are
    % first created
    x_array = zeros(size(summary_nodes_table, 1),1);
    y_array = zeros(size(summary_nodes_table, 1),1);

    summary_lines_table.arbitrary_x = zeros(size(summary_lines_table, 1),1);
    summary_lines_table.arbitrary_y = zeros(size(summary_lines_table, 1),1);

    for i = 1:size(coord,1)
        row = strcmp(summary_nodes_table.name, coord{i, 'name'});
        if sum(row) > 0
            x_array(row) = coord{i, 'x'};
            y_array(row) = coord{i, 'y'};

        end 
    end 

    summary_nodes_table.arbitrary_x = x_array;
    summary_nodes_table.arbitrary_y = y_array;
    
    
    %% write tables to a csv files: save as csv files
    writetable(summary_nodes_table, fullfile(file.CSVexport, 'load_metrics.csv'));
    writetable(summary_lines_table, fullfile(file.CSVexport, 'line_metrics.csv'));
    writetable(general_count, fullfile(file.CSVexport, 'gen_metrics.csv'));
end 
