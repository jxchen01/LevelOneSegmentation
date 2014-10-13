function [labelIdx, labelMat]=getTrainingLabel(info)

sqNum=info.sqNum;
idxBase=info.idxBase;
trainingFrame=info.trainingFrame;

%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%% load training labels %%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%
str=['../sq',num2str(sqNum),'/mask/img0',num2str(idxBase+trainingFrame),'_background.png'];
bg=imread(str);
bg=(bg>1e-8);

str=['../sq',num2str(sqNum),'/mask/img0',num2str(idxBase+trainingFrame),'_cell.png'];
cl=imread(str);
cl=(cl>1e-8);

% check for confliction
conflictLabel=bg & cl;
cl(conflictLabel)=false;

%%%% generate labels %%%%
clLabel=find(cl);
bgLabel=find(bg);
labelIdx=cat(1,clLabel,bgLabel); % cell labels first 

clNum=length(clLabel);
bgNum=length(bgLabel);
numTraining = clNum+bgNum;

labelMat=cell(numTraining,1);
for i=1:1:clNum
    labelMat{i}='cellBody';
end
for i=clNum+1:1:numTraining
    labelMat{i}='background';
end
