function [stats_lines, ops_lines, line_all] = stats_lines_function(file, summary_lines_table)
% stats_lines_function
% Description: takes data from the summary lines table and calculates
% additional metrics specific to lines. 

% Arguments:
% file: holds the paths and settings for this case
% summary_lines_table: Relevant data pulled from input and output files...
% for line type components (transformers, lines, fuses, and their
% subtypes). This refers to the preliminary summary_lines_table

%ODSS
% S_total = total apparent parent across the elements
% URatio: max current (across phases)/rating
% mean V = sumof current in existing phases/total number of phases
% Deviation (by phase) = |V in phase - mean V|
% Imbalance: load imbalance calc with voltage (max V deviation/mean V), line imbalance calculated
% with current (max i deviation/ mean i)



% Outputs:
% stats_lines: descriptive stats of the lines
% ops_lines: operational measures of the lines 
% line_all: the additional calculated descriptive and operational stats...
% combined into one structure

   
%% phase count    
phases = {'A', 'B', 'C'};
    for iLine = 1:size(summary_lines_table,1)            
        line_name = summary_lines_table{iLine, 'name'};
        type = summary_lines_table{iLine, 'component'}{1,1};
        %% Triplex lines -- need to ID phases via power flow
        %Note: sometimes in GLD, triplex lines can have current but no
        %power flow. Therefore, phases are accounted for only by the number
        %of phases with power flow in them. In ODSS, triplex lines are
        %defined as 2 phase, and both phases appear t have current and
        %power flow
        thisPhase = [];
        if strcmp({type}, 'triplex_line')
            keepCol = [0 0 0]; %used in calc of URatio
            if summary_lines_table{iLine, 'power_in_A_P'} ~= 0
               thisPhase = [thisPhase 'A'];
               keepCol(1) = 1;
            end

            if summary_lines_table{iLine, 'power_in_B_P'} ~= 0
               thisPhase = [thisPhase 'B'];
               keepCol(2) = 1;
            end

            if summary_lines_table{iLine, 'power_in_C_P'} ~= 0
                thisPhase = [thisPhase 'C'];   
                keepCol(3) = 1;
            end                   
            phasecount = length(thisPhase);
        else
            if file.data_type == 1 %GLD
                thisPhase = summary_lines_table{iLine, 'phases'}{1,1};
                phasecount = length(thisPhase)-1;
            else %ODSS
               thisPhase = summary_lines_table{iLine, 'phasecount'};
               phasecount = thisPhase;
            end
            
        end 

        stats_lines.(type)(iLine).name = line_name;  
        stats_lines.(type)(iLine).phasecount = phasecount;

        line_all(iLine).name = line_name;  
        line_all(iLine).phasecount = phasecount;

     
%% Calcs by phase
        ops_lines.(type)(iLine).name = line_name;
        line_all(iLine).name = line_name;
        
        for iPhase = 1:3%size(strVal,2)%for each phase
            
            phase = phases{iPhase};
%% Apparent Power
            p_name_re = ['power_in_' phase '_P'];
            p_name_im = ['power_in_' phase '_Q'];

            Q = summary_lines_table{iLine, p_name_re};
            P = summary_lines_table{iLine, p_name_im};

            %summary for each load
            power_S = sqrt(Q.^2.+P.^2); %for each phase on each load
            S_record(iPhase) = power_S; %for each xformer, this holds the S of each phase

            ops_lines.(type)(iLine).(['S_phase_' phase]) = power_S;
            line_all(iLine).(['S_phase_' phase]) = power_S;
           

%% Current Calculations 
         % NOTE: In GLD, transformer ratings are given in terms of kVA.
         % Ratings for line types are provided in amps elsewhere
            field_re = ['current_in_' phase '_real'];
            field_im = ['current_in_' phase '_im'];

            realA_I = summary_lines_table{iLine,field_re};
            imA_I = summary_lines_table{iLine,field_im};

            %col1 = A, col2 = B, col3 = C
            magI(iLine,iPhase) = sqrt(realA_I^2 + imA_I^2);
            magI_name = ['magI_Phase' num2str(iPhase)];
            
            ops_lines.(type)(iLine).(magI_name) = magI(iLine,iPhase);
            line_all(iLine).(magI_name) = magI(iLine,iPhase);

