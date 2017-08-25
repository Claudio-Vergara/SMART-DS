function [coord, tuples] = plot_aMatrix_feeder(file, Feeder, filename, nk)
a_matrix=Feeder.adj_matrix.(filename);
asym_matrix=Feeder.asy_matrix.(filename);
bus_names=Feeder.Bus_Sub_Names.(filename);
summary_lines_table=Feeder.summary_feeder_lines.(filename);
summary_nodes_table=Feeder.summary_feeder_nodes.(filename);
nodes_array=Feeder.Bus_Node_Array1.(filename);
%% Find and remove a unused buses. These are buses that are not connected to any other bus in the network. 
%% Plot aMatrix
    sumA = sum(a_matrix);
    sum2A = sum(a_matrix,2);
    connected_col = sumA ~= 0; %remove the nodes with 0 linkages
    connected_row = sum2A ~=0;


%% Remove extra nodes that are not connected (if any) 
    final_name_nodes = {bus_names{connected_col,1}}';
    cleanMat = a_matrix(connected_row,connected_col);

%% Create a graph from the adjacency matrix and extract the coordinates of the buses. 
    g1 = graph(cleanMat, final_name_nodes); %can also take out final_name_nodes

%% Without labels - Force layout

    if ~file.ODSS.useXYcoord
        figure;
        p2 = plot(g1, 'Layout','force','NodeLabel',final_name_nodes);

%         figure;
%         p3 = plot(g1, 'Layout','layered','NodeLabel',final_name_nodes);

        x = get(p2,'XData')';
        y = get(p2,'YData')';
        name = get(p2, 'NodeLabel')';
    end 
    
%% Create a clean nodes table    
node_table = struct;
for iRow = 1:height(summary_nodes_table)
    bus = summary_nodes_table{iRow, 'bus'}{1,1};
    
    [clean_bus, ~] = strtok(bus, '.');
    node_table(iRow).bus = clean_bus;
    node_table(iRow).type = summary_nodes_table{iRow, 'component'}; 

end

%% If bus coordinates are known, extract them and use

if file.ODSS.useXYcoord%any(circuit.buses.x) && file.ODSS.useXYcoord
    rows = strcmp(summary_nodes_table.type, {'node'});
    name = summary_nodes_table{rows, 'name'};
    x = summary_nodes_table{rows, 'x'};
    y = summary_nodes_table{rows, 'y'};  
%     name = circuit.buses.names;
%     x = circuit.buses.x;
%     y = circuit.buses.y;
end
%% See if anything is attached to each bus (if any)
    count = 1;
    x_array = [];
    y_array = [];
    type_array = {};
    name_array = {};
    coord = table;
    
    for iRow = 1:length(name)

        this_name = num2str(name{iRow});
        this_x = x(iRow);
        this_y = y(iRow);        
        n1_row = find(strcmp({node_table.bus}, this_name));

        if isempty(n1_row)
            type_array(count) = {'node'};
            x_array(count) = this_x;
            y_array(count) = this_y;
            name_array(count) = {this_name};
            count = count + 1;
        else
            for iRow2 = 1:length(n1_row)
                this_row = n1_row(iRow2);
                type_array(count) = node_table(this_row).type;
                x_array(count) = this_x;
                y_array(count) = this_y;
                name_array(count) = {this_name};
                count = count + 1;
                
            end
        end
    end
    
    coord.name = name_array';
    coord.node_type = type_array';
    coord.x = x_array';
    coord.y = y_array';
%% ID tuples from the asymmetric matrix (aMatrix is n x n: in the order of bus_names x bus_names)
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
        
%         if strcmp(n1, n2) %can be more than one obj on the same node -- is this neeed
%             overlay = to_row + from_row;
%             matched_row = find(overlay >1);
%             for iRow = 1:length(matched_row)
%                 row = matched_row(iRow); 
%                 node1_final(row,1) = n1;
%                 node2_final(row,1) = n2;
%                 edges(row,1) = line_table{row, 'name'}; 
%                 edge_type(row,1) = line_table{row, 'type'}; 
%             end
%             
%         else
            overlaid = to_row + from_row; % + to_row2 + from_row2;
            matched_row = find(overlaid > 1);
            node1_final(matched_row,1) = n1;
            node2_final(matched_row,1) = n2;
            edges(matched_row,1) = line_table{matched_row, 'name'}; 
            edge_type(matched_row,1) = line_table{matched_row, 'type'};
%         end 
    end 

%% Save the final results to tables    
tuples = table;
tuples.node1 = node1_final;
tuples.node2 = node2_final;
tuples.edges = edges;
tuples.edge_type = edge_type;

%% coordinates for lines
% 
% Lentup=length(tuples.node1);
%     for kk=1:Lentup
%     idxn1=strcmp(tuples.node1{kk},coord.name);
%     idx1=find(idxn1~=0);
%     idxn2=strcmp(tuples.node2{kk},coord.name);
%     idx2=find(idxn2~=0);
%     tuples.node1_x(kk)=coord.x(idx1(1));
%     tuples.node1_y(kk)=coord.y(idx1(1));
%     tuples.node2_x(kk)=coord.x(idx2(1));
%     tuples.node2_y(kk)=coord.y(idx2(1));
%     end


    
%% Create Plot
handles.H=figure(nk);
hold on;
    
%% Plot lines
line_plot.color = [rgb('PaleTurquoise'); rgb('LightPink'); ...
    rgb('RoyalBlue'); rgb('Yellow'); rgb('Green'); rgb('Orange')];
