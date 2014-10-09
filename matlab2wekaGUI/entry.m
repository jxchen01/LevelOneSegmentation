%%%% data information %%%%
sqNum=3;
numFrame=5;
idxBase=100;
imgType='.png';

%%%% program parameters %%%%
trainingFrame=1;
opt=struct('FrangiScaleRange', [1 2], ...
    'FrangiScaleRatio', 1, 'FrangiBetaOne', 0.5, ...
    'FrangiBetaTwo', 5, 'verbose',true,...
    'BlackWhite',false);
se_tophat=strel('disk',10,0);

%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%% load training labels %%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%
str=['./sq',num2str(sqNum),'/mask/img0',num2str(idxBase+trainingFrame),'_background',imgType];
bg=imread(str);
bg=(bg>1e-8);

str=['./sq',num2str(sqNum),'/mask/img0',num2str(idxBase+trainingFrame),'_cell',imgType];
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

labelMat=zeros(1,numTraining);
labelMat(1:clNum)=1;
labelMat=uint8(labelMat);

%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%% generate training data %%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%

%%% load raw image %%%
str=['./sq',num2str(sqNum),'/raw/img0',num2str(idxBase+trainingFrame),imgType];
I0=imread(str);
[feaMatTraining, numFeature]=FeatureGeneration(I0,opt,se_tophat);
numPixel=length(I0(:));

feaArray=cell(1,numFeature);
for i=1:1:numFeature
    tmp=feaMatTraining{i};
    a=tmp(labelIdx);
    feaArray{i}=a;
end
clear a tmp

TrainingOutputForWeka(['./sq',num2str(sqNum),'/data'], ...
    feaArray, labelMat, numFeature, numTraining);

%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%% generate all data %%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%
for i=1:1:numFrame
    if(i==trainingFrame)
        AllDataForWeka(['./sq',num2str(sqNum),'/weka/img0',num2str(100+i)], ...
            feaMatTraining, numFeature, numPixel)
    else
        str=['./sq',num2str(sqNum),'/raw/img0',num2str(idxBase+i),imgType];
        I0=imread(str);
        [feaMat, numFeature]=FeatureGeneration(I0,opt,se_tophat);
        AllDataForWeka(['./sq',num2str(sqNum),'/weka/img0',num2str(100+i)], ...
            feaMat, numFeature, numPixel)
    end
end
