function [x_load, x_table, nodes_array, meter_summary] =...
    xformer_loads_ODSS(file, summary_nodes_table, summary_lines_table)
%% preparing data for identifying downstream transformers
% Create line table
remove_switch_same = 1; % need to remove to avoid looping
line_table = create_line_table(file, summary_lines_table,...
    remove_switch_same);

%% create a parent array
nodes_array = create_nodesarray_COM(line_table, summary_nodes_table, summary_lines_table);

%% create meter table
[meter_summary] = meter_table_ODSS(nodes_array, summary_lines_table);
%ID transformers
%all x
i_x_rows = regexp(line_table.name, 'transformer');
x_rows = find(not(cellfun('isempty', i_x_rows)));
name_x = line_table.name(x_rows);

%all regulators
x_reg = regexp( name_x,'reg');
rows_x_reg = find(not(cellfun('isempty', x_reg)));
rows_x_not_reg_final = x_rows(find(cellfun('isempty', x_reg)));

%num of xformers that aren't reg
num_x = length(x_rows) - length(rows_x_reg);    

%ID loads
% inputsTable = struct2table(circuit.element);
% [~, p_terminal] = findIndices_3phases_COM(inputsTable, 'powers');

%Power consumed by: triplex node, load, triplex load
load_rows = find(strcmp(summary_nodes_table.component, 'load'));
load_node.name = summary_nodes_table.name(load_rows);
load_node.type = summary_nodes_table.component(load_rows);

summary_nodes_buses = strtok(summary_nodes_table.bus, '.');
%% find S
tic;

for iNode = 1:length(load_node.name)
    this_node = load_node.name{iNode};
    this_type = load_node.type{iNode};

    this_row = find(strcmp(summary_nodes_table.name, this_node));
    this_bus(iNode,1) = {summary_nodes_buses{this_row}};
    
    P_total(iNode,1) = sum(summary_nodes_table{this_row,...
        {'power_in_A_P', 'power_in_B_P','power_in_C_P'}});
    Q_total(iNode,1) = sum(summary_nodes_table{this_row,...
        {'power_in_A_Q', 'power_in_B_Q','power_in_C_Q'}});
    S_total(iNode,1) = sqrt(P_total(iNode,1)^2 + Q_total(iNode,1)^2);
    
%     loads_P_A = p_terminal.part1_in(this_row,1);
%     loads_P_B = p_terminal.part1_in(this_row,2);
%     loads_P_C = p_terminal.part1_in(this_row,3);
% 
%     loads_Q_A = p_terminal.part2_in(this_row,1);
%     loads_Q_B = p_terminal.part2_in(this_row,2);
%     loads_Q_C = p_terminal.part2_in(this_row,3);
%     
%     P_total(iNode,1) = loads_P_A + loads_P_B + loads_P_C;
%     Q_total(iNode,1) = loads_Q_A + loads_Q_B + loads_Q_C;
%     S_total(iNode,1) = sqrt(P_total(iNode,1)^2 + Q_total(iNode,1)^2);
end
toc;

load_node.bus = this_bus;
load_node.S_total = S_total;
load_node.P_total = P_total;
load_node.Q_total = Q_total;

%% ID buses with loads
for iNode = 1:length(nodes_array) %for each node, ID the set of loads downstream from it
    nodes = nodes_array(iNode).downstream_nodes;
    load_S_array = [];
    load_P_array = [];
    load_Q_array = [];
    load_type_array = [];
    for iNode2 = 1:length(nodes) % for each node in the set of downstream nodes for each node
        % if the node has an associated load
        this_node = nodes(iNode2);
        isLoad = find(strcmp(load_node.bus, this_node));

        if sum(isLoad) > 0 
            this_S = load_node.S_total(isLoad);
            this_P = load_node.P_total(isLoad);
            this_Q = load_node.Q_total(isLoad);
            this_type = {'load'};
        else
            this_S = 0;
            this_P = 0;
            this_Q = 0;
            this_type = {'node'};
        end
        
        load_S_array = [load_S_array; sum(this_S)];
        load_P_array = [load_P_array; sum(this_P)];
        load_Q_array = [load_Q_array; sum(this_Q)];
        load_type_array = [load_type_array; this_type];
   
    end
    nodes_array(iNode).downstream_S_array = load_S_array;
    nodes_array(iNode).downstream_P_array = load_P_array;
    nodes_array(iNode).downstream_Q_array = load_Q_array;
    nodes_array(iNode).downstream_type_array = load_type_array;
