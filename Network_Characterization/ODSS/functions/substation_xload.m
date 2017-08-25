function [summary_lines_table]=substation_xload(summary_lines_table, summary_lines_final,summary_nodes_final)
%  HV > 115kV, 69kV < MV < 2.4kV, LV < 600V
%% No of Substations
Idx=regexp(summary_lines_final.name,'transformer');

Idx1=find(~cellfun(@isempty,Idx));

Idx=regexp(summary_lines_final.type,'regulator');

Idx2=find(~cellfun(@isempty,Idx));

Idx3=setdiff(Idx1, Idx2);

summary_transformer=summary_lines_final(Idx3,:);

Idx=regexp(summary_nodes_final.component,'node');

Idx1=find(~cellfun(@isempty,Idx));

summary_nodes=summary_nodes_final(Idx1,:);

Idxl=regexp(summary_lines_final.name,'line');

Idxl1=find(~cellfun(@isempty,Idxl));

summary_lines1=summary_lines_final(Idxl1,:);

Idxol=find(summary_lines1.length > 1e-3);

summary_lines=summary_lines1(Idxol,:);


Idxaa=find(summary_transformer.nominalV > 2.4 & summary_transformer.phasecount == 3 ...
        & summary_transformer.cont_rating_amps_or_kVA > 499);
summary_transformer1=summary_transformer(Idxaa,:);
l_xfrm=length(summary_transformer1.name);
l_node=length(summary_nodes.name);

for i=1:l_xfrm
    for j= 1:l_node
        Idx10=strfind(summary_transformer1.from{i}, summary_nodes.name{j});
        if Idx10==1
            summary_transformer1.primaryV(i)=summary_nodes.nominalV(j)*1.732;
            summary_transformer1.priname(i)=summary_nodes.name(j);
            break
        end
    end
end

for i=1:l_xfrm
    for j= 1:l_node
        Idx10=strfind(summary_transformer1.to{i}, summary_nodes.name{j});
        if Idx10==1
            summary_transformer1.nodename(i)=summary_nodes.name(j);
            break
        end
    end
end

% Idxaa=find(summary_transformer1.nominalV > 2.4 & summary_transformer1.phasecount == 3 ...
%         & summary_transformer1.cont_rating_amps_or_kVA > 499 & summary_transformer1.primaryV >= 30);
    
Idxaa=find(summary_transformer1.nominalV > 2.4 & summary_transformer1.phasecount == 3 ...
        & summary_transformer1.cont_rating_amps_or_kVA > 499);
    
summary_propbable_substations=summary_transformer1(Idxaa,:);

lk=length(summary_propbable_substations.name);
for kk=1:lk
xxy=strcmp(summary_lines_table.name, summary_propbable_substations.name(kk));
idx=find(xxy ~= 0);
summary_lines_table.type{idx}='substation';
end
end        
   






