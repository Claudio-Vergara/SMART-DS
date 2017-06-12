function [line_table] = create_line_table(file, summary_lines_table, remove_switch_same)
% Create line_table
% Creates a table that summarizes all relevant details regarding the conductors in the network

% Description:
% Details from the summary lines table are extracted and saved in the lines table for ease-of-use. 
% In the function which calculates of transformer loads, switches which form loads may cause infinite loops. The remove_switch_same is a binary variable that allows switches which are marked as typically open to be excluded from the line table.

% Arguments:
% file: holds the paths and settings for the case

% summary_lines_table:
% remove_switch_same: a binary variable to indicate that the switches which are usually open should be excluded from inclusion in the table (1)

% Outputs:
% line_table: a table that holds the line information extracted from the summary lines table. 

    %% Create Line Table to hold all to's and from's, but excludes regulators
    line_type_components = summary_lines_table.name;

    line_table = table;
    line_table.name = summary_lines_table.name;
    line_table.type = summary_lines_table.type;
    line_table.from = summary_lines_table.from;
    line_table.to = summary_lines_table.to;
    line_table.length = summary_lines_table.length;
    line_table.nominalV = summary_lines_table.nominalV;
    line_table.component = summary_lines_table.component;
    line_table.phasecount = summary_lines_table.phasecount;
    %overwrite the empty to/from spaces in xformer rows
    % Exclude regulators 

    %all x
    i_x_rows = regexp(line_type_components, 'transformer');
    x_rows = find(not(cellfun('isempty', i_x_rows)));
    name_x = line_type_components(x_rows);
   
    %all regulators
    x_reg = regexp( name_x,'reg');
    rows_x_reg = find(not(cellfun('isempty', x_reg)));
    rows_x_not_reg = x_rows(find(cellfun('isempty', x_reg)));
    
    
    %num of xformers that aren't reg
    num_x = length(x_rows) - length(rows_x_reg);
    
    %% remove rows with open switches (may form loops)
    %  do this only when creating transformer trees
    if remove_switch_same
        i_open_sw = regexp(line_table.to, 'open');
        row_open_sw = find(not(cellfun('isempty', i_open_sw)));
        line_table(row_open_sw,:) = [];
    end
    
    %% Remove the phases in the from and to (bus names)
  
    for iRow = 1:size(line_table,1)
        [clean_fr, ~] = strtok(line_table{iRow, 'from'}, '.');
        [clean_to, ~] = strtok(line_table{iRow, 'to'}, '.');
        
        clean_fr = clean_fr{:};
        clean_to = clean_to{:};
        
        if regexp(clean_fr, 'open')
            clean_fr(regexp(clean_fr,'[_open]')) = [];
        end 
        if regexp(clean_to, 'open')
            clean_to(regexp(clean_to,'[_open]')) = [];
        end  

       
        line_table{iRow, 'from'} = {clean_fr};
        line_table{iRow, 'to'} = {clean_to};
    end
   
    
    %% remove rows in which switch is between a node and a reg on that node (or will loop)
    %  do this only when creating transformer trees
    if remove_switch_same
        
        for iRow = 1:size(line_table.to,1)
            should_remove(iRow) = strcmp(line_table{iRow, 'from'}, line_table{iRow, 'to'});
        end 
        line_table(should_remove,:) = [];
    end
    
end 