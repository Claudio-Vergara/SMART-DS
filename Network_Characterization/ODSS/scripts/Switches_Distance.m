addpath('C:\Users\athakall\Desktop\FEEDER_CODES\SMART-DS-master\Network_Characterization\ODSS\functions');
addpath('C:\Users\athakall\Desktop\FEEDER_CODES\SMART-DS-master\Network_Characterization\ODSS\functions\matlab-networks-toolbox-master');
set_up1_MLX;
MainFolder='C:\Users\athakall\Desktop\FEEDER_CODES\Validation_CSV_Files';
CaseFolder=file.caseName;
CaseFolder_Cr = fullfile(MainFolder,file.caseName)
m = 'N' %loveland
load(fullfile(saveWorkspace, 'Feeder'));
load(fullfile(saveWorkspace, 'circuit'));
load(fullfile(saveWorkspace, 'summary_lines_final'));
load(fullfile(saveWorkspace, 'FeederData'));
nodetrim = strtok(circuit.Nodes_Dis,'.');
Sub_Id = table;
for j = 1:Feeder.Total_No_Feeders
    to_node = Feeder.Feeder_Summary.To_Node(j);
    for i = 1:Feeder.Total_No_Feeders
        filename = sprintf('%s_%d','FeederNo',i);
        idx=strcmp(strtok(Feeder.summary_feeder_lines.(filename).from,'.'),to_node);
        idx1=find(idx == 1);
        if ~isempty(idx1)
            Sub_Id.Feed_No(j,1) = i;
            SubName = Feeder.Feeder_Summary.SubStn_Name(j);
            for k = 1:Feeder.No_of_Substations  
                idx_s=strcmp(Feeder.summary_propbable_substations.name,SubName);
                idx1_s = find(idx_s == 1);
                if ~isempty(idx1_s)
                    Sub_Id.Sub_Node(j,1) = Feeder.summary_propbable_substations.to(idx1_s);
                    break
                end
            end
            break
        end
    end
    idx_d = strcmp(nodetrim,strtok(Sub_Id.Sub_Node(j,1),'.'));
    idx1_d = find(idx_d == 1);
    idx1_d = idx1_d(1);
    Sub_Id.Distance(j,1) = (circuit.Distance(idx1_d));
end

for i = 1:Feeder.Total_No_Feeders
    filename = sprintf('%s_%d','FeederNo',i);
    idxdis = find(Sub_Id.Feed_No == i);
    disdiff = Sub_Id.Distance(idxdis(1));
    for j = 1 : length(Feeder.summary_feeder_lines.(filename).from)
        %substation to node
        
        idx=strcmp(nodetrim,strtok(Feeder.summary_feeder_lines.(filename).from(j),'.'));
        idx1=find(idx == 1);
        idx1=idx1(1);
        Feeder.summary_feeder_lines.(filename).distance(j) = ((circuit.Distance(idx1))-disdiff)*0.621371; %miles
    end
end


for i=1:Feeder.Total_No_Feeders;
    
    filename = sprintf('%s_%d','FeederNo',i);
    FeederLoop.(filename) = table;
        
    idx=regexp(Feeder.summary_feeder_lines.(filename).name,'fuse');
    idx1=find(~cellfun(@isempty,idx));
    idx1a = repmat('fuse',length(idx1),1);
    idx1b = repmat('closed',length(idx1),1);
    
    idx=regexp(Feeder.summary_feeder_lines.(filename).name,'recloser');
    idx2=find(~cellfun(@isempty,idx));
    idx2a = repmat('recloser',length(idx2),1);
    idx2b = repmat('closed',length(idx2),1);
        
    idx=regexp(Feeder.summary_feeder_lines.(filename).name,'switch');
    idx3=find(~cellfun(@isempty,idx));
    idx3a = repmat('switch',length(idx3),1);
    idx3b = repmat('closed',length(idx3),1);

    
    idx=regexp(Feeder.summary_feeder_lines.(filename).name,'interruptor');
    idx4=find(~cellfun(@isempty,idx));
    idx4a = repmat('interruptor',length(idx4),1);
    idx4b = repmat('closed',length(idx4),1);

    
    idx5=[idx1;idx2;idx3;idx4];
    idx5a=strvcat(idx1a,idx2a,idx3a,idx4a);
    idx6a=strvcat(idx1b,idx2b,idx3b,idx4b); 
    
    FeederLoop.(filename).distance = Feeder.summary_feeder_lines.(filename).distance(idx5);
    FeederLoop.(filename).component = idx5a; 
    FeederLoop.(filename).name = Feeder.summary_feeder_lines.(filename).name(idx5);
    FeederLoop.(filename).to = Feeder.summary_feeder_lines.(filename).to(idx5);
    FeederLoop.(filename).from = Feeder.summary_feeder_lines.(filename).from(idx5);
    FeederLoop.(filename).phasecount = Feeder.summary_feeder_lines.(filename).phasecount(idx5);
    FeederLoop.(filename).status = idx6a; 
    FeederLoop.(filename) = sortrows(FeederLoop.(filename));
