function [network] = agg_metrics_shared(file, summary_nodes_table, meter_summary,...
    summary_lines_table, x_load, a_matrix_non)


%% Assuming no HV network and only one MV network per feeder.
% First, calculate metrics/stats specific to the MV network
    iMV = 1;
    %% Loads
    %% count of MV loads and LV loads
    i_loads_1 = strcmp([summary_nodes_table.component], 'load');
    i_loads_2 = strcmp([summary_nodes_table.component], 'triplex_node');
    i_loads_3 = strcmp([summary_nodes_table.component], 'triplex_load');
    i_loads_4 = strcmp([summary_nodes_table.component], 'node');

    i_loads = find(i_loads_1 + i_loads_2 + i_loads_3 + i_loads_4);
    
    loads_S = summary_nodes_table{i_loads, 'S_total'};
    loads_nomV = summary_nodes_table{i_loads, 'nominalV'};
    
    loads_P_A = summary_nodes_table{i_loads, 'power_in_A_P'};
    loads_P_B = summary_nodes_table{i_loads, 'power_in_B_P'};
    loads_P_C = summary_nodes_table{i_loads, 'power_in_C_P'};
    loads_P_total = loads_P_A + loads_P_B + loads_P_C;
    
    loads_Q_A = summary_nodes_table{i_loads, 'power_in_A_Q'};
    loads_Q_B = summary_nodes_table{i_loads, 'power_in_B_Q'};
    loads_Q_C = summary_nodes_table{i_loads, 'power_in_C_Q'};
    loads_Q_total = loads_Q_A + loads_Q_B + loads_Q_C;
    
    %Change the units so they are the same
    if file.data_type == 2 % ODSS
        MV_loads = loads_nomV(loads_nomV > 0.650);
        S_MV_loads = loads_S(loads_nomV > 0.650);
        P_MV_loads = loads_P_total(loads_nomV > 0.650);
        Q_MV_loads = loads_Q_total(loads_nomV > 0.650);
%         nodes_meanV = circuit.buses.mean_V_node';
        nodes_rows = strcmp(summary_nodes_table.type, 'node');
        nodes_meanV = table2array(summary_nodes_table(nodes_rows, 'nominalV'));
        MV_rows = find(nodes_meanV > 0.650);
        MV_nodes = nodes_meanV(MV_rows);
        %% count of MV loads and S total of MV loads
        n_nodes_MV = length(MV_nodes); %all nodes
        n_loads_MV = length(MV_loads); %nodes with loads > 0
        S_total_MV = sum(S_MV_loads);
        P_total_MV = sum(P_MV_loads);
        Q_total_MV = sum(Q_MV_loads);        
        
    else
        MV_nodes = loads_nomV(loads_nomV > 0.650); % nodes
        S_MV_loads = loads_S(loads_nomV > 0.650);
        P_MV_loads = loads_P_total(loads_nomV > 0.650);
        Q_MV_loads = loads_Q_total(loads_nomV > 0.650);
        %% count of MV loads and S total of MV loads
        n_nodes_MV = length(MV_nodes); %all nodes
        n_loads_MV = length(find(S_MV_loads ~= 0)); %nodes with loads > 0
        S_total_MV = sum(S_MV_loads);
        P_total_MV = sum(P_MV_loads);
        Q_total_MV = sum(Q_MV_loads);
    end 

    
    %% Voltage level of the MV feeder
    %  Note: substations and xfmers only provide readings of the secondary kV.
    if file.data_type == 2
%         ss_rows = find(strcmp(inputsTable.type, 'substation'));
%         x_rows = find(strcmp(inputsTable.type, 'transformer'));
%         all_x_rows = [ss_rows; x_rows];
%         V_levels_x = inputsTable{all_x_rows, 'kV'};
        ss_rows = find(strcmp(summary_lines_table.type, 'substation'));
        x_rows = find(strcmp(summary_lines_table.type, 'transformer'));
        all_x_rows = [ss_rows; x_rows];
        V_levels_x = summary_lines_table{all_x_rows, 'nominalV'}; %nominal V for xfmrs in ODSS should be on the secondary side
          
        V_levels = V_levels_x;
        MV_levels = V_levels(V_levels > 0.650)';
        LV_levels = V_levels(V_levels < 0.650)';

        %% HV source: Vsource provides the HV?
