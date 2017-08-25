function [No_Plots]=feederwiseplot(Feeder,file);
No_Plots=Feeder.Total_No_Feeders;
No_Plots = No_Plots+1;
for nk = 1:No_Plots
    filename = sprintf('%s_%d','FeederNo',nk);
    [~, ~] = plot_aMatrix_feeder(file, Feeder, filename, nk);
end
No_Plots=Feeder.Total_No_Feeders;
end