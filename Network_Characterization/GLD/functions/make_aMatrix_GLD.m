function [a_matrix_non, a_matrix, asym_matrix, bus_names] = make_aMatrix_GLD(...
    summary_lines_table, summary_nodes_table)
    
    %% read in buses  
    bus_names = summary_nodes_table.name;
    num_bus = length(bus_names);

    %% ID Line Rows

    line_table = table;
    line_table.name = summary_lines_table.name; 
    line_table.from = summary_lines_table.from; 
    line_table.to = summary_lines_table.to; 
    line_table.len = summary_lines_table.length; 
    num_lines = length(line_table.name);
    
    %% Read in nodes connected to nodes (occurs in GLD)    
%   Notes: node2node_type = {'triplex_load','load','triplex_node', 'node'}';
    node_type_components = summary_nodes_table.type;
    node2node_i_prelim = regexp( node_type_components, 'load');
    rows_node2node1 = find(not(cellfun('isempty', node2node_i_prelim)));

    node2node_i_prelim2 = regexp(node_type_components, 'node');
    rows_node2node2 = find(not(cellfun('isempty', node2node_i_prelim2)));

    rows_node2node = [rows_node2node1; rows_node2node2]; 
    num_node2node = length(rows_node2node);
    
    %% Add onto Adjacency Matrix: Nodes that are connected to nodes (loads and meters)
    for iNode = 1:num_node2node
        thisLine = rows_node2node(iNode);

        to = summary_nodes_table.parent{thisLine};
        [to_bus, ~] = strtok(to,'.'); %CHECK IF NEED THIS

        from = summary_nodes_table.name{thisLine};
        [from_bus, ~] = strtok(from, '.');

        to_i = strcmp(bus_names, to);
        iRow = find(to_i == 1);

        from_i = strcmp(bus_names, from);
        iCol = find(from_i == 1);

        a_matrix_non(iRow,iCol) = 1; 
        a_matrix_non(iCol, iRow) = 1;

        a_matrix(iRow, iCol) = 0.01;
        a_matrix(iCol, iRow) = 0.01;
    end 
    
    %% A matrix
    for iLine = 1:num_lines
        thisLine = iLine; 
        len = line_table.len(thisLine);
        to = line_table.to{thisLine};
        [to_bus, ~] = strtok(to,'.');

        from = line_table.from{thisLine};
        [from_bus, ~] = strtok(from, '.');
    
        to_i = strcmp(bus_names, to_bus);
        iRow = find(to_i == 1);

        from_i = strcmp(bus_names, from_bus);
        iCol = find(from_i == 1);
        
        a_matrix_non(iRow,iCol) = 1;
        a_matrix_non(iCol, iRow) = 1;
        
        if len == 0
            a_matrix(iRow, iCol) = 0.01;
            a_matrix(iCol, iRow) = 0.01;            
        else
            a_matrix(iRow, iCol) = len;
            a_matrix(iCol, iRow) = len;
        end
        
        asym_matrix(iRow, iCol) = 1;
        
    end 

end 