%         vsource_rows = find(strcmp(inputsTable.type, 'vsource'));
%         V_levels_vsource = inputsTable{vsource_rows, 'basekV'}; %need to save this
    
    else
        MV_levels = unique(MV_nodes);
        LV_levels = [];
    end 
    %% MV line stats
    all_line_types = summary_lines_table{:, 'component'};
    switches = regexp(summary_lines_table{:, 'type'}, 'sw');

    rename = find(not(cellfun('isempty', switches)));
    all_line_types(rename) = {'switch'};
    
    irow_lines = regexp(all_line_types, 'line');
    row_lines = find(not(cellfun('isempty', irow_lines)));
    
    %% ID MV lines
    lines_nomV = abs(summary_lines_table{row_lines, 'nominalV'});
    lines_len = summary_lines_table{row_lines, 'length'};

    MV_lines = lines_nomV(lines_nomV > 0.650); %assuming 0.650 is the cutoff 
    MV_len = lines_len(lines_nomV > 0.650);
    lines_array_MV = summary_lines_table{(lines_nomV > 0.650), 'name'};


    %% line length by feeder (all MV lines)
    length_MV = sum(MV_len);

    %% line length by phase (MV) 
    line_phase = zeros(length(lines_array_MV),1);
    line_length = zeros(length(lines_array_MV),1);
    for iLine = 1:length(lines_array_MV)
        line_name = lines_array_MV{iLine};
        line_row = find(strcmp(summary_lines_table.name, line_name));
        line_length(iLine) = summary_lines_table{line_row, 'length'};
       
        if file.data_type == 1 
            line_phase(iLine) = summary_lines_table{line_row, 'phasecount'}{1,1};% GLD -- FIGURE OUT THE SOURCE OF THIS ISSUE AND FIX IT
        else
            line_phase(iLine) = summary_lines_table{line_row, 'phasecount'};
        end
    end 
    len_phase1_MV = sum(line_length(line_phase == 1));
    len_phase2_MV = sum(line_length(line_phase == 2));
    len_phase3_MV = sum(line_length(line_phase == 3));

    %% Length of Line by Overhead vs. Underground in the medium network
    if file.data_type == 1 % for GLD
        i_UL = strcmp([summary_lines_table.component], 'underground_line');
        UL_len = summary_lines_table{i_UL, 'length'};
        sum_UL_len = sum(UL_len);

        i_OL = strcmp([summary_lines_table.component], 'overhead_line');
        OL_len = summary_lines_table{i_OL, 'length'};
        sum_OL_len = sum(OL_len);

    else % for ODSS
        sum_UL_len = NaN;
        sum_OL_len = NaN;

    end
    
    %% Percentage Loss (power)
    % measured P at the source meter
    source_row = find(meter_summary.source_meter == 1);
    measured_P = meter_summary{source_row, 'measured_P'};

    % Losses in lines and xformer - feeder
    feeder_row = find(strcmp([x_load.type], 'start_node'));
    if isempty(feeder_row)
        feeder_row = find(strcmp([x_load.type], 'substation'));
    end
    
    losses_feeder = x_load(feeder_row).lineloss_P; 
    percent_loss = losses_feeder/measured_P*100;
    
