function [meter_summary] = meter_table_GLD(nodes_array, summary_nodes_table)
% pulls together the metered power and the associated transformer
%% meter summary
    sourcenode_row = (cellfun('isempty',[nodes_array.parent_node]));
    source_meter = nodes_array(sourcenode_row).downstream_nodes;

%% measured power from meters
    meter_row = find(strcmp(summary_nodes_table.type, 'meter'));
    meter_names = summary_nodes_table{meter_row, 'name'};
    m_P = summary_nodes_table{meter_row, 'measured_real_power'};
    m_Q = summary_nodes_table{meter_row, 'measured_reactive_power'};
    
    is_source_array = zeros(length(meter_names),1);
    connector_array = cell(length(meter_names),1);
    m_S_array = zeros(length(meter_names),1);
    
    for iMeter = 1:length(meter_names)%size(meter_table,2)
        m_name = meter_names(iMeter);
        is_source = strcmp(m_name, source_meter);
        is_source_array(iMeter) = is_source;
        im_P = m_P(iMeter);
        im_Q = m_Q(iMeter);
        m_S_array(iMeter) = sqrt((im_P)^2 + (im_Q)^2);

%% fgure out which transformer the meters are attached to 
        node_array_row = (strcmp([nodes_array.name], m_name));
        connector = nodes_array(node_array_row).line_connector;
        connector_array(iMeter) = connector;
    
    end
    meter_summary = table;
    meter_summary.name = meter_names;%m_name_array;
    meter_summary.source_meter = is_source_array;
    meter_summary.measured_P = m_P; %m_P_array;
    meter_summary.measured_Q = m_Q; %m_Q_array;
    meter_summary.measured_S = m_S_array;
    meter_summary.trans_or_reg = connector_array;
end 