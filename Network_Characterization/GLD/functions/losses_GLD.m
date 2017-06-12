function [loss_table, summary_lines_table, summary_nodes_table]...
    = losses_GLD(file, summary_lines_table, summary_nodes_table)
%% Pulls out the Losses associated with each line or transformer
    
%% Losses
OL_table = table;
UL_table = table;
tri_table = table;
xfm_table = table;
% read in the line losses 
% Overhead lines 
    if exist(file.loss_OL_re, 'file')
        [num_re, strings] = xlsread(file.loss_OL_re);
        names = strings(9,2:end);
        OL_table.name = names';
        OL_table.loss_re = num_re(1,:)';

        [num_im, ~] = xlsread(file.loss_OL_im);
        OL_table.loss_im = num_im(1,:)';
    else
        OL_table.name = {'empty'};
        OL_table.loss_re = 0;
        OL_table.loss_im = 0;
    end 
% Underground lines 
    if exist(file.loss_UL_re, 'file')
        [num_re, strings] = xlsread(file.loss_UL_re);
        names = strings(9,2:end);
        UL_table.name = names';
        UL_table.loss_re = num_re(1,:)';

        [num_im, ~] = xlsread(file.loss_UL_im);
        UL_table.loss_im = num_im(1,:)';
    else
        UL_table.name = {'empty'};
        UL_table.loss_re = 0;
        UL_table.loss_im = 0;
    end 
% Triplex Lines
    if exist(file.loss_tri_re, 'file')
        [num_re, strings] = xlsread(file.loss_tri_re);
        names = strings(9,2:end);
        tri_table.name = names';
        tri_table.loss_re = num_re(1,:)';

        [num_im, ~] = xlsread(file.loss_tri_im);
        tri_table.loss_im = num_im(1,:)';
    else
        tri_table.name = {'empty'};
        tri_table.loss_re = 0;
        tri_table.loss_im = 0;
    end 
% Transformer
    if exist(file.loss_xfm_re, 'file')
        [num_re, strings] = xlsread(file.loss_xfm_re);
        names = strings(9,2:end);
        xfm_table.name = names';
        xfm_table.loss_re = num_re(1,:)';

        [num_im, ~] = xlsread(file.loss_xfm_im);
        xfm_table.loss_im = num_im(1,:)';
    else
        xfm_table.name = {'empty'};
        xfm_table.loss_re = 0;
        xfm_table.loss_im = 0;
    end

    
    %% combine losses into one table
    
    loss_table = outerjoin(OL_table, UL_table, 'MergeKeys', 1);
    loss_table = outerjoin(loss_table, tri_table, 'MergeKeys', 1);
    loss_table = outerjoin(loss_table, xfm_table, 'MergeKeys', 1);
    %% add losses to summary table
    n_summ_table_lines = size(summary_lines_table,1);
    n_summ_table_nodes = size(summary_nodes_table,1);
    summary_lines_table.losses_re = zeros(n_summ_table_lines,1);    
    summary_lines_table.losses_im = zeros(n_summ_table_lines,1);
    
    %ignore losses from node type objects
    summary_nodes_table.losses_re = zeros(n_summ_table_nodes,1);
    summary_nodes_table.losses_im = zeros(n_summ_table_nodes,1);

    %pull losses for each line type object into the summary table
    for i= 1:size(loss_table,1)
        name = loss_table.name{i};
        i_name = regexp(name, summary_lines_table.name);
        index = not(cellfun('isempty', i_name));
        summary_lines_table{index, 'losses_re'} = loss_table{i, 'loss_re'};
        summary_lines_table{index, 'losses_im'} = loss_table{i, 'loss_im'};
    end 
    
    
end