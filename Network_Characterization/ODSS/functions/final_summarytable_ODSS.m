function [summary_nodes_final,summary_lines_final] = final_summarytable_ODSS(file,...
    coord, summary_nodes_table, summary_lines_table)

%% Preliminary line and node summary table has been created. Now, it, additional metrics are calculated and added onto it
    %A. Calculate some additional loads stats
    [~, ~, load_all] = stats_loads_function(file,...
        summary_nodes_table);

    %B. Calculate some additional line stats
    [~, ~, line_all] = stats_lines_function(file, summary_lines_table);

    %C. Calculate some overall summary stats
    [total_components] = stats_overall_function(summary_lines_table,...
        summary_nodes_table);
    disp('Calculated stats');
    
    %D. Save these additional stats into the summary table
    [summary_nodes_final, summary_lines_final] = print_final_metrics(load_all, line_all, ...
         total_components, summary_lines_table, summary_nodes_table, file, coord);
    disp('Printed final summary tables');
end 