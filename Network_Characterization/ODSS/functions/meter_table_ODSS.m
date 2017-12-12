function [meter_summary] = meter_table_ODSS(nodes_array, summary_lines_table)
%% Read in all power measurements. Note: Power entering feeders is measured at the input terminal of xformers
% column_name = 'powers';
% [~, terminalP] = findIndices_3phases_COM(inputsTable, column_name);

nodes_array = struct2table(nodes_array);

%% Calculate power into the feeder  at the substation. If a substation hasn't been defined, find the regulator that the source bus is connected to. 
row_subxfm = find(strcmp(nodes_array.line_type, 'substation'),1);

count = 0;
if isempty(row_subxfm)
   
    % find source bus
    sourcenode_row = find(cellfun('isempty', nodes_array.parent_node));
    source_bus = nodes_array{sourcenode_row, 'name'};
    downstream_node = nodes_array{sourcenode_row, 'downstream_nodes'};
    downstream_node_row = find(strcmp(nodes_array.name, downstream_node{1,1}));
    line_connector = nodes_array{downstream_node_row, 'line_connector'};

    % calculate p into the regulatr connected to the source bus
    terminal_row = find(strcmp(lower(summary_lines_table.name), line_connector));
    P_in = sum(summary_lines_table{terminal_row, {'power_in_A_P', 'power_in_B_P', 'power_in_C_P'}});
    Q_in = sum(summary_lines_table{terminal_row, {'power_in_A_Q', 'power_in_B_Q', 'power_in_C_Q'}});

    meter_summary(1).name = [source_bus{1,1} '_source_bus'];
    meter_summary(1).transformer = line_connector;
    meter_summary(1).measured_P = P_in;
    meter_summary(1).measured_Q = Q_in;
    meter_summary(1).source_meter = 1;    
%     terminal_row = find(strcmp(lower(terminalP.names), line_connector));
%     P_in = sum(terminalP.part1_in(terminal_row,:));
%     Q_in = sum(terminalP.part2_in(terminal_row,:));
% 
%     meter_summary(1).name = [source_bus{1,1} '_source_bus'];
%     meter_summary(1).transformer = line_connector;
%     meter_summary(1).measured_P = P_in;
%     meter_summary(1).measured_Q = Q_in;
%     meter_summary(1).source_meter = 1;

    count = count + 1;
end

%% For each transformer, calculate the power entering the primary winding
xfm_rows = find(strcmp(nodes_array.line_type, 'transformer'));

xfm_rows = [xfm_rows; row_subxfm];

for ixfm = 1:length(xfm_rows)
    this_row = xfm_rows(ixfm);
    this_xfm = nodes_array{this_row, 'line_connector'};
    this_type = nodes_array{this_row, 'line_type'};

%     terminal_row = find(strcmp(lower(terminalP.names), this_xfm));
    terminal_row = find(strcmp(lower(summary_lines_table.name), this_xfm));

    P_in = sum(summary_lines_table{terminal_row, {'power_in_A_P', 'power_in_B_P', 'power_in_C_P'}});
    Q_in = sum(summary_lines_table{terminal_row, {'power_in_A_Q', 'power_in_B_Q', 'power_in_C_Q'}});

%     P_in = sum(terminalP.part1_in(terminal_row,:));
%     Q_in = sum(terminalP.part2_in(terminal_row,:));
    
    is_meter = strcmp(this_type, 'substation');

    meter_summary(ixfm+count).name = this_xfm;
    meter_summary(ixfm+count).transformer = this_xfm;
    meter_summary(ixfm+count).measured_P = P_in;
    meter_summary(ixfm+count).measured_Q = Q_in;
    meter_summary(ixfm+count).source_meter = is_meter;


end

meter_summary = struct2table(meter_summary);
end 