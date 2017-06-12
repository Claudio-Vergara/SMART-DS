function [summary] = table_contents(file, network)
summary = struct;
summary.ID = '1'; 
summary.name = file.caseName;
summary.format = file.format;

%% Create summary structure
    summary.MV = num2str([network.MV.V_levels.MV]);
    summary.LV = num2str([network.MV.V_levels.LV]);
    summary.n_MV_nodes = num2str(network.MV.nNodes.MV);
    summary.n_LV_nodes = num2str(network.MV.nNodes.LV);
    summary.n_MV_loads = num2str(network.MV.nLoads.MV);
    summary.n_LV_loads = num2str(network.MV.nLoads.LV);
    summary.TxSubstations = num2str(1); %update this later 
    summary.HVMV_xfms = num2str(0); %update this later
    summary.MVLV_xfms = num2str(network.MV.nLVFeeders);
    summary.total_P = num2str(network.MV.P_total.MV + network.MV.P_total.LV);
    summary.total_Q = num2str(network.MV.Q_total.MV + network.MV.Q_total.LV);
    summary.total_S = num2str(network.MV.S_total.MV + network.MV.S_total.LV);
    summary.mean_line_util = num2str(network.MV.mean_line_UR);
    summary.total_losses = num2str(0);
    summary.OL_len = num2str(network.MV.UL_len);
    summary.UL_len = num2str(network.MV.OL_len);
    summary.triplex_len = num2str(network.MV.triplex_len);
    summary.MV_len = num2str(network.MV.length.MV);
    summary.LV_len = num2str(network.MV.length.LV);
    summary.n_branches = num2str(network.MV.n_branches);
    summary.percent_loss = num2str(network.MV.percent_loss);
    
    % new additions from EU paper
    summary.nLVconsumers_perMV = num2str(network.MV.nLV_perMV);
    summary.lenLV_perLVconsumer = num2str(network.MV.triplex_len/...
        network.MV.nLoads.LV);
    summary.nLVconsumers_perMVLVxfm = num2str(network.MV.nLoads.LV/...
        network.MV.nLVFeeders);
    summary.LV_ULratio = {'no_info'};
    summary.MVLVcap_perLVconsumer = num2str(network.MV.MVLV_xfm_capacity/...
        network.MV.nLoads.LV);
    summary.MVlen_MVsupp_pt = num2str(network.MV.MVcircuit_perMVsupply);
    summary.MV_ULratio = {'no_info'};
    summary.nMVsupp_perHVMVxfm = num2str(network.MV.MV_supplypts_HVMVSS);
    summary.capacity_MVLVxfm = num2str(network.MV.MVLV_xfm_capacity);

%% Topology metrics
    summary.top_ave_deg = network.topology.ave_deg; 
    summary.top_diameter = network.topology.diameter;
    summary.top_char_path_len = network.topology.char_path_len;
    summary.clust_coeff = mean(network.topology.clust_coeff);
    summary.top_deg_assort = network.topology.deg_assort;

%% Find next empty line in CSV
    if exist( fullfile(file.CSVexport, 'table_of_contents.xls'), 'file')
        written = readtable(fullfile(file.CSVexport, 'table_of_contents.xls'));
        end_row = size(written, 1) + 1;
        start_corner = ['A' num2str(end_row + 1)];
    else
        end_row = 0;
        start_corner = 'A1';
    end

%% if no lines previously in document, write header
    if end_row == 0
        write_header = 1;
    else
        write_header = 0;
    end 
    
    if isempty(summary.LV), summary.LV='NA'; end

    table_summary = struct2table(summary);
    writetable(table_summary, fullfile(file.CSVexport, 'table_of_contents.xls'),...
        'WriteVariableNames', write_header, 'Range', start_corner);
    
end 