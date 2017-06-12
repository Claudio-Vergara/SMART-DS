clearvars;
clc;
dbstop if error
addpath(genpath('C:\Dropbox (MIT)\SMART_DS\matlab\metrics\GLD'));

%% The main functions, written in script format (live script)

%create summary tables
create_summarytables_GLD_MLX; %creates the initial summary table
make_aMatrix_GLD_MLX; %creates an adjacency matrix
plot_aMatrix_GLD_MLX; %plot the feeder
final_summarytables_GLD_MLX; %save final metrics into summary table

%calculate metrics
xformer_loads_function_GLD_MLX; %transformer loads
agg_metrics_shared_GLD_MLX; %calculate aggregate metrics
table_contents_GLD_MLX; % shared function