end

%m=input('If loveland utility data type Y, Y/N [Y]:','s')
if m=='Y'
    %%Loveland Start
    Devfile = fullfile(file.ODSS.loc,'Device1.dss');
    A = importdata(Devfile);
    A = lower(A);
    xx = length(A);
    %fuses
    Idx=regexp(A,'fuse');    Idx1=find(~cellfun(@isempty,Idx));
    Afuse = A(Idx1);
    %ckt breaker
    Idx=regexp(A,'circuit');
    Idx2=find(~cellfun(@isempty,Idx));
    Acktbrk = A(Idx2);
    %recloser
    Idx=regexp(A,'recloser');
    Idx3=find(~cellfun(@isempty,Idx));
    Arecl = A(Idx3);
    %switches
    Idx4 = [Idx1;Idx2;Idx3];
    Idx5=1:xx;
    Idx5=Idx5.';
    Idx6 = setdiff(Idx5,Idx4);
    Aswit = A(Idx6);
    summary_lines_final.status = repmat('closed',length(summary_lines_final.name),1);
    
    for ik=1:Feeder.Total_No_Feeders;
    
    filename = sprintf('%s_%d','FeederNo',ik);
    % fuse update in summary_lines_final
   for ig=1:length(Feeder.summary_feeder_lines.(filename).name)
       
       Ifuse=regexp(Afuse,char(Feeder.summary_feeder_lines.(filename).name(ig)));
       Ifuse1=find(~cellfun(@isempty,Ifuse));
       if isempty(Ifuse1)
           1;
       else
           Feeder.summary_feeder_lines.(filename).type{ig} = 'fuse';
       end
   end
   
   
   Ifuopen=regexp(Afuse,'open');
   Ifuopen1=find(~cellfun(@isempty,Ifuopen));
   Afuseopen = Afuse(Ifuopen1);
   
      for ig=1:length(Feeder.summary_feeder_lines.(filename).name)
       
       Ifuse=regexp(Afuseopen,char(Feeder.summary_feeder_lines.(filename).name(ig)));
       Ifuse1=find(~cellfun(@isempty,Ifuse));
       if isempty(Ifuse1)
          1;
       else
           Feeder.summary_feeder_lines.(filename).bus{ig} = 'open';
       end       
      end
    end
    
    
    % ckt brkr update in summary_lines_final
for ik=1:Feeder.Total_No_Feeders;
    
     filename = sprintf('%s_%d','FeederNo',ik);
   for ig=1:length(Feeder.summary_feeder_lines.(filename).name)
       
       Ifuse=regexp(Acktbrk,char(Feeder.summary_feeder_lines.(filename).name(ig)));
       Ifuse1=find(~cellfun(@isempty,Ifuse));
       if isempty(Ifuse1)
           1;
       else
           Feeder.summary_feeder_lines.(filename).type{ig} = 'cb';
       end
       
       
   end
   
   Ifuopen=regexp(Acktbrk,'open');
   Ifuopen1=find(~cellfun(@isempty,Ifuopen));
   Acktbrkopen = Acktbrk(Ifuopen1);
   
      for ig=1:length(Feeder.summary_feeder_lines.(filename).name)
       
       Ifuse=regexp(Acktbrkopen,char(Feeder.summary_feeder_lines.(filename).name(ig)));
       Ifuse1=find(~cellfun(@isempty,Ifuse));
       if isempty(Ifuse1)
          1;
       else
           Feeder.summary_feeder_lines.(filename).bus{ig} = 'open';
       end       
      end
end
      %
               % recloser update in summary_lines_final
