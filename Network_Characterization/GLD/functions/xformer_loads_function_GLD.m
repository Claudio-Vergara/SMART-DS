function [x_load, x_table, nodes_array, meter_summary] =...
    xformer_loads_function_GLD(file, summary_nodes_table,...
    summary_lines_table)

    %% Create loss table
    
    loss_table = summary_lines_table(:,{'name', 'losses_re', 'losses_im'});
    
    
    %% Calc ops load
    [~, ops_load, ~] = stats_loads_function(file,summary_nodes_table);
    %% create a parent array
    nodes_array = struct;
    parent = summary_nodes_table.parent;
    %for each node, find the parent and the parent line
    for iParent = 1:length(parent)
        this_obj = parent(iParent);

        row = find(strcmp(summary_lines_table.name, this_obj));

        if isempty(row) %if this parent obj isn't a line type object (ex. a meter)
            this_parent = this_obj;
            line_row = find(strcmp(summary_lines_table.from, this_obj));
            this_line = summary_lines_table{line_row, 'name'};
            line_type = summary_lines_table{line_row, 'type'};
        else           
            this_parent = summary_lines_table{row, 'from'};
            this_line = summary_lines_table{row, 'name'};
            line_type = summary_lines_table{row, 'type'};
        end 
        
        %% ID line losses
        nodes_array(iParent).name = summary_nodes_table{iParent, 'name'};
        nodes_array(iParent).parent_node = this_parent;
        nodes_array(iParent).line_connector = this_line; %the line is the parent of the node
        nodes_array(iParent).line_type = line_type;        
        
        has_losses = strcmp(line_type, 'underground_line') + ...
            strcmp(line_type, 'overhead_line')+ strcmp(line_type, 'triplex_line')...
            + strcmp(line_type, 'transformer');
        if has_losses > 0
            loss_P = zeros(length(this_line),1);
            loss_Q = zeros(length(this_line),1);
            loss_S = zeros(length(this_line),1);
            for iLine = 1:length(this_line)
                i_this_line = this_line(iLine);
                loss_row = find(strcmp(loss_table.name, i_this_line));
                loss_P(iLine) = loss_table{loss_row, 'losses_re'};
                loss_Q(iLine) = loss_table{loss_row, 'losses_im'};
                loss_S(iLine) = sqrt(loss_P(iLine)^2 + loss_Q(iLine)^2);
            end
            nodes_array(iParent).line_loss_P = sum(loss_P);
            nodes_array(iParent).line_loss_Q = sum(loss_Q);
            nodes_array(iParent).line_loss_S = sum(loss_S);
            
            
        else
            nodes_array(iParent).line_loss_P = 0;
            nodes_array(iParent).line_loss_Q = 0;
            nodes_array(iParent).line_loss_S = 0; 
        end 

    end 

    %% parent array: add in upstream downstream nodes
    for iNode = 1:length(nodes_array)
        from_nodes1 = [];
        from_nodes2 = [];
        to_nodes1 = [];
        to_nodes2 = [];

        this_node = nodes_array(iNode).name;

        %upstream
        keep_rows = find(strcmp(summary_lines_table.to, this_node));
        from_nodes1 = summary_lines_table{keep_rows, 'from'};

        if ~isempty(nodes_array(iNode).parent_node{1,1})
            from_nodes2 = nodes_array(iNode).parent_node;
        end 

        all_from_nodes = unique([from_nodes1; from_nodes2]);
        nodes_array(iNode).upstream_nodes = all_from_nodes;

        %downstream
        keep_rows1 = find(strcmp(summary_lines_table.from, this_node));
        to_nodes1 = summary_lines_table{keep_rows1, 'to'};
        keep_rows2 = find(strcmp([nodes_array.parent_node], this_node));

        if ~isempty(keep_rows2)
            to_nodes2 = nodes_array(keep_rows2).name;
        end 

        all_to_nodes = unique([to_nodes1; to_nodes2]);
        nodes_array(iNode).downstream_nodes = all_to_nodes;
    end
    
    %% Create meter table
    [meter_summary] = meter_table_GLD(nodes_array, summary_nodes_table);

    %% All transformers
    line_type_components = summary_lines_table.name;
    x_only = regexp( line_type_components, 'xfm'); %xfm or sub type
    rows_x = find(not(cellfun('isempty', x_only)));
    num_x = length(rows_x);

    %% ID loads
    %Power consumed by: triplex node, load, triplex load
    node_i = strcmp(summary_nodes_table.component, 'node');
    tri_node_i = strcmp(summary_nodes_table.component, 'triplex_node');
    load_i = strcmp(summary_nodes_table.component, 'load');
    tri_load_i = strcmp(summary_nodes_table.component, 'triplex_load');
    
    load_i = node_i + tri_node_i + load_i + tri_load_i; %added in nodes
    load_rows = find(load_i == 1);   
    load_node.name = summary_nodes_table.name(load_rows);
    load_node.type = summary_nodes_table.component(load_rows);

    % find S
    for iNode = 1:length(load_node.name)
        this_node = load_node.name{iNode};
        this_type = load_node.type{iNode};

        this_row = find(strcmp({ops_load.(this_type).name}, this_node));
        S_total(iNode,1) = ops_load.(this_type)(this_row).S_total;
        
        %%%% CHECK TO MAKE SURE THAT THIS_ROW REFERS TO THE RIGHT ROW
        loads_P_A = summary_nodes_table{this_row, 'power_in_A_P'};
        loads_P_B = summary_nodes_table{this_row, 'power_in_B_P'};
        loads_P_C = summary_nodes_table{this_row, 'power_in_C_P'};

        loads_Q_A = summary_nodes_table{this_row, 'power_in_A_Q'};
        loads_Q_B = summary_nodes_table{this_row, 'power_in_B_Q'};
        loads_Q_C = summary_nodes_table{this_row, 'power_in_C_Q'};
        
        P_total(iNode,1) = loads_P_A + loads_P_B + loads_P_C;
        Q_total(iNode,1) = loads_Q_A + loads_Q_B + loads_Q_C;
    end

    load_node.S_total = S_total;
    load_node.P_total = P_total;
    load_node.Q_total = Q_total;

    %% ID buses with loads
    for iNode = 1:length(nodes_array) %for each node, ID the set of loads downstream from it
        nodes = nodes_array(iNode).downstream_nodes;
        load_S_array = [];
        load_P_array = [];
        load_Q_array = [];
