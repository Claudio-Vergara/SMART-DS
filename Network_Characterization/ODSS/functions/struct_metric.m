function [feeder_metrics]=struct_metric(a_matrixn,a_matrix_nonn) 
    sumA = sum(a_matrix_nonn);
    sum2A = sum(a_matrix_nonn,2);
    connected_col = find(sumA ~= 0); %remove the nodes with 0 linkages
    connected_row = find(sum2A ~=0);

%     final_name_nodes = {bus_names{connected_col,1}}';

    % Remove extra nodes (if any) that are not connected (ie. sourceonde
    aMat_clean = a_matrix_nonn(connected_row,connected_col);
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
    
   feeder_metrics.diameter = max(max(d_matrix));
   feeder_metrics.char_path_len = mean(mean(d_matrix));
    
    % clustering coeffient
    %[clust_coeff] = clustering_coefficients(sparse_A);
    %feeder_metrics.clust_coeff = clust_coeff;
    % degree assortativity
    %deg_assort = assortativity(A, 0);
    %deg_assort = [];
    %feeder_metrics.deg_assort = deg_assort;
    % node betweeness
    %betweenness = betweenness_centrality(sparse_A);
    %feeder_metrics.betweenness = betweenness;
    
    %feeder_metrics.deg_array = sum(A,1); % degree distribution
    feeder_metrics.ave_deg = mean(sum(A,1)); % average degree
end