for ik=1:Feeder.Total_No_Feeders;
    
     filename = sprintf('%s_%d','FeederNo',ik);              

   for ig=1:length(Feeder.summary_feeder_lines.(filename).name)
       
       Ifuse=regexp(Arecl,char(Feeder.summary_feeder_lines.(filename).name(ig)));
       Ifuse1=find(~cellfun(@isempty,Ifuse));
       if isempty(Ifuse1)
           1;
       else
           Feeder.summary_feeder_lines.(filename).type{ig} = 'recloser';
       end
       
       
   end
   
   Ifuopen=regexp(Arecl,'open');
   Ifuopen1=find(~cellfun(@isempty,Ifuopen));
   Areclopen = Arecl(Ifuopen1);
   
      for ig=1:length(Feeder.summary_feeder_lines.(filename).name)
       
       Ifuse=regexp(Areclopen,char(Feeder.summary_feeder_lines.(filename).name(ig)));
       Ifuse1=find(~cellfun(@isempty,Ifuse));
       if isempty(Ifuse1)
          1;
       else
           Feeder.summary_feeder_lines.(filename).bus{ig} = 'open';
       end       
      end
end


for ik=1:Feeder.Total_No_Feeders;
    
     filename = sprintf('%s_%d','FeederNo',ik);      
   %switch
     for ig=1:length(Feeder.summary_feeder_lines.(filename).name)
       
       Ifuse=regexp(Aswit,char(Feeder.summary_feeder_lines.(filename).name(ig)));
       Ifuse1=find(~cellfun(@isempty,Ifuse));
       if isempty(Ifuse1)
           1;
       else
           Feeder.summary_feeder_lines.(filename).type{ig} = 'switch';
       end
       
       
   end
   
   Ifuopen=regexp(Aswit,'open');
   Ifuopen1=find(~cellfun(@isempty,Ifuopen));
   Aswitopen = Aswit(Ifuopen1);
   
      for ig=1:length(Feeder.summary_feeder_lines.(filename).name)
       
       Ifuse=regexp(Aswitopen,char(Feeder.summary_feeder_lines.(filename).name(ig)));
       Ifuse1=find(~cellfun(@isempty,Ifuse));
       if isempty(Ifuse1)
          1;
       else
           Feeder.summary_feeder_lines.(filename).bus{ig} = 'open';
       end       
      end
end

for i=1:Feeder.Total_No_Feeders;
    
    filename = sprintf('%s_%d','FeederNo',i);
    FeederLoop.(filename) = table;
        
    idx=regexp(Feeder.summary_feeder_lines.(filename).type,'fuse');
    idx1=find(~cellfun(@isempty,idx));
    idx1a = repmat('fuse',length(idx1),1);
    
    idx=regexp(Feeder.summary_feeder_lines.(filename).type,'cb');
    idx2=find(~cellfun(@isempty,idx));
    idx2a = repmat('circuit breaker',length(idx2),1);
        
    idx=regexp(Feeder.summary_feeder_lines.(filename).type,'switch');
    idx3=find(~cellfun(@isempty,idx));
    idx3a = repmat('switch',length(idx3),1);

    
    idx=regexp(Feeder.summary_feeder_lines.(filename).type,'recloser');
    idx4=find(~cellfun(@isempty,idx));
    idx4a = repmat('recloser',length(idx4),1);

    
    idx5=[idx1;idx2;idx3;idx4];
    idx5a=strvcat(idx1a,idx2a,idx3a,idx4a); 
    
    FeederLoop.(filename).distance = Feeder.summary_feeder_lines.(filename).distance(idx5);
    FeederLoop.(filename).component = idx5a; 
    FeederLoop.(filename).name = Feeder.summary_feeder_lines.(filename).name(idx5);
    FeederLoop.(filename).to = Feeder.summary_feeder_lines.(filename).to(idx5);
    FeederLoop.(filename).from = Feeder.summary_feeder_lines.(filename).from(idx5);
    FeederLoop.(filename).phasecount = Feeder.summary_feeder_lines.(filename).phasecount(idx5);
    FeederLoop.(filename).status = repmat('closed',length(idx5),1);    
    FeederLoop.(filename) = sortrows(FeederLoop.(filename));
