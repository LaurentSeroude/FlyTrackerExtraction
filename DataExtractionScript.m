%Loading in data and setting up initial parameters
trkdatasize=size(trk.data);
Numberofarena=trkdatasize(1,1);
Configsize=size(ArenaConfiguration)
Configsize=Configsize(1)
% Change frametonalyze value to accommodate length of analyzed video file, 5400: 3 min at 30 frames/s
frametoanalyze=5400;
% Remove or add ?number? to the required number of configurations
Arenaconfig=menu('Choose Configuration','1','2','3','4','5','6','7','8','9','10','11','12','13','14','15','16');
% Replace ArenaConfiguration by the name of your configuration file
Configuration=ArenaConfiguration(1:Configsize,Arenaconfig+1);
Conf=table2array(Configuration);
prompt={'Enter Age'};
title="Input";
dims=[1 40];
AgeAsText=inputdlg(prompt,title,dims);
Age=str2double(AgeAsText);
prompt={'Starting Arena'};
title="Input";
dims=[1 40];
ArenaAsText=inputdlg(prompt,title,dims);
Arena=str2double(ArenaAsText);
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
    flyprocesseddata(i,2)={"Male"};
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
    % Replace MHC Male by the desired name for the saved file
    FileName=strcat("MHC Male",cell2mat(AgeAsText),cell2mat(ArenaAsText),".xls");
else
    % Replace MHC Male by the desired name for the saved file
    FileName=strcat("MHC Male",cell2mat(AgeAsText),".xls");
end
%Prompting save path
[file,path]=uiputfile(FileName);
CSVFileName=strcat(path,'Flydata',FileName);
FileName=strcat(path,file);
writetable(FlyFinal,FileName);
xlswrite(CSVFileName,flydata)
