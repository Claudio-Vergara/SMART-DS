function [outputsTable, powerFlow] = makeTable_function(file)
%%Pull out most relevant outputs from XML file into table
    %% Read in xml data as a structure
    file_struct = xml2struct(file.GLD.xml);

    powerFlow = file_struct.gridlabd.powerflow;
    fields = fieldnames(powerFlow);

    %Pulling data out
    for iRow = 1:length(fields)
        iTemp(iRow) = any(regexp(fields{iRow},'list$'));
        temp_fields = {fields{iTemp,1}}';
    end 

    for iRow = 1:length(temp_fields)
        iTemp2(iRow) = ~any(regexp(temp_fields{iRow},'configuration_list$'));
        final_fields = {temp_fields{iTemp2,1}}';
    end

    final_fields = [final_fields; 'transformer_configuration_list'];

    %list of components to keep
    componentList = final_fields;
    for iRow =1:length(componentList)
        tempName = final_fields{iRow,1};
        componentNames{iRow,1} = {tempName(1:end-5)};
    end 

    %% Making Table

    for iRow = 1:length(componentList)
        list = componentList{iRow,1};
        name = componentNames{iRow,1}{1,1}; %type of component
%         list_fields = fieldnames(powerFlow.(list));

        does_list_exist = isfield(powerFlow.(list), name);
        
        if ~does_list_exist
            outputsTable.(name) = [];
        else   

            list_struct = powerFlow.(list).(name); %entire structure for the component

            %iComp = each component of the type
            for iComp = 1:length(list_struct)
                if length(list_struct) > 1
                    struct_fields = fieldnames(list_struct{1,1});
                else               
                    struct_fields = fieldnames(list_struct);                    
                    
                end
                
          %for each field listed for each individual component piece
                %iNum = each field name for each component of type ('name')
                for iNum = 1:length(struct_fields)
                    
                    if length(list_struct) == 1
                        current_struct = list_struct;
                    else              
                        current_struct = list_struct{1,iComp};
                    end 
                    current_fieldnames = fieldnames(current_struct);                   
                    field_name = struct_fields{iNum,1};                         
                    does_field_exist = isfield(current_struct, field_name);

                    if ~does_field_exist
                        field_value = [];
                    else 
                        field_value = current_struct.(field_name).Text;
                    end

                    colName = [name num2str(iComp)];
    
                        if iComp == 1
                            outputsTable.(name)(iNum).rowLabels = field_name;
                        end 

                    outputsTable.(name)(iNum).(colName) = field_value;
                end 

            end 
        end 
    end 
    
    %% Call function to pull line configuration info in - is this needed?
%     [line_details] = line_details_GLD(powerFlow);
    
end