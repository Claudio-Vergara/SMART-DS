function [summary_nodes_table, summary_lines_table, powerFlow] = create_summarytables_GLD(file)

%% creates data structure from xml file
[outputsTable, powerFlow] = makeTable_function(file);

%% pulls raw data into summary tables
summary_lines_table = summarytable_lines_GLD(outputsTable, powerFlow);
summary_nodes_table = summarytable_nodes_GLD(outputsTable);


end