%% Caculate LV specific Metrics: cycle through each MV/LV tansformer, assuming that it is the starting point of a LV network
    if file.data_type == 2
        MVLV_x = find(strcmp([x_load.type], 'transformer'));    
    else
        i_MVLV_xformers = regexp([x_load.name], 'xfm');
        MVLV_x = find(not(cellfun('isempty', i_MVLV_xformers)));
    end
    
    array_2ndV = [];   
    
    %for each LV feeder
    for iLV = 1:length(MVLV_x) 
        row = MVLV_x(iLV);
        name = x_load(row).name{1,1}; %xformer name

        %% ID lines downstream of xfm - call one xformer at a time
        lines_array = x_load(row).lines_connectors;

        %ID the characteristics of the lines for this LV feeder
        line_phase = zeros(length(lines_array),1);
        line_length = zeros(length(lines_array),1);
        
        for iLine = 1:length(lines_array) %for each line
            line_name = lines_array{iLine};
            line_row = find(strcmp(summary_lines_table.name, line_name));
            line_length(iLine) = summary_lines_table{line_row, 'length'};
            
            if file.data_type == 1 
                line_phase(iLine) = summary_lines_table{line_row, 'phasecount'}{1,1};%GLD - FIGURE OUT THE SOURCE OF THIS ISSUE
            else
                line_phase(iLine) = summary_lines_table{line_row, 'phasecount'};
            end 

        end 

        %% loads and nodes
        this_S_loads = x_load(row).total_S;
        this_P_loads = x_load(row).total_P;
        this_Q_loads = x_load(row).total_Q;
        
        if this_S_loads > 0 
            S_total_LV(iLV) = sum(this_S_loads);
            P_total_LV(iLV) = sum(this_P_loads);
            Q_total_LV(iLV) = sum(this_Q_loads);
        else
            S_total_LV(iLV) = 0;
            P_total_LV(iLV) = 0;
            Q_total_LV(iLV) = 0;
        end
        
        nNodes(iLV) = x_load(row).nNodes; %num of nodes in each LV feeder
        nLoads(iLV) = x_load(row).nLoads; %num nodes with loads
        
        %% voltage level - find secondary side of the transformer
        if file.data_type == 1 % GLD

            row = find(strcmp([summary_lines_table.name], name));
            xfm_2ndV(iLV) = summary_lines_table{row, 'nominalV_2nd_xfm'};
            array_2ndV = [array_2ndV xfm_2ndV(iLV)];
        else %for ODSS, nomV for xfms == output V
            row = find(strcmp([summary_lines_table.name], name));
            xfm_2ndV(iLV) = summary_lines_table{row, 'nominalV'};
            array_2ndV = [array_2ndV xfm_2ndV(iLV)];
                              
        end 
               
        %% Total Length of LV line: sum across all lines in the LV feeder             
        length_LV(iLV) = sum(line_length);
        
        %% Length of Lines by phase (for this LV feeder only)
        phase1_lines_LV = find(line_phase == 1);
        phase2_lines_LV = find(line_phase == 2);
        phase3_lines_LV = find(line_phase == 3);

        len_phase1(iLV) = sum(line_length(phase1_lines_LV));
        len_phase2(iLV) = sum(line_length(phase2_lines_LV));
        len_phase3(iLV) = sum(line_length(phase3_lines_LV));
        

%%   Save to network structure (LV) and save to network structure

        network.MV(iMV).LVFeeder(iLV).phase1_len = len_phase1(iLV);
        network.MV(iMV).LVFeeder(iLV).phase2_len = len_phase2(iLV);
        network.MV(iMV).LVFeeder(iLV).phase3_len = len_phase3(iLV);
        network.MV(iMV).LVFeeder(iLV).length = length_LV(iLV);
        
        network.MV(iMV).LVFeeder(iLV).nNodes = nNodes(iLV);
        network.MV(iMV).LVFeeder(iLV).nLoads = nLoads(iLV);
        network.MV(iMV).LVFeeder(iLV).S_total = S_total_LV(iLV);
        network.MV(iMV).LVFeeder(iLV).P_total = P_total_LV(iLV);
        network.MV(iMV).LVFeeder(iLV).Q_total = Q_total_LV(iLV);
        
        network.MV(iMV).LVFeeder(iLV).V_level = xfm_2ndV(iLV);

    end % end of LV feeders
    
%%    Roll-Up LV metrics to MV level and save to network structure
    %  summed LV numbers for the MV feeder   
    network.MV(iMV).nNodes.LV = sum(nNodes); % total num buses
    network.MV(iMV).nLoads.LV = sum(nLoads); % total num loads
    network.MV(iMV).S_total.LV = sum(S_total_LV); % total S loads in LV networks
    network.MV(iMV).P_total.LV = sum(P_total_LV); % total P loads in LV networks
    network.MV(iMV).Q_total.LV = sum(Q_total_LV); % total Q loads in LV networks
    network.MV(iMV).length.LV = sum(length_LV); % total LV length
    network.MV(iMV).phase1_len.LV = sum(len_phase1); % total length of 1 phase lines
    network.MV(iMV).phase2_len.LV = sum(len_phase2); % total length of 2 phase lines
    network.MV(iMV).phase3_len.LV = sum(len_phase3); % total length of 3 phase lines 
    network.MV(iMV).nLVFeeders = length(MVLV_x); % total number of LV feeders
    network.MV(iMV).V_levels.LV = unique(LV_levels); % total LV levels
    network.MV(iMV).triplex_len = sum(length_LV); % total trimplex length (assuming all LV is triplex)
    
    network.MV(iMV).nLV_perMV = sum(nLoads)/n_loads_MV;% LV consumers per MV consumer
    network.MV(iMV).MVLV_xfm_capacity = sum([x_load.xfm_capacity]);% total MV/LV xfm capacity 
    
