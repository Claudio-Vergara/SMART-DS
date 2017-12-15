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