end
AAA=[Afuseopen;Acktbrkopen;Areclopen; Aswitopen];
if ~isempty(AAA)
Devfile = fullfile(file.ODSS.loc,'Reactor1.dss');
    A = importdata(Devfile);
    A = lower(A);
    xx = length(A);
    FuseTab = table;
    j=1;
    for i = 1:length(Afuseopen)
    %fuse open
    fop=strsplit(Afuseopen{i, 1}  ,' ');
    objt = fop(4);
    Idx=regexp(A,objt,'match');    Idx1=find(~cellfun(@isempty,Idx));
    Afopen = A(Idx1);
    fop1=strsplit(Afopen{1, 1}  ,' ');
    aa=fop1(4);
    bb=strsplit(aa{1,1},'=');
    FuseTab.from(j,1) = bb(2);
    aa=fop1(5);
    bb=strsplit(aa{1,1},'=');
    FuseTab.to(j,1) = bb(2);
    FuseTab.name(j,1) = fop1(2);
    aa=fop1(3);
    bb=strsplit(aa{1,1},'=');
    FuseTab.phasecount(j,1) = bb(2);
    aa=strsplit(Afuseopen{i,1},' ');
    FuseTab.type(j,1) = aa(9);
    j=j+1;
    end
    
        for i = 1:length(Acktbrkopen)
    %fuse open
    fop=strsplit(Acktbrkopen{i, 1}  ,' ');
    objt = fop(4);
    Idx=regexp(A,objt,'match');    Idx1=find(~cellfun(@isempty,Idx));
    Afopen = A(Idx1);
    fop1=strsplit(Afopen{1, 1}  ,' ');
    aa=fop1(4);
    bb=strsplit(aa{1,1},'=');
    FuseTab.from(j,1) = bb(2);
    aa=fop1(5);
    bb=strsplit(aa{1,1},'=');
    FuseTab.to(j,1) = bb(2);
    FuseTab.name(j,1) = fop1(2);
    aa=fop1(3);
    bb=strsplit(aa{1,1},'=');
    FuseTab.phasecount(j,1) = bb(2);
    aa=strsplit(Acktbrkopen{i,1},' ');
    FuseTab.type(j,1) = aa(9);
    j=j+1;
        end
    
for i = 1:length(Areclopen)
    %fuse open
    fop=strsplit(Areclopen{i, 1}  ,' ');
    objt = fop(4);
    Idx=regexp(A,objt,'match');    Idx1=find(~cellfun(@isempty,Idx));
    Afopen = A(Idx1);
    fop1=strsplit(Afopen{1, 1}  ,' ');
    aa=fop1(4);
    bb=strsplit(aa{1,1},'=');
    FuseTab.from(j,1) = bb(2);
    aa=fop1(5);
    bb=strsplit(aa{1,1},'=');
    FuseTab.to(j,1) = bb(2);
    FuseTab.name(j,1) = fop1(2);
    aa=fop1(3);
    bb=strsplit(aa{1,1},'=');
    FuseTab.phasecount(j,1) = bb(2);
    aa=strsplit(Areclopen{i,1},' ');
    FuseTab.type(j,1) = aa(9);
    j=j+1;
end
    
for i = 1:length(Aswitopen)
    %fuse open
    fop=strsplit(Aswitopen{i, 1}  ,' ');
    objt = fop(4);
    Idx=regexp(A,objt,'match');    Idx1=find(~cellfun(@isempty,Idx));
    Afopen = A(Idx1);
    fop1=strsplit(Afopen{1, 1}  ,' ');
    aa=fop1(4);
    bb=strsplit(aa{1,1},'=');
    FuseTab.from(j,1) = bb(2);
    aa=fop1(5);
    bb=strsplit(aa{1,1},'=');
    FuseTab.to(j,1) = bb(2);
    FuseTab.name(j,1) = fop1(2);
    aa=fop1(3);
    bb=strsplit(aa{1,1},'=');
    FuseTab.phasecount(j,1) = bb(2);
    aa{1,1}='switch';
    FuseTab.type(j,1) = aa(1);
    j=j+1;
end

ii=0;
for k = 1:Feeder.Total_No_Feeders
    filename = sprintf('%s_%d','FeederNo',k);
    lenfelop = length(FeederLoop.(filename).distance);
    FeederLoop.(filename).component=cellstr(FeederLoop.(filename).component);
    FeederLoop.(filename).status=cellstr(FeederLoop.(filename).status);
    % fuse update in summary_lines_final]
    im=0;
   for ig=1:length(FuseTab.from)
   %for ig=1:1
       idx=strcmp(Feeder.summary_feeder_lines.(filename).from,FuseTab.from{ig,1});
       idx1=find(idx==1);
%        if ~isempty(idx1)
%            break
%        end
%       idx=strcmp(Feeder.summary_feeder_lines.(filename).from,FuseTab.to{ig,1});
%       idx2=find(idx==1);
%        if ~isempty(idx2)
%            break
%        end
       idx=strcmp(Feeder.summary_feeder_lines.(filename).to,FuseTab.from{ig,1});
       idx3=find(idx==1);
