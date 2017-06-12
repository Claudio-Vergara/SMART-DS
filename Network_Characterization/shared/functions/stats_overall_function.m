function [total_components] = stats_overall_function(summary_lines_table, ...
    summary_nodes_table)
% stats_overall_function
% Description: makes a count of each element subtype

% Arguments: 
% summary_lines_table:Relevant data pulled from input and output files...
% for line type components (transformers, lines, fuses, and their
% subtypes). This refers to the preliminary summary_lines_table
% summary_nodes_table: Relevant data pulled from input and output files...
% for line type components (loads, capacitors). This refers to the...
% preliminary summary_lines_table

% Outputs:
% total_components: holds the count of each subtype

%% Counts  each component

%% lines summary table
    type = summary_lines_table.type;
    unique_list = unique(type);
    clean_xfm_list = [];
    for iComp = 1:length(unique_list)
        item =  unique_list{iComp};
        if strcmp(item, 'switch')
            item = 'switch_type';
        end 
        rows = strcmp(type, item);

        if strcmp(item, 'transformer')
            list_xfm = summary_lines_table.type(rows);

            for i_xfm = 1:length(list_xfm)
                item = list_xfm{i_xfm}(1:3);%keep only first 3 letters
                clean_xfm_list = [clean_xfm_list; {item}];
            end 

            unique_xfm = unique(clean_xfm_list);

            for i_unique_xfm = 1:length(unique_xfm)
                item = unique_xfm{i_unique_xfm};
                this_xfm = unique_xfm(i_unique_xfm);
                rows_xfm = regexp(list_xfm, this_xfm);
                not_empty = find(not(cellfun('isempty',rows_xfm)));
                num_comp = length(not_empty);
                total_components.(['xfm_' item]) = num_comp;
            end 
        else 
            num_comp = sum(rows);
            total_components.(item) = num_comp;
        end 
    end 
%% nodes summary table
    type = summary_nodes_table.type;
    unique_list = unique(type);

    for iComp = 1:length(unique_list)
        item =  unique_list{iComp};
        rows = strcmp(type, item);
        num_comp = sum(rows);
        total_components.(item) = num_comp;

    end 
end 