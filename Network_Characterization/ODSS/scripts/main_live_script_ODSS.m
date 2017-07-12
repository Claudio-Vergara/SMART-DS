clc
clearvars
fclose all;

% The main functions, written in script format (live script)

%% interacts with engine to create circuit data structure
tic;
run_case1_MLX;
clc
disp(['run_case1_MLX ran in ' num2str(round(toc)) ' seconds.']);

%% creates the preliminary summary tables (one for lines and one for loads)
tic;
summarytable_ODSS_MLX;
clc;
disp(['summarytable_ODSS_MLX ran in ' num2str(round(toc)) ' seconds.']);

%% create the adjacency matrix
tic;
make_aMatrix_ODSS_MLX;
clc
disp(['make_aMatrix_ODSS_MLX ran in ' num2str(round(toc)) ' seconds.']);

%% calcs some metrics for transformers (downstream)
tic;
xformer_loads_ODSS_MLX;
clc
disp(['xformer_loads_ODSS_MLX ran in ' num2str(round(toc)) ' seconds.']);

%% plots the feeder
plot_aMatrix_MLX;

%% pulls the additional metrics/stats calculated into the summary tables
final_summarytable_ODSS_MLX;

%% calcs the aggregate metrics
agg_metrics_shared_ODSS_MLX;

%% saves summary statistics into an excel sheet
table_contents_ODSS_MLX;