end 

%% Find starting node - this is the one without a parent node
sourcenode_row = find(cellfun('isempty',{nodes_array.parent_node}));
    
    
%% Check to see if a substation is specified. If specified, remove it from the list to iterate through to avoid repitition (this is because for the last iteration, the downstream tree will be iterated through starting from the source node)
is_subxfm = find(strcmp(line_table.type, 'substation'));

if isempty(is_subxfm)
    add_sourcenode = 1;
    num_x = num_x + 1;
else
    add_sourcenode = 0;
end 
%% Begin creating the transformer tree: 
% It wil cycle through the transformers. For each, it identifies the buses immediately downstream of the transformer (this is branch level 1), and the loads connected to these buses and the lines connected to these buses . It then finds the buses immediately downstream of those buses (which make up branch level 2), and so forth, until it reaches a point where there are no more downstream buses. 
% Note: nodes and buses are two terms used interchangeably in the code, but technically, ODSS describes buses as having several nodes. A bus represents an intersection between two lines or line types. 
S_name = 'node_S';
P_name = 'node_P';
Q_name = 'node_Q';
branch_name = 'branchlevel';
line_name = 'line';
line_type = 'linetype';
node_type = 'nodetype';
line_loss_P_name = 'lineloss_P';
line_loss_Q_name = 'lineloss_Q';
line_loss_S_name = 'lineloss_S'; 

%% Cycle through each transformer
for iX = 1:num_x
 tic;  
 
   if iX == num_x && add_sourcenode %for the last iteration, the function will run through the entire feeder
        disp('On sourcenode iteration');
        % find first this_row
        this_row = sourcenode_row;
        x_fieldName = 'startnode';       
        thisX = {'added_startnode'}; 
        x_type = {'start_node'};
        first_node = nodes_array(this_row).name;
   else
        this_row = rows_x_not_reg_final(iX); %the row where the transformer is locate        
        x_fieldName = ['xfm' num2str(iX)];
        thisX = line_table.name(this_row);
        x_type = line_table.type(this_row);
        first_node = line_table.to(this_row);
   end

    x_table(iX).feeder(1).(x_fieldName) = thisX; %xformer_name
    x_table(iX).feeder(2).(x_fieldName) = x_type; %xfromer type 
    i = 3;
    ibranch = 1;
    %start with the first node
    row = find(strcmp([load_node.name], first_node));
    % if the first_node is a meter (or anything other than a load
    % type), S = 0
    if isempty(row)
        first_S = 0;
        first_Q = 0;
        first_P = 0;
        first_type = {'node'};
    else 
        first_S = load_node.S_total(row);
        first_Q = load_node.Q_total(row);
        first_P = load_node.P_total(row);
        first_type = {'node'};
    end 
    all_ds_nodes = first_node;
    all_ds_S_array = first_S;
    all_ds_P_array = first_P;
    all_ds_Q_array = first_Q;
    all_ds_type_array = first_type;

    %ID nodes downstream of the transformer, one branch level at a time
    while 1
       
        nodes = all_ds_nodes;
        S_nodes = all_ds_S_array;
        P_nodes = all_ds_P_array;
        Q_nodes = all_ds_Q_array;
        type_nodes = all_ds_type_array;
        
        %clear this array to start again
        all_ds_nodes = [];
        all_ds_S_array = [];
        all_ds_P_array = [];
        all_ds_Q_array = [];
        all_ds_type_array = [];
       
        
       %for each node in the downstream array, ID its the downstream array
        for iNode = 1:length(nodes)
            % for each node, ID downstream nodes
            this_node = nodes(iNode);
            this_S = S_nodes(iNode);
            this_P = P_nodes(iNode);
            this_Q = Q_nodes(iNode);
            this_type = type_nodes(iNode);
         

            x_table(iX).feeder(i).(x_fieldName) = this_node;
            x_table(iX).feeder(i).(node_type) = this_type;
            x_table(iX).feeder(i).(S_name) = this_S;
            x_table(iX).feeder(i).(P_name) = this_P;
            x_table(iX).feeder(i).(Q_name) = this_Q;         
            
            x_table(iX).feeder(i).(branch_name) = ibranch;
            row = find(strcmp([nodes_array.name], this_node));

            x_table(iX).feeder(i).(line_name) = nodes_array(row).line_connector;
            x_table(iX).feeder(i).(line_type) = nodes_array(row).line_type;
            x_table(iX).feeder(i).(line_loss_P_name) = nodes_array(row).line_loss_P;
            x_table(iX).feeder(i).(line_loss_Q_name) = nodes_array(row).line_loss_Q;
            x_table(iX).feeder(i).(line_loss_S_name) = nodes_array(row).line_loss_S;         

            downstream_nodes = nodes_array(row).downstream_nodes;
            downstream_S_array = nodes_array(row).downstream_S_array;
            downstream_P_array = nodes_array(row).downstream_P_array;
            downstream_Q_array = nodes_array(row).downstream_Q_array;
            downstream_type_array = nodes_array(row).downstream_type_array;
            

            all_ds_nodes = [all_ds_nodes; downstream_nodes];
            all_ds_S_array = [all_ds_S_array; downstream_S_array];
            all_ds_P_array = [all_ds_P_array; downstream_P_array];
            all_ds_Q_array = [all_ds_Q_array; downstream_Q_array];
            all_ds_type_array = [all_ds_type_array; downstream_type_array];

            i = i + 1;

        end 
       % break when there are no more downstream nodes
       if isempty(all_ds_nodes)
           break;
       end 

       ibranch = ibranch + 1;
    end

