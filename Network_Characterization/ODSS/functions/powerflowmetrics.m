function [Power_Flow]=powerflowmetrics(DSSCircuit)
Sol=DSSCircuit.Solution;
Power_Flow.Total_Time=Sol.Total_Time;
Power_Flow.Iterations=Sol.MostIterationsDone;
Power_Flow.Tolerance=Sol.Tolerance;
end