%        if ~isempty(idx3)
%            break
%        end
%       idx=strcmp(Feeder.summary_feeder_lines.(filename).to,FuseTab.to{ig,1});
%       idx4=find(idx==1);
%        if ~isempty(idx4)
%            break
%        end  
        idx5 = [idx1;idx3];
       
        if ~isempty(idx5)
            ii=ii+1;
            k
            ig
            idx5
             idx5=idx5(1);
            im=im+1;
            FeederLoop.(filename).distance(lenfelop+im) = Feeder.summary_feeder_lines.(filename).distance(idx5);
            FeederLoop.(filename).component(lenfelop+im) = FuseTab.type(ig);
            FeederLoop.(filename).name(lenfelop+im) = FuseTab.name(ig);
            FeederLoop.(filename).to(lenfelop+im) = FuseTab.to(ig);
            FeederLoop.(filename).from(lenfelop+im) = FuseTab.from(ig);
            FeederLoop.(filename).phasecount(lenfelop+im) = str2num(FuseTab.phasecount{ig,1})
            aa{1,1}='open';
            FeederLoop.(filename).status(lenfelop+im) = aa(1);
            % break
         end  
   end
end

end

for lm=1:Feeder.Total_No_Feeders
    filename = sprintf('%s_%d','FeederNo',lm);
    FeederLine.(filename) = table;
    ix = strcmp(Feeder.summary_feeder_lines.(filename).type,'line');
    idx=find(ix==1);
    idx1 = regexp(Feeder.summary_feeder_lines.(filename).linecode(idx),'oh');
    idx2=find(~cellfun(@isempty,idx1));
    aa=Feeder.summary_feeder_lines.(filename)(idx,:);
    bb=aa(idx2,:);
    no_line = length(idx);
    no_oh_line = length(idx2);
    no_ug_line = no_line - no_oh_line;
    FeederLine.(filename).No_OH_Lines = no_oh_line;
    FeederLine.(filename).No_UG_Cables = no_ug_line;
end

      
%     ixx = strcmp(summary_lines_final.bus,'open');
%     ixy = find(ixx==1);
%     frm = strtok(summary_lines_final.from(ixy),'.');
%     too = strtok(summary_lines_final.to(ixy),'.');
%     
%     a_matrix1=a_matrix;
%     a_matrix_non1=a_matrix_non;
%     for ik = 1:length(ixy)
%       ixx = strcmp(bus_names,frm(ik));
%       ixx1 = find(ixx==1);
%       iyy = strcmp(bus_names,too(ik));
%       iyy1 = find(iyy==1);
%       a_matrix1(ixx1,iyy1)=0;
%       a_matrix_non1(ixx1,iyy1)=0;
%     end
else
        for lm=1:Feeder.Total_No_Feeders
        filename = sprintf('%s_%d','FeederNo',lm);
        FeederLine.(filename) = table;
        ix = strcmp(Feeder.summary_feeder_lines.(filename).type,'line');
        idx=find(ix==1);
        idx1 = regexp(Feeder.summary_feeder_lines.(filename).linecode(idx),'oh');
        idx2=find(~cellfun(@isempty,idx1));
        aa=Feeder.summary_feeder_lines.(filename)(idx,:);
        bb=aa(idx2,:);
        no_line = length(idx);
        no_oh_line = length(idx2);
        no_ug_line = no_line - no_oh_line;
        FeederLine.(filename).No_OH_Lines = no_oh_line;
        FeederLine.(filename).No_UG_Cables = no_ug_line;
    end
end
 %Loveland End
kk=char(strsplit(file.caseName,'\'));
casesFolder_sw='C:\Users\athakall\Desktop\FEEDER_CODES\Validation_CSV_Files\Switches'
folderName_sw = fullfile(casesFolder_sw,kk(1,:));
mkdir(folderName_sw)
cd(folderName_sw)
BB{1,1}='distance_miles';
BB{1,2}='component';
BB{1,3}='name';
BB{1,4}='to';
BB{1,5}='from';
BB{1,6}='phasecount';
BB{1,7}='status';
DD{1,1}='No_OH_Lines';
DD{1,2}='No_UG_Cables';
for y=1:Feeder.Total_No_Feeders
filename = sprintf('%s_%d','FeederNo',y);
FeederLoop.(filename) = sortrows(FeederLoop.(filename)); 
AA=table2cell(FeederLoop.(filename))
AAA=[BB;AA]; 
xlswrite(kk(1,:), AAA, y)
CC=table2cell(FeederLine.(filename))
CCC=[DD;CC];
xlswrite(kk(1,:), CCC, y, 'H1')
end
%cd('C:\Users\athakall\Desktop\FEEDER_CODES\ODSS_feeders\Loveland')
