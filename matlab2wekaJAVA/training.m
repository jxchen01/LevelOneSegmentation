function [myModel, numPixel] = training(opt)

%%%% data information %%%%
sqNum=opt.sqNum;
idxBase=opt.idxBase;
imgType=opt.imgType;

%%%% program parameters %%%%
trainingFrame=opt.trainingFrame;
opt_frangi=opt.opt_frangi;
se_tophat=opt.se_tophat;

myClassifier=opt.myClassifier;
myParameter=opt.myParameter;

%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%% generate training data %%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%
info=struct('sqNum',sqNum,'idxBase',idxBase,'imgType',...
    imgType,'trainingFrame',trainingFrame);
[labelIdx,labelMat]=getTrainingLabel(info);

%%% load raw image %%%
str=['../sq',num2str(sqNum),'/raw/img0',num2str(idxBase+trainingFrame),imgType];
I0=imread(str);
[feaMatTraining, numFeature, featureNames]=FeatureGeneration(I0,opt_frangi,se_tophat);
classIdx=numFeature+1;

trainingMat=[num2cell(feaMatTraining(labelIdx,:)),labelMat];
trainWeka = matlab2weka('segmentation_train',featureNames,trainingMat,classIdx);

myModel = trainWekaClassifier(trainWeka,myClassifier,myParameter);

numPixel=length(I0(:));