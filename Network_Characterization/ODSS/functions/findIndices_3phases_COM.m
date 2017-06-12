function [this_table, terminal] = findIndices_3phases_COM(inputsTable, column_name)
% findIndices_3phases
% pulls the measurements of power, voltage, and current from the raw form in the circuit structure into a data structure

% Description:
% Assumes the cell array pulled from circuit is organized on the highest level by terminals (1, 2, 3). It is assumed terminal 1 refers to the input terminal, while terminal 2 refers to the output terminal. Three terminal objects have only been observed in transformers so far. Within each terminal, the data is organized by conductors in the order of phases (1, 2, 3) followed by neutrals. Within each conductor, it is assumed that the data is organized in 2 parts. Power measurements are reported as tuplets of P and Q, current measurements are reported in tuplets of magnitude and angle, voltage measurements are reported in tuplets of magnitude and angle. 

% Arguments: 
% InputsTable: the circuit structure is converted to a table format for easier access to values. 
% column_name: specifies which measurement is of interest

% Outputs:
% terminal:  this structure holds the measurements in a easier-to-use format, in which part 1 and part 2 of the measurements are pulled for each element and organized by phase. Measurements of neutral conductors is not included. 

%%    
    this_col = inputsTable.(column_name);
    for i = 1:length(this_col)
        col(i,1) = size(this_col{i,:},2);
    end

    col_size = max(col);
    this_table = zeros(length(this_col), col_size);

    % this_table holds the values of interst by conductor
    for i = 1:length(this_col)
       this_i = this_col{i,:};
       this_table(i,1:length(this_i)) = this_i;
    end 

    %% divide categories into p1, p2 in and p1, p2 out
    num_terminals = inputsTable.n_terminals;
    n_conductors = inputsTable.n_conductors;
    num_phases = inputsTable.phases;     
    total_cols = n_conductors*2;%number of conductors * 2 parts (Q and P)
    
    %will keep at max 3 phases
    %out terminal
    start_index_out = total_cols + 1; %two cols per conductor
%     end_index_out = min(start_index_out + total_cols-1,start_index_out+ 5); 
    end_index_out = min(start_index_out + num_phases*2-1,start_index_out+ 5); 

    %in terminal
    start_index_in = 1;
%     end_index_in = min(start_index_in + total_cols -1,start_index_in+ 5);
    end_index_in = min(start_index_in + num_phases*2 -1,start_index_in+ 5);
    

    
    
    % initialize terminal with holder values    
    terminal.names = inputsTable.name;
    terminal_out_total = zeros(size(num_phases,1),6);    
    terminal_in_total = zeros(size(num_phases,1),6);    
%     terminal_out_total = zeros(size(num_phases,1),12);    
%     terminal_in_total = zeros(size(num_phases,1),12);
    terminal_part1_out = zeros(size(num_phases,1),3);
    terminal_part2_out = zeros(size(num_phases,1),3);
    terminal_part1_in = zeros(size(num_phases,1),3);
    terminal_part2_in = zeros(size(num_phases,1),3);
    terminal_part1_out2 = zeros(size(num_phases,1),3); % if there is a third terminal
    terminal_part2_out2 = zeros(size(num_phases,1),3); % if there is a third terinal
    
    for i = 1:size(num_phases,1) %size of num_conductors = total rows

        %% all out columns
        % if there is only one terminal, then there is no output (if
        % there are more conductors than phases, the extra should be neutrals)
        out_terminal = this_table(i,start_index_out(i):end_index_out(i));
        
        if num_terminals(i) == 1
            
            len_out = length(out_terminal);
        elseif num_terminals(i) == 3 % if there is a third terminal
             
            terminal_out_total(i,1:length(out_terminal)) = out_terminal;
            
            start_index_out2 = end_index_out +1;
            end_index_out2 = min(start_index_out2 + total_cols-1,start_index_out2+ 5); 
            
            out_terminal2 = this_table(i,start_index_out2(i):end_index_out2(i));            
            
            
            % the start and end indices of the third terminal
            out2_start = length(out_terminal)+1;
            out2_end = out2_start+length(out_terminal2)-1;
            
            
            terminal_out_total(i,out2_start:out2_end) = out_terminal2;
            len_out = size(out_terminal,2);
            
        elseif num_terminals(i) == 2         
            terminal_out_total(i,1:length(out_terminal)) = out_terminal;
            len_out = size(out_terminal,2);
        end 
        
        %% split out columns by p1 and p2 (part 1 and part 2)
        i2 = 1:len_out; %create an array
        indices_p1_out = i2(mod(i2,2) == 1);
        indices_p2_out = i2(mod(i2,2) == 0);

        p1_out_terminal = terminal_out_total(i,indices_p1_out); %mag V for voltage
        p2_out_terminal = terminal_out_total(i,indices_p2_out); %deg V for voltage        
        
        terminal_part1_out(i,1:length(p1_out_terminal)) = p1_out_terminal;
        terminal_part2_out(i,1:length(p2_out_terminal)) = p2_out_terminal;
        
        if num_terminals(i) == 3
            p1_out2_terminal = terminal_out_total(i,indices_p1_out); %mag V for voltage
            p2_out2_terminal = terminal_out_total(i,indices_p2_out); %deg V for voltage        

            terminal_part1_out2(i,1:length(p1_out_terminal)) = p1_out2_terminal;
            terminal_part2_out2(i,1:length(p2_out_terminal)) = p2_out2_terminal;
        end 
        
        %% all in columns
        in_terminal = this_table(i,start_index_in:end_index_in(i));        
        len_in = size(in_terminal,2);
        
        terminal_in_total(i,1:length(in_terminal))  = in_terminal;
        
        %% split in columns by p1 and p2 (p1 and p2 stand for part 1 and
        %part2 -- ex. real and imaginary, mag and degree)
        i2 = 1:len_in; %create an array
        
        indices_p1_in = i2(mod(i2,2) == 1);
        indices_p2_in = i2(mod(i2,2) == 0);
        part1_in_terminal = in_terminal(indices_p1_in); %mag V for voltage
        part2_in_terminal = in_terminal(indices_p2_in); %deg V for voltage
        
        terminal_part1_in(i,1:length(part1_in_terminal))  = part1_in_terminal;
        terminal_part2_in(i,1:length(part2_in_terminal))  = part2_in_terminal;        
        
    end 
    %note: nans mark where there isn't a value
    %neutrals are not included
    terminal.out_total = terminal_out_total;    
    terminal.in_total = terminal_in_total;
    terminal.part1_out = terminal_part1_out;
    terminal.part2_out = terminal_part2_out;
    terminal.part1_in = terminal_part1_in;
    terminal.part2_in = terminal_part2_in;
    terminal.part1_out2 = terminal_part1_out2;
    terminal.part2_out2 = terminal_part2_out2;    

end