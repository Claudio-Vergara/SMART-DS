function [summary_nodes_final, summary_lines_final, opsLoad] = final_summarytables_GLD(file, summary_lines_table, summary_nodes_table, coord)


%% add in losses
%% calculate line type losses
[~, summary_lines_table, summary_nodes_table]...
    = losses_GLD(file, summary_lines_table, summary_nodes_table);
%% calculates additional metrics and adds onto the summary tables
[~, opsLoad, load_all] = stats_loads_function(file,...
    summary_nodes_table);

[~, ~, line_all] = stats_lines_function(file,...
    summary_lines_table);

[total_components] = stats_overall_function(summary_lines_table,...
    summary_nodes_table);

%% prints and saves
% [summary_nodes_final, summary_lines_final] = print_final_metrics(load_all,...
%     line_all, total_components, summary_lines_table, summary_nodes_table, file);
[summary_nodes_final, summary_lines_final] = print_final_metrics(load_all, line_all, ...
     total_components, summary_lines_table, summary_nodes_table, file, coord);
 
end 