function [nodes_array] = create_nodesarray_COM(line_table, summary_nodes_table, summary_lines_table)
% create_nodesarray_ODSS
% creates a table of  critical information regarding nodes

% Description:
% From the circuit data structure and the line table, this function identifies the critical downstream and upstream buses for each bus, including its parent bus, the line directly connecting it to the parent bus, and losses associated with power flow through that line
% This information is used to hold vital network connection details in the creation of the transformer table

% Arguments:
% circuit:  holds the useful values regarding the circuit retrieved from the COM engine.
% line_table: holds the critical information regarding lines in a useful table

% Outputs:
% nodes_array: holds the critical information regarding node connection and sequencing 

%% read in from: file.ODSS.losses (it contains line types) 
%     losses_table.names = lower(circuit.all_elements.element_names);
%     evens = 2;
%     even_array = [];
%     
%     while 1
%         even_array = [even_array evens];
%         evens = evens + 2;
%         if evens > length(circuit.all_elements.element_losses)
%             break;
%         end            
%     end
%     
%     odd_array = even_array - 1;
%     if max(odd_array) < length(losses_table.names)
%         odd_array = [odd_array (max(odd_array)+2)];
%     end 
%     losses_table.losses_P = circuit.all_elements.element_losses(odd_array)';
%     losses_table.losses_Q = circuit.all_elements.element_losses(even_array)';
% 
% 
% 
%     nodes_array = struct;
%     
%     % ID list of buses
%     bus_names = circuit.buses.names;
%     num_bus = length(bus_names);

    %for each node
     
    rows = strcmp(summary_nodes_table.type, {'node'});
    bus_names = summary_nodes_table{rows, 'name'};
    
    for iBus = 1:length(bus_names)
        %start from bus 1, move downstream fro here
        this_obj = bus_names(iBus);

        %choose one parent node, out of the potentially many
        parent_row = max(find(strcmp(line_table.to, this_obj)));         
        this_parent = line_table{parent_row,'from'};
        this_line = line_table{parent_row, 'name'};
        line_type = line_table{parent_row, 'type'};
        
        nodes_array(iBus).name = this_obj;
        
        %% ID losses
        if isempty(parent_row)
            continue;
        end
        loss_row = find(strcmp(summary_lines_table.name, this_line));
        line_loss_P = summary_lines_table{loss_row, 'losses_re'};
        line_loss_Q = summary_lines_table{loss_row, 'losses_im'};
        line_loss_S = sqrt(line_loss_P^2 + line_loss_Q^2);        
%         loss_row = find(strcmp(losses_table.names, this_line));
%         line_loss_P = losses_table.losses_P(loss_row);
%         line_loss_Q = losses_table.losses_Q(loss_row);
%         line_loss_S = sqrt(line_loss_P^2 + line_loss_Q^2);
        
        nodes_array(iBus).parent_node = this_parent{1,1};
        nodes_array(iBus).line_connector = this_line{1,1};
        nodes_array(iBus).line_type = line_type{1,1};        
        
        nodes_array(iBus).line_loss_P = line_loss_P;
        nodes_array(iBus).line_loss_Q = line_loss_Q;
        nodes_array(iBus).line_loss_S = line_loss_S;
    end 

        %% parent array: add in upstream downstream nodes
    for iNode = 1:length(nodes_array)
        from_nodes1 = [];
        from_nodes2 = [];
        to_nodes1 = [];
        to_nodes2 = [];

        this_node = nodes_array(iNode).name;

        %upstream
        keep_rows = find(strcmp(line_table.to, this_node));
        from_nodes1 = line_table{keep_rows, 'from'};
        all_from_nodes = unique(from_nodes1);
        nodes_array(iNode).upstream_nodes = all_from_nodes;

        %downstream
        keep_rows1 = find(strcmp(line_table.from, this_node));
        to_nodes1 = line_table{keep_rows1, 'to'};

        all_to_nodes = unique(to_nodes1);
        nodes_array(iNode).downstream_nodes = all_to_nodes;
    end
    %remove the buses that are named 9r etc. 
    remove1 = cellfun('isempty', {nodes_array(:).line_connector});
    remove2 = cellfun('isempty', {nodes_array(:).downstream_nodes});
    remove = remove1 + remove2; 
    nodes_array(remove == 2) = [];    
end