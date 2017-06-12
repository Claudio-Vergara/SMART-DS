function [coord, tuples] = plot_aMatrix_GLD(file, a_matrix, asym_matrix,...
    bus_names, summary_lines_table, summary_nodes_table)

%% Plot aMatrix
    sumA = sum(a_matrix);
    sum2A = sum(a_matrix,2);
    connected_col = find(sumA ~= 0); %remove the nodes with 0 linkages
    connected_row = find(sum2A ~=0);

    final_name_nodes = {bus_names{connected_col,1}}';

%% Remove extra nodes (if any) 
    testMat = a_matrix(connected_row,connected_col);
    sumTestMat = sum(testMat);
    sum2TestMat = sum(testMat);

    check1= find(sumTestMat == 0);
    check2 = find(sum2TestMat == 0);

    g1 = graph(testMat, final_name_nodes); %can also take out final_name_nodes

%% Without labels - Force layout
    figure;
    p2 = plot(g1, 'Layout','force','NodeLabel',final_name_nodes);

%     figure;
%     p3 = plot(g1, 'Layout','layered','NodeLabel',final_name_nodes);
    coord = table;
    

    
%% Get coordinates
    coord.x = get(p2,'XData')';
    coord.y = get(p2,'YData')';
    coord.name = get(p2, 'NodeLabel')';
    
    % add arbitrary_x and arbitrary_y to headers when these summary tables are
    % first created
    for i = 1:size(coord,1)
        row = strcmp(summary_nodes_table.name, coord{i, 'name'});
        summary_nodes_table{row, 'arbitrary_x'} = coord{i, 'x'};
        summary_nodes_table{row, 'arbitrary_y'} = coord{i, 'y'};
    end 

%% See if anything is attached to each bus (if any)
    for iRow = 1:size(coord,1)
        n1 = coord{iRow, 'name'};
        n1_row = find(strcmp(summary_nodes_table.name, n1));
        n1_type(iRow) = summary_nodes_table{n1_row, 'type'};
    end
    
    coord.node_type = n1_type';    
%% ID tuples (aMatrix is n x n: in the order of bus_names x bus_names)
    node1_array = [];
    node2_array = [];

    for iNode = 1:length(asym_matrix)
        node1_name = bus_names(iNode);
        node1_row = asym_matrix(iNode,:);
        
        node2_i = find(node1_row ~= 0);
        node2_name = bus_names(node2_i);
        node2_array = [node2_array; node2_name];
        
        node1_cell = cell(length(node2_i),1);
        node1_cell(:) = node1_name;
        node1_array = [node1_array; node1_cell];
        
    end
    
%% ID the lines associated with each tuple
%  for each node tuple, find the string that links them
    edges = {};
    remove_switch_same = 0;
    line_table = create_line_table(file, summary_lines_table, remove_switch_same);
      
    % Ignore the line objs attached to the same node
    edges = cell(length(node1_array),1);
    edge_type = cell(length(node1_array),1);
    for iNode = 1:length(node1_array)

        n1 = node1_array(iNode);     
        n2 = node2_array(iNode);
        to_row = strcmp(line_table.to, n1);
        from_row = strcmp(line_table.from, n2);
        
        if strcmp(n1, n2) %can be more than one obj on the same node
            overlay = to_row + from_row;
            matched_row = find(overlay >1);
            for iRow = 1:length(matched_row)
                row = matched_row(iRow); 
                node1_final(row,1) = n1;
                node2_final(row,1) = n2;
                edges(row,1) = line_table{row, 'name'}; 
                edge_type(row,1) = line_table{row, 'type'}; 
            end
            
        else
            overlaid = to_row + from_row; % + to_row2 + from_row2;
            matched_row = find(overlaid > 1);
            node1_final(matched_row,1) = n1;
            node2_final(matched_row,1) = n2;
            edges(matched_row,1) = line_table{matched_row, 'name'}; 
            edge_type(matched_row,1) = line_table{matched_row, 'type'};
        end 
    end
    
