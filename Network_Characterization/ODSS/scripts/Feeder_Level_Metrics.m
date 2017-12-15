set_up1_MLX;

load(fullfile(saveWorkspace, 'summary_lines_final'));
load(fullfile(saveWorkspace, 'summary_nodes_final'));
load(fullfile(saveWorkspace, 'a_matrix'));
load(fullfile(saveWorkspace, 'a_matrix_non'));
load(fullfile(saveWorkspace, 'bus_names'));
load(fullfile(saveWorkspace, 'asym_matrix'));
load(fullfile(saveWorkspace, 'nodes_array'));
load(fullfile(saveWorkspace, 'file'));

%segregates and calculates feeder wise data
[Feeder]=Feeder_Wise_Data_d3loops(file,summary_lines_final,summary_nodes_final,a_matrix,bus_names,a_matrix_non,asym_matrix,nodes_array);

variables = {'Feeder'};
for iV = 1:length(variables)
    saveMat = fullfile(saveWorkspace, [variables{iV} '.mat']);
    save(saveMat, variables{iV});
end

disp('Created Feeder Metrics'); 