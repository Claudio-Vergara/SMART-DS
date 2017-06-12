function [a_matrix_non, a_matrix, bus_names, asym_matrix] =...
    make_aMatrix_ODSS(file, circuit, summary_lines_table)
%% Read in buses - including letters in names
    bus_names = circuit.buses.names;
    num_bus = length(bus_names);
    
    %% ID Line Rows
%     line_type_components = summary_lines_table.name;%type;
    remove_switch_same = 0;
    [line_table] = create_line_table(file, summary_lines_table,...
        remove_switch_same);
    
    num_lines = size(line_table,1);

  
%% Create the adjacency matrix:
%% Cycle through the lines in the network, and identify the buses at the ends of each line. 
    a_matrix = sparse(num_bus, num_bus);
    a_matrix_non=sparse(num_bus, num_bus);
    asym_matrix=sparse(num_bus, num_bus);

    for iLine = 1:num_lines
        
        thisLine = iLine;
        len = line_table.length(thisLine);
        to = line_table.to{thisLine};
        from = line_table.from{thisLine};

        to_i = strcmp(to, bus_names);
        iRow = find(to_i);
              
        from_i = strcmp(from, bus_names);
        iCol = find(from_i); 
        
        a_matrix_non(iRow,iCol) = 1; %shoudl have a weighted matrix too
        a_matrix_non(iCol, iRow) = 1;

        if len == 0 % some elements don't have lengths associated with them
            a_matrix(iRow, iCol) = 1;
            a_matrix(iCol, iRow) = 1;            
        else
            a_matrix(iRow, iCol) = len;
            a_matrix(iCol, iRow) = len;
        end 
        
        asym_matrix(iRow, iCol) = 1; % for extracting data (so there aren't repeats)

    end 
    
end 