%% Artificially make meters into line type objects
% from node for meters = its own coordinates
% to node for meters = summary_node_table.parent == the meters
    mtypes = {'meter', 'triplex_meter'};
    count = 1;
    for i_mtype = 1:length(mtypes)
        type = mtypes{i_mtype};
        m_rows = strcmp(summary_nodes_table.type, type);
        meters = summary_nodes_table.name(m_rows);

        for iMeter = 1:length(meters)
            this_meter = meters{iMeter};
            meter_node1(count,1) = {this_meter};
            n2_row = find(strcmp(summary_nodes_table.parent, this_meter));
            meter_node2(count,1) = summary_nodes_table{n2_row, 'name'};
            meter_edges(count,1) = {this_meter};
            meter_edge_type(count,1) = {type};
            count = count + 1;

        end
    end 


%% Save the final results to tables    
    tuples = table;
    tuples.node1 = [node1_final; meter_node1];
    tuples.node2 = [node2_final; meter_node2];
    tuples.edges = [edges; meter_edges];
    tuples.edge_type = [edge_type; meter_edge_type];
    
%% Plotting     
    figure;
    hold on;
    
%% Plot lines - add labels

    line_plot.color = [rgb('PaleTurquoise'); rgb('LightPink'); ...
        rgb('RoyalBlue'); rgb('Yellow'); rgb('LightGreen');...
        rgb('Red'); rgb('Orange'); rgb('DarkGreen'); rgb('Purple')];
    line_plot.type = {'transformer', 'meter', 'triplex_meter',...
        'underground_line','overhead_line','triplex_line', 'fuse',...
        'regulator', 'switch'};
    legend_name = {'transformer', 'meter', 'triplexMeter',...
        'undergroundLine','overheadLine','triplexLine', 'fuse',...
        'regulator', 'switch'};
    count = 1;
    hg_array = [];
    for iType = 1:length(line_plot.type)
        line_rows = find(strcmp(tuples.edge_type, line_plot.type{iType}));
        this_color = line_plot.color(iType,:);
        this_group = [];
        for iSeg = 1:length(line_rows)
            row = line_rows(iSeg);
            n1 = tuples.node1(row);
            n2 = tuples.node2(row);

            row_n1 = find(strcmp(coord.name, n1));
            row_n2 = find(strcmp(coord.name, n2));

            x(1) = coord{row_n1, 'x'};
            x(2) = coord{row_n2, 'x'};
            y(1) = coord{row_n1, 'y'};
            y(2) = coord{row_n2, 'y'};        

            this_group(iSeg) = plot(x,y, 'Color', this_color,...
                'LineWidth', 3);
            
        end
        
        hg = hggroup;
        set(this_group,'Parent',hg);
        set(hg,'Displayname',legend_name{iType});
        hg_array(count) = hg;
        count = count + 1;
    end 
    
    
    %% Plot nodes
    legend_name = {'node', 'load', 'triplexNode','triplexLoad'}; 
    node_plot.type = {'node', 'load', 'triplex_node','triplex_load'}; 
    node_plot.color = [rgb('PowderBlue'); rgb('Red'); rgb('RoyalBlue');...
        rgb('Yellow')]; 
    sz = 75;
    for iType = 1:length(node_plot.type)
        node_rows = find(strcmp(coord.node_type, node_plot.type{iType}));
        this_color = node_plot.color(iType,:);
        this_group = [];
        for iNode = 1:length(node_rows)
            x = coord{node_rows(iNode), 'x'};
            y = coord{node_rows(iNode), 'y'};
            this_group(iNode) = scatter(x, y, sz, 'filled',...
                'LineWidth', 1,'MarkerFaceColor',this_color,...
                'MarkerEdgeColor', 'blue');
        end
        
        hg = hggroup;
        set(this_group,'Parent',hg);
        set(hg,'Displayname',legend_name{iType});
        hg_array(count) = hg;
        count = count + 1;
    end
    

    
    %% Plot swing bus/node
    this_group = [];
    swing_row = find(cellfun('isempty',summary_nodes_table.parent));
    swing_name = summary_nodes_table{swing_row, 'name'};
    row = find(strcmp(coord.name, swing_name));
    x = coord{row, 'x'};
    y = coord{row, 'y'};
    sz = 200;
    this_group = scatter(x, y, sz, 'filled', 'LineWidth', 2,'MarkerFaceColor',...
        'yellow', 'MarkerEdgeColor', 'red');
    
    hg = hggroup;
    set(this_group,'Parent',hg);
    set(hg,'Displayname', 'swingBus');
    hg_array(count) = hg;
   
    legend(hg_array);

    saveas(gcf, fullfile(file.CSVexport,'feeder.jpeg'));
    
end   