%%   Calculate feeder level Mean Line Utilization Ratio 
    i_line = regexp(summary_lines_table.type, 'line');
    line_rows = find(not(cellfun('isempty', i_line)));
    UR = summary_lines_table.URatio(line_rows);
    
    network.MV(iMV).mean_line_UR = mean(UR);
    
%%    Calculate Network Topology (Feeder level) (Could be a seperate function)
    sumA = sum(a_matrix_non);
    sum2A = sum(a_matrix_non,2);
    connected_col = find(sumA ~= 0); %remove the nodes with 0 linkages
    connected_row = find(sum2A ~=0);

%     final_name_nodes = {bus_names{connected_col,1}}';

    % Remove extra nodes (if any) that are not connected (ie. sourceonde
    aMat_clean = a_matrix_non(connected_row,connected_col);
    A = aMat_clean;
    
    sparse_A = sparse(A);
   
    % dijkstra algorithm - shortest path
    d_matrix = zeros(length(A));
    p_matrix = zeros(length(A));

    for i = 1:length(A)
        [d, p] = dijkstra_sp(sparse_A, i);

        d_matrix(i,:) = d;
        p_matrix(i,:) = p;
    end
    
    diameter = max(max(d_matrix));
    char_path_len = mean(mean(d_matrix));
    
    % clustering coeffient
    [clust_coeff] = clustering_coefficients(sparse_A);
    % degree assortativity
    deg_assort = assortativity(A, 0);
    % node betweeness
    betweenness = betweenness_centrality(sparse_A);
    
    network.topology.deg_array = sum(A,1); % degree distribution
    network.topology.ave_deg = mean(sum(A,1)); % average degree
    network.topology.diameter = diameter; % diameter
    network.topology.char_path_len = char_path_len; % characteristic path length
    network.topology.clust_coeff = mean(clust_coeff); % clustering coeff
    network.topology.deg_assort = deg_assort; % degree assortativity
    network.topology.betweenness = betweenness; % node betweeness 
    

%%  Save MV specific metrics to network   
    network.MV(iMV).phase1_len.MV = len_phase1_MV;
    network.MV(iMV).phase2_len.MV = len_phase2_MV;
    network.MV(iMV).phase3_len.MV = len_phase3_MV;        
    network.MV(iMV).length.MV = length_MV;
    network.MV(iMV).nNodes.MV = n_nodes_MV;
    network.MV(iMV).nLoads.MV = n_loads_MV;
    network.MV(iMV).S_total.MV = S_total_MV;
    network.MV(iMV).P_total.MV = P_total_MV;
    network.MV(iMV).Q_total.MV = Q_total_MV;   
    network.MV(iMV).V_levels.MV = unique(MV_levels);
    
    if file.data_type == 1 %GLD
        network.MV(iMV).UL_len = sum(UL_len);
        network.MV(iMV).OL_len = sum(OL_len);       
        network.MV(iMV).UL_ratio = sum(UL_len)/length_MV; % MV underground circuit ratio    
    else
        network.MV(iMV).UL_len = NaN; % ODSS does not specify overhead vs. underground lengths
        network.MV(iMV).OL_len = NaN;
    end 
    
    % Assume 1 for now
    n_MVFeeders = 1;
    n_HVMVFeeders = 0;
    n_MV_supply_points = length(Q_MV_loads);  %sum of injection and consumer points      
    network.MV(iMV).n_MVFeeders = n_MVFeeders; 
    
    % MV circuit per MV supply point
    network.MV(iMV).MVcircuit_perMVsupply = length_MV/n_MV_supply_points;
    % Assume # of HV/MV SS = 0 
    network.MV(iMV).MV_supplypts_HVMVSS = n_MV_supply_points/n_HVMVFeeders;
    % Branching
    network.MV(iMV).n_branches = max([x_load.branch_level]);
    % Percent Loss
    network.MV(iMV).percent_loss = percent_loss;
    
end 