%         type_row_array = [];
        
        for iNode2 = 1:length(nodes) % for each node in the set of downstream nodes for each node
            % if the node has an associated load
            this_node = nodes(iNode2);

            isLoad = strcmp(load_node.name, this_node);

            if sum(isLoad) > 0 
                this_S = load_node.S_total(isLoad);
                this_P = load_node.P_total(isLoad);
                this_Q = load_node.Q_total(isLoad);
            else
                this_S = 0;
                this_P = 0;
                this_Q = 0;
            end 
            load_S_array = [load_S_array this_S];
            load_P_array = [load_P_array this_P];
            load_Q_array = [load_Q_array this_Q];

        end

        nodes_array(iNode).downstream_S_array = load_S_array;
        nodes_array(iNode).downstream_P_array = load_P_array;
        nodes_array(iNode).downstream_Q_array = load_Q_array;
    end 

    %% Find starting node -- (swing bus) assuming no substations
    sourcenode_row = find(cellfun('isempty',[nodes_array.parent_node]));
    
    
    
    %% Assume the inputs do not specify a substation
    num_x = num_x + 1;

    %% Start Creating Tree
    for iX = 1:num_x

       if iX == num_x %for the last iteration, run through the entire feeder
            % find first this_row
            this_row = sourcenode_row;
            x_fieldName = 'startnode';       
            thisX = {'added_startnode'}; %{'source_node'};
            x_type = {'start_node'};
            first_node = nodes_array(this_row).name;
       else
            this_row = rows_x(iX); %the row where the transformer is locate        
            x_fieldName = ['xfm' num2str(iX)];
            thisX = summary_lines_table.name(this_row);
            x_type = summary_lines_table.type(this_row);
            first_node = summary_lines_table.to(this_row);
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
        else 
            first_S = load_node.S_total(row);
            first_Q = load_node.Q_total(row);
            first_P = load_node.P_total(row);
        end 
        all_ds_nodes = first_node;
        all_ds_S_array = first_S;
        all_ds_P_array = first_P;
        all_ds_Q_array = first_Q;

        %ID downstream nodes
        while 1
            S_name = [x_fieldName '_downstream_S'];
            P_name = [x_fieldName '_downstream_P'];
            Q_name = [x_fieldName '_downstream_Q'];
            branch_name = [x_fieldName '_branchlevel'];
            line_name = [x_fieldName '_line'];
            line_type = [x_fieldName '_linetype'];
            node_type = [x_fieldName '_nodetype'];
            line_loss_P_name = [x_fieldName '_lineloss_P'];
            line_loss_Q_name = [x_fieldName '_lineloss_Q'];
            line_loss_S_name = [x_fieldName '_lineloss_S'];
            
            nodes = all_ds_nodes;
            S_nodes = all_ds_S_array;
            P_nodes = all_ds_P_array;
            Q_nodes = all_ds_Q_array;


            %clear this array to start again
            all_ds_nodes = [];
            all_ds_S_array = [];
            all_ds_P_array = [];
            all_ds_Q_array = [];
           %for each node in the downstream array, ID its the downstream array
            for iNode = 1:length(nodes)
                % for each node, ID downstream nodes
                this_node = nodes(iNode);
                this_S = S_nodes(iNode);
                this_P = P_nodes(iNode);
                this_Q = Q_nodes(iNode);
                
                %node_type 
                ntype_row = strcmp(summary_nodes_table.name, this_node);
                this_type = summary_nodes_table{ntype_row, 'type'};
                
      
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
                
                all_ds_nodes = [all_ds_nodes; downstream_nodes];
                all_ds_S_array = [all_ds_S_array downstream_S_array];
                all_ds_P_array = [all_ds_P_array downstream_P_array];
                all_ds_Q_array = [all_ds_Q_array downstream_Q_array];
                i = i + 1;

            end 

           if isempty(all_ds_nodes)
               break;
           end 

           ibranch = ibranch + 1;
        end

        %% Create x_load summary table
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
            
            meter_nodes = regexp([x_table(iX).feeder.(node_type)], 'meter');%gets only non empty rows
            non_meter_nodes = find(cellfun('isempty', meter_nodes));
            meter_nodes = find(not(cellfun('isempty', meter_nodes)));
            x_load(iX).nNodes = length(non_meter_nodes); %# of nodes
                         
            S_loads = [x_table(iX).feeder.(S_name)];
            S_loads(meter_nodes) = []; % remove meter rows
            x_load(iX).nLoads = length(find(S_loads ~= 0)); %# nodes with loads
            
            
        else
            x_load(iX).total_S  = 0;
            x_load(iX).total_P = 0;
            x_load(iX).total_Q = 0;
            x_load(iX).nNodes = 0;
            x_load(iX).nLoads = 0;
        end

        if isfield(x_table(iX).feeder, line_name)       
            x_load(iX).lines_connectors = [x_table(iX).feeder.(line_name)];
            x_load(iX).line_types = [x_table(iX).feeder.(line_type)];
            x_load(iX).lineloss_P = sum([x_table(iX).feeder.(line_loss_P_name)]);
            x_load(iX).lineloss_Q = sum([x_table(iX).feeder.(line_loss_Q_name)]);
            x_load(iX).lineloss_S = sum([x_table(iX).feeder.(line_loss_S_name)]);            
        else
            x_load(iX).lines_connectors = [];
            x_load(iX).lines_types = [];
            x_load(iX).lineloss_P = [];
            x_load(iX).lineloss_Q = [];
            x_load(iX).lineloss_S = [];
        end
        xfm_row = find(strcmp(summary_lines_table.name, thisX{1,1}));
        xfm_capacity = summary_lines_table{xfm_row, 'cont_rating_amps_or_kVA'};
        x_load(iX).xfm_capacity = xfm_capacity;

    end
end 