% Create x_load summary table: This is a summary of the load and branch level information held in x_table for each transformer.
    %  if xformer iX has branches and loads, then add these to the load
    %  table

    x_load(iX).name = thisX;
    x_load(iX).type = x_type;

    if isfield(x_table(iX).feeder, branch_name)
        x_load(iX).branch_level = max([x_table(iX).feeder.(branch_name)]);
    else
        x_load(iX).branch_level = 0;
    end

    if isfield(x_table(iX).feeder, S_name)
        x_load(iX).total_S = sum([x_table(iX).feeder.(S_name)]);
        x_load(iX).total_P = sum([x_table(iX).feeder.(P_name)]);
        x_load(iX).total_Q = sum([x_table(iX).feeder.(Q_name)]);
        x_load(iX).nNodes = length([x_table(iX).feeder.(node_type)]);
        S_loads = [x_table(iX).feeder.(S_name)];
        x_load(iX).nLoads  = length(find(S_loads ~= 0));
        
    else
        x_load(iX).total_S  = 0;
        x_load(iX).total_P = 0;
        x_load(iX).total_Q = 0;
        x_load(iX).nNodes = 0;
        x_load(iX).nLoads = 0;            
    end

    if isfield(x_table(iX).feeder, line_name) 
        
        x_load(iX).lines_connectors = {x_table(iX).feeder.(line_name)}';
        x_load(iX).line_types = {x_table(iX).feeder.(line_type)}';
        
        empty_line_conn = (cellfun('isempty',x_load(iX).lines_connectors));
        x_load(iX).lines_connectors(empty_line_conn) = [];
        
        empty_line_types = (cellfun('isempty',x_load(iX).line_types));
        x_load(iX).line_types(empty_line_conn) = [];
                
        x_load(iX).lineloss_P = sum([x_table(iX).feeder.(line_loss_P_name)]);
        x_load(iX).lineloss_Q = sum([x_table(iX).feeder.(line_loss_Q_name)]);
        x_load(iX).lineloss_S = sum([x_table(iX).feeder.(line_loss_S_name)]);             
    else
        x_load(iX).lines = [];
        x_load(iX).lines_types = [];
        x_load(iX).lineloss_P = [];
        x_load(iX).lineloss_Q = [];
        x_load(iX).lineloss_S = [];            
    end
    
%     xfm_row = find(strcmp(lower(inputsTable.name), thisX{1,1}));
%     xfm_capacity = inputsTable{xfm_row, 'kVA'};
    xfm_row = (strcmp(lower(summary_lines_table.name), thisX{1,1}));
    xfm_capacity = summary_lines_table{xfm_row, 'cont_rating_amps_or_kVA'};
    x_load(iX).xfm_capacity = xfm_capacity;
toc
end

end 