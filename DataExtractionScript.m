%FLYTRACKER DATA EXTRACTION SCRIPT, VERSION3, July 2022, Seroude Lab,
%Queen's University, Kingston, Canada
%Loading in data, configuration table and setting up initial parameters
if and(exist('feat','var'),exist('trk','var'))
trkdatasize=size(trk.data);
Numberofarena=trkdatasize(1,1);
else
    msgbox('feat.mat or/and trk.mat have not been added to MatLab Workspace','Abort','error')
    return
end
h=msgbox('Select the Configuration Table File (.xls or .xlsx)','Information','help');
pause(2); 
close(h);
file=0;
while file==0
[file,path]=uigetfile('*');
if file==0
    choice=menu('No configuration table file (.xls or .xlsx) selected (cancel), do you want to abort?','YES, Stop','Select file again');
    if choice==1
    return
    end
end
end
ConfigurationFile=strcat(path,file);
ArenaConfiguration=readtable(ConfigurationFile);
Configsize=size(ArenaConfiguration);
Configsize=Configsize(1);
frametoanalyze=double.empty;
while isempty(frametoanalyze)
prompt={'Number of video frames tracked by FlyTracker? (3min at 30fps:5400)'};
title="Input";
dims=[1 40];
frametoanalyzeText=inputdlg(prompt,title,dims);
frametoanalyze=str2double(frametoanalyzeText);
if isnan(frametoanalyze)
    frametoanalyze=double.empty;
end
end
% Remove or add 'number' to the required number of configurations
Arenaconfig=menu('Choose Configuration','1','2','3','4','5','6','7','8','9','10','11','12','13','14','15','16');
% Extracting the specific configuration chosen by the user 
Configuration=ArenaConfiguration(1:Configsize,Arenaconfig+1);
Conf=table2array(Configuration);
prompt={'Enter Age'};
title="Input";
dims=[1 40];
AgeAsText=inputdlg(prompt,title,dims);
Age=str2double(AgeAsText);
prompt={'Enter Sex'};
title="Input";
dims=[1 40];
SexAsText=inputdlg(prompt,title,dims);
Arena=double.empty;
while isempty(Arena)
prompt={'Starting Arena?'};
title="Input";
dims=[1 40];
ArenaAsText=inputdlg(prompt,title,dims);
Arena=str2double(ArenaAsText);
if isnan(Arena)
    Arena=double.empty;
end
if Arena==0
    Arena=double.empty;
end
end
%% SECTION2
flydata=zeros(frametoanalyze+2,Numberofarena*4);
flyprocesseddata=cell(Numberofarena,8);
%Extracting data of interest and forming an array
for i=1:Numberofarena
    %Setting up starting points for calculations
    framenumber=frametoanalyze;
    distance=0;
    timeimmobile=0;
    velocity=0;
    VelocityFrames=5399;
    %Calculating data of interest
        for j=2:frametoanalyze
            if or(isnan(trk.data(i,j,2)),isnan(trk.data(i,j-1,2)))
            else
                distance=distance+sqrt((trk.data(i,j-1,2)-trk.data(i,j,2))^2+(trk.data(i,j-1,1)-trk.data(i,j,1))^2);
            end
            if or(isnan(feat.data(i,j,1)),isnan(trk.data(i,j,2)))
                VelocityFrames=VelocityFrames-1;
            else
                if feat.data(i,j,1)<1
                    timeimmobile=timeimmobile+1;
                else
                velocity=velocity+feat.data(i,j,1);
                end
            end
        end
        %Calculating numbers of frames to analyze
    for j=1:frametoanalyze
        if or(isnan(trk.data(i,j,1)),isnan(trk.data(i,j,2)))
            framenumber=framenumber-1;
        end
        %Extracting x, y, velocity, and distance and placing them in to
        %their respective columns. Adds data of interest at the bottom.
        flydata(:,(4*(i-1)+1))=[trk.data(i,1:frametoanalyze,1),framenumber,0]';
        flydata(:,(4*(i-1)+2))=[trk.data(i,1:frametoanalyze,2),distance,VelocityFrames]';
        flydata(:,(4*(i-1)+3))=[feat.data(i,1:frametoanalyze,1),timeimmobile,velocity/(VelocityFrames-timeimmobile)]';
        flydata(:,(4*(i-1)+4))=[feat.data(i,1:frametoanalyze,9),0,0]';
    end
    %Processing Data and compiling in to a table
    flyprocesseddata(i,1)={Conf(((i-1)+Arena),1)};
    flyprocesseddata(i,2)={SexAsText};
    flyprocesseddata(i,3)={Age};
    flyprocesseddata(i,4)={Arena+(i-1)};
    flyprocesseddata(i,5)={flydata(5401,(4*(i-1)+1))};
    flyprocesseddata(i,6)={((flydata(5401,(4*(i-1)+3)))/VelocityFrames)*100};
    flyprocesseddata(i,7)={flydata(5401,(4*(i-1)+2))};
    flyprocesseddata(i,8)={flydata(5402,(4*(i-1)+3))};
end

%Sets up table with variable names
FlyFinal=cell2table(flyprocesseddata,...
    'VariableNames',{'Genotype','Gender','Age','Arena','Frames','PercentImmobile','Distance','Velocity'});
%% SECTION3
%Writing to file
if i==1
    %If analyzing data from a single arena, arena number added to name of file
    % Replace MHC by the desired name for the saved file
    FileName=strcat("MHC ",cell2mat(SexAsText),cell2mat(AgeAsText),cell2mat(ArenaAsText),".xls");
else
    % Replace MHC by the desired name for the saved file
    FileName=strcat("MHC ",cell2mat(SexAsText),cell2mat(AgeAsText),".xls");
end
%Prompting save path
[file,path]=uiputfile(FileName);
CSVFileName=strcat(path,'Flydata',FileName);
FileName=strcat(path,file);
writetable(FlyFinal,FileName);
xlswrite(CSVFileName,flydata)
