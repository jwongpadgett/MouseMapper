%%%File to Test on %%%
handles.pathName ='D:\Jessica\Stryker\MiceVR\replays\'
handles.fileName= '-2017-2-9-15-47-54-1';
handles.startVal =0;
handles.endVal =1;

%%%Scenario Info
xmlFile = xmlread('D:\Jessica\Stryker\MiceVR\scenarios\nb_02.xml');
doc = xmlFile.getElementsByTagName('document');
doc = doc.item(0);
trees=doc.getElementsByTagName('trees');
trees = trees.item(0);
t  = trees.getElementsByTagName('t');
walls=doc.getElementsByTagName('walls');
walls = walls.item(0);
w = walls.getElementsByTagName('wall');
handles.wpos = {[]};
handles.wrot = {[]};
handles.tpos = {[]};
handles.wsca = {[]};
for iter=0:w.getLength-1
    holder = w.item(iter).getElementsByTagName('pos').item(0).getFirstChild.getData;
    handles.wpos(iter+1,1:3) = textscan(char(holder),'%f;%f;%f');
    holder = w.item(iter).getElementsByTagName('rot').item(0).getFirstChild.getData;
    handles.wrot(iter+1,1:3) = textscan(char(holder),'%f;%f;%f');
    holder = w.item(iter).getElementsByTagName('scale').item(0).getFirstChild.getData;
    handles.wsca(iter+1,1:3) = textscan(char(holder),'%f;%f;%f');
end
for iter=0:t.getLength-1
    holder = t.item(iter).getElementsByTagName('pos').item(0).getFirstChild.getData;
    handles.tpos(iter+1,1:3) = textscan(char(holder),'%f;%f;%f');
end

%%%Process Replay info%%%
hold on;
cd(handles.pathName);
if iscell(handles.fileName)
   numFiles = size(handles.fileName,2); 
else
   numFiles =1;
end
for i = 0:numFiles-1
    if(numFiles>1) %Subplotting for multiple files
        if mod(i,8)==0 % At maximum 8 figures per image
           figure; 
        end
        subplot(2,4,mod(i,8)+1);
        fileID = fopen(handles.fileName{i+1});
        fN = handles.fileName{i+1};
    else
        fileID = fopen(handles.fileName);%Single File Case
        fN = handles.fileName;
        figure;
    end
    rewName = ['rew_',fN];
    %get replay points
    
    holderA = textscan(fileID, '%f,%f,%f;%f');
    holderB = holderA(1);
    xPos = holderB{1};
    holderB = holderA(3);
    zPos =holderB{1};
    holderB = holderA(4);
    euler =holderB{1};

    pose = [xPos(1:length(euler)), zPos(1:length(euler)), euler];
    clear holderA holderB xPos zPos euler

    %Find Outer limits
    xMin = min(pose(:,1));
    %xShift =xMin;
    xShift = pose(1,1);
    xMax = max(pose(:,1));
    zMin = min(pose(:,2));
    %zShift = zMin;
    zShift = pose(1,2);
    zMax = max(pose(:,2));
    numPts = size(pose,1);
    %Set to origin
    pose = pose -[xShift*ones(numPts,1), zShift*ones(numPts,1), zeros(numPts,1)];
    xMax = xMax-xShift;
    xMin = xMin-xShift;
    zMax = zMax-zShift;    
    zMin = zMin-zShift;

    %Percent Traveled
     poseDiff = diff(pose(:,1:2));
     vectDiff = zeros(length(poseDiff),1);
    for v = 1: length(poseDiff)
       vectDiff(v) = norm(poseDiff(v,1:2));%magnitudes of Vector 
    end
    intFrames = 100;
    threshold = 2;
    vectSum = zeros(floor(length(vectDiff)/intFrames),1);%sum of vector magnitudes over threshold time period
    for x = 1:length(vectDiff)/intFrames
        vectSum(x)= sum(vectDiff((x-1)*intFrames+1:(x-1)*intFrames+intFrames+1));
    end
    disp(fN);
    disp(['Percent Time Traveling Over' num2str(threshold) 'units per' num2str(intFrames) 'Frames:']);
    disp(num2str(length(find(vectSum>threshold))/length(vectSum)*100));
    
    startPt = floor(handles.startVal*numPts)+1;
    endPt = ceil(handles.endVal*numPts);
    hold on;
    border = 40;
    
    for iter = 0:length(handles.wrot)-1
        rotMat = [cosd(handles.wrot{iter+1,2}) sind(handles.wrot{iter+1,2}); ...
            -sind(handles.wrot{iter+1,2}) cosd(handles.wrot{iter+1,2})];
        x = handles.wpos{iter+1,1};
        z = handles.wpos{iter+1,3};
        %xScale = handles.wsca{iter+1,1}*2;
        %zScale = handles.wsca{iter+1,3}+50;
        xScale = handles.wsca{iter+1,1};
        zScale = handles.wsca{iter+1,3};
        vert = [-xScale/2,-zScale/2 ;xScale/2,-zScale/2;xScale/2,zScale/2 ;-xScale/2,zScale/2];
        rVert = rotMat*vert';
        patch(rVert(1,:)+x-xShift,rVert(2,:)+z-zShift,'red');
    end
end

%%%Plot info%%%
for iter = 0:length(handles.wrot)-1
        rotMat = [cosd(handles.wrot{iter+1,2}) sind(handles.wrot{iter+1,2}); ...
            -sind(handles.wrot{iter+1,2}) cosd(handles.wrot{iter+1,2})];
        x = handles.wpos{iter+1,1};
        z = handles.wpos{iter+1,3};
        %xScale = handles.wsca{iter+1,1}*2;
        %zScale = handles.wsca{iter+1,3}+50;
        xScale = handles.wsca{iter+1,1};
        zScale = handles.wsca{iter+1,3};
        vert = [-xScale/2,-zScale/2 ;xScale/2,-zScale/2;xScale/2,zScale/2 ;-xScale/2,zScale/2];
        rVert = rotMat*vert';
        patch(rVert(1,:)+x-xShift,rVert(2,:)+z-zShift,'red');
end

for iter=0:size(handles.tpos,1)-1
    viscircles([handles.tpos{iter+1,1}-xShift, handles.tpos{iter+1,3}-zShift],4.5);
end

if startPt<endPt
    plot(pose(startPt:endPt-3,1),pose(startPt:endPt-3,2),'-');
end


%%%QuiverPlot
%findstillTimes
i=1;
stillCounter = 1;
stayed =0;
stillTimes=[];
stillThreshold =0.02;
timeThreshold = 10;%frames
while i <=length(vectDiff)
   if ((vectDiff(i)<=stillThreshold) && (stayed ==0))
       stayed=1;
       stillTimes(stillCounter,1)=i;
   elseif ((vectDiff(i)>stillThreshold)&&(stayed==1))
        stayed=0;
        stillTimes(stillCounter,2)=i;
        if(stillTimes(stillCounter,2)-stillTimes(stillCounter,1)>=timeThreshold)
            stillCounter = stillCounter+1;
        else
            stillTimes(stillCounter,2)=0;
        end
   end
   i=i+1;
end
if stillTimes(end,2)==0
   stillTimes(end,2)=length(vectDiff); 
end
stillTimes(:,3)=stillTimes(:,2)-stillTimes(:,1);
%stem(stillTimes(:,3));

for i = 1:length(stillTimes)
   pos = [pose(stillTimes(i,1),1:2)-[0.5,0.5],1,1];
   rectangle('Position',pos,'Curvature',[1,1],'FaceColor',[0.5,0.1,0.7]);
end