%% Voltage            
            field_V = ['voltage_in_' phase '_mag'];
            magV(iPhase) = summary_lines_table{iLine, field_V};           
            
        end
        %for each line
        % NOTE: In GLD, transformer ratings are given in terms of kVA.
        % Ratings for line types are provided in amps elsewhere        
        rating = summary_lines_table{iLine, 'cont_rating_amps_or_kVA'};%str2num(ratingL{iLine,1}(2:end-2));
        S_total = sum(S_record(:));
        phaseNum = stats_lines.(type)(iLine).phasecount;
        meanS = sum(S_record(:))/phaseNum; %mean across phase A,B,C
        max_devS = max(abs(S_record(:))- meanS);
        meanV = sum(magV(:));
                

        ops_lines.(type)(iLine).meanS = meanS;
        line_all(iLine).meanS = meanS;        
        
        ops_lines.(type)(iLine).maxDev_S = max_devS;
        line_all(iLine).maxDev_S = max_devS;
        
        stats_lines.(type)(iLine).S_total = S_total;
        line_all(iLine).S_total = S_total;        
        
        ops_lines.(type)(iLine).meanV =  meanV;
        line_all(iLine).meanV =  meanV;        

%% Line Unbalance and Utilization Ratio
        %% if transformer and GLD
        if strcmp(type, 'transformer') && file.data_type == 1 %GLD
            %% Transformer Utilization Ratio
            %using TOTAL apparent power out (given in XML) / rated power
            ops_lines.(type)(iLine).URatio = S_total/rating;
            line_all(iLine).URatio = S_total/rating;
            
            %% Imbalance
            %ID phases in which apparent power out
            %block out the indices of non-existent phases( where current == 0)             
            
            indexI_unused = find(magI(iLine,:) == 0);
            meanI = sum(magI(iLine,:))/phaseNum;
            
            devI = abs(magI(iLine,:)-meanI);
            devI(indexI_unused) = 0;
            max_devI = max(devI);
            
            %save to structure
            ops_lines.(type)(iLine).maxDev_I = max_devI/meanI;
            line_all(iLine).maxDev_I = max_devI/meanI;           
            ops_lines.(type)(iLine).meanI = meanI;
            line_all(iLine).meanI = meanI;
            
          
            ops_lines.(type)(iLine).imbalance = max_devS/meanS;
            line_all(iLine).imbalance = max_devS/meanS;
            
        %% if triplex line - essentially would be applicable to GLD only
        elseif strcmp(type, 'triplex_line')
            %% Triplex Utilization Ratio
            maxI(iLine) = max(magI(iLine,:).*keepCol);
            meanI = sum(magI(iLine,:).*keepCol)/phaseNum;
            ops_lines.(type)(iLine).URatio =  maxI(iLine)/rating;
            line_all(iLine).URatio =  maxI(iLine)/rating;
            
            devI = abs(magI(iLine,:).*keepCol-meanI);

            %block out the indices of non-existent phases
            devI(keepCol == 0) = 0;
            max_devI = max(devI);
            ops_lines.(type)(iLine).maxDev_I = max_devI; %/meanI;
            line_all(iLine).maxDev_I = max_devI;%/meanI;
            
            ops_lines.(type)(iLine).meanI = meanI;
            line_all(iLine).meanI = meanI; 
            
            %% Triplex Imbalance
            ops_lines.(type)(iLine).imbalance = max_devI/meanI;
            line_all(iLine).imbalance = max_devI/meanI;

        else
            %% All other lines: Utilization Ratio
            maxI(iLine) = max(magI(iLine,:));
            meanI = sum(magI(iLine,:))/phaseNum;
            ops_lines.(type)(iLine).URatio =  maxI(iLine)/rating;
            line_all(iLine).URatio =  maxI(iLine)/rating;

            %block out the indices of non-existent phases( where current == 0)             
            indexI_unused = find(magI(iLine,:) == 0);
            devI = abs(magI(iLine,:)-meanI);
            devI(indexI_unused) = 0;
            max_devI = max(devI);
            
            %save to structure
            ops_lines.(type)(iLine).maxDev_I = max_devI/meanI;
            line_all(iLine).maxDev_I = max_devI/meanI;
            
            ops_lines.(type)(iLine).meanI = meanI;
            line_all(iLine).meanI = meanI;             
            
            %% All other lines: Imbalance
            ops_lines.(type)(iLine).imbalance = max_devI/meanI;
            line_all(iLine).imbalance = max_devI/meanI;
            
        end 
 
%% this counts Total 1 vs. 2 vs. 3 phases
        colName = ['length_numPhase' num2str(phasecount)];
        %log the line length in the appropriate column
        
        if summary_lines_table{iLine, 'length'} == 0 % for xformers, fuses, etc
           this_length = 1;
        else
            this_length = summary_lines_table{iLine, 'length'};
        end 
        
        stats_lines.(type)(iLine).(colName) = this_length;
        line_all(iLine).(colName) = this_length;

%% this counts the length of each particlar phase combo
        if file.data_type == 1 %GLD
           stats_lines.(type)(iLine).(thisPhase) = this_length;
           line_all(iLine).(thisPhase) = this_length;  
           
        end
        
        ops_lines.(type)(iLine).phases = thisPhase;
        line_all(iLine).phases = thisPhase;

    end 

end 