line_plot.type = {'transformer', 'line', 'triplex_line', 'switch', ...
    'regulator'};
legend_name = {'transformer', 'line', 'triplexLine', 'switch',...
    'regulator'};

count = 1;
hg_array = [];
for iType = 1:length(line_plot.type)
    line_rows = find(strcmp(tuples.edge_type, line_plot.type{iType}));
    this_color = line_plot.color(iType,:);
    this_group = [];
    icount = 1;
    for iSeg = 1:length(line_rows)
        row = line_rows(iSeg);
        n1 = tuples.node1(row);
        n2 = tuples.node2(row);

        row_n1 = find(strcmp(coord.name, n1));
        row_n2 = find(strcmp(coord.name, n2));
        % There may be multiple entries of each n1 and n2 in coord,
        % because there may be multiple loads on each bus
        x_plot(1) = coord{row_n1(1), 'x'}; %use the first value (they should all be the same anyway_
        x_plot(2) = coord{row_n2(1), 'x'};
        y_plot(1) = coord{row_n1(1), 'y'};
        y_plot(2) = coord{row_n2(1), 'y'};
        
        % if the x and y coordinates are missing, ignore this iteration            
        %if x_plot(1) == 0 && y_plot(1) == 0 &&  x_plot(2) == 0 && y_plot(2) == 0
        if x_plot(1) == 0 && y_plot(1) == 0   
            continue;
        elseif x_plot(2) == 0 && y_plot(2) == 0
            continue;
        end 

        this_group(icount) = plot(x_plot, y_plot, 'Color', this_color,...
            'LineWidth', 3);
        icount = icount + 1;
    end
    hg = hggroup; % used for creating the  legend
    set(this_group, 'Parent', hg);
    set(hg,'Displayname',legend_name{iType});
    hg_array(count) = hg;
    count = count + 1;
end 
    
%% Plot nodes

node_plot.type = {'node', 'load', 'capacitor'};
node_plot.color = [[0 .8 .8]; [.6 .6 .6]; rgb('Red')];
sz = [40 40 20];

for iType = 1:length(node_plot.type)
    node_rows = find(strcmp(coord.node_type, node_plot.type{iType}));
    this_color = node_plot.color(iType,:);
    this_group = [];
    icount = 1;
    for iNode = 1:length(node_rows)
        x_plot = coord{node_rows(iNode), 'x'};
        y_plot = coord{node_rows(iNode), 'y'};
        
        % if the x and y coordinates are missing, ignore them
        if x_plot(1) == 0 && y_plot(1) == 0
            continue;
        end 

        this_group(icount) = scatter(x_plot, y_plot, sz(iType), 'filled', 'LineWidth',...
            1,'MarkerFaceColor', this_color ,'MarkerEdgeColor', 'blue');        
        icount = icount + 1;
    
    end 
    hg = hggroup;
    set(this_group, 'Parent', hg);
    set(hg, 'Displayname', node_plot.type{iType});
    hg_array(count) = hg;
    count = count + 1;
end
    
%% Plot the starting node
this_group = [];
%CHECK IF THERE IS ALWAYS A SOURCEBUS
% sourcenode_row = stcmp(summary_nodes_table.name, 'sourcebus');
% coord_row = find(strcmp(coord.name, sourcenode_row));
src_node=unique(Feeder.Feeder_Summary.From_Node);
src_len=length(src_node);
for ik=1:src_len
   id=strcmp({nodes_array.parent_node},src_node(ik));
   id1=find(id==1);
   if isempty(id1)
       continue
   else
       break
   end
end
sourcenode_row11 = find(cellfun('isempty',{nodes_array.parent_node}));
if isempty(sourcenode_row11)
sourcenode_row=id1;
source_node1 = nodes_array(sourcenode_row).name;
id2=strcmp({nodes_array.parent_node},source_node1);
id3=find(id2==1);
sourcenode_row=id3;
source_node = nodes_array(sourcenode_row).name;
coord_row = find(strcmp(coord.name, source_node));
sz = 200;
x = coord{coord_row, 'x'};
y = coord{coord_row, 'y'};

% if the x and y coordinates are missing, ignore them
if x(1) ~= 0 && y(1) ~= 0
   this_group = scatter(x,y, sz, 'filled', 'LineWidth',...
        2,'MarkerFaceColor', 'yellow' ,'MarkerEdgeColor', 'red'); 
    
end     

hg = hggroup;

set(this_group, 'Parent', hg);
set(hg, 'Displayname', 'sourcenode');
hg_array(count) = hg;

legend(hg_array);
hold off
else
source_node = nodes_array(sourcenode_row11).name;
coord_row = find(strcmp(coord.name, source_node));
sz = 200;
x = coord{coord_row, 'x'};
y = coord{coord_row, 'y'};

% if the x and y coordinates are missing, ignore them
if x(1) ~= 0 && y(1) ~= 0
   this_group = scatter(x,y, sz, 'filled', 'LineWidth',...
        2,'MarkerFaceColor', 'yellow' ,'MarkerEdgeColor', 'red'); 
    
end     

hg = hggroup;

set(this_group, 'Parent', hg);
set(hg, 'Displayname', 'sourcenode');
hg_array(count) = hg;

legend(hg_array);
hold off
end


% saveas(gcf, fullfile(file.CSVexport,'feeder.jpeg'));
%saveas(gcf, fullfile(char(FinalPath{8,2}{1}),'feeder.jpeg'));
end 