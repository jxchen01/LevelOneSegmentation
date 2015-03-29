function [myModel, numPixel] = training(img,opt)

% input:
%   -img,  matrix of size M x N x 3 x K.
%          3 layers: raw, cell, non-cell
%          K is the number of training images
%   -opt,  structure of parameters


%%%% program parameters %%%%
myClassifier=opt.myClassifier;
myParameter=opt.myParameter;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%% generate training data %%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
numTrainingImage = numel(trainingFrame);
trainingMat = [];
for trainIdx = 1:1:numTrainingImage

    info=struct('sqNum',sqNum,'idxBase',idxBase,'imgType',...
    imgType,'trainingFrame',trainingFrame(trainIdx));
    [labelIdx,labelMat]=getTrainingLabel(info);

    %%% load raw image %%%
    str=['../sq',num2str(sqNum),'/raw/img0',...
        num2str(idxBase+trainingFrame(trainIdx)),imgType];
    I0=imread(str);
    [feaMatTraining, numFeature, featureNames]=...
        FeatureGeneration(I0,opt_frangi,se_tophat);
    trainingMatSingle=[num2cell(feaMatTraining(labelIdx,:)),labelMat];
    trainingMat = cat(1, trainingMat, trainingMatSingle);
end
classIdx=numFeature+1;
trainWeka = matlab2weka('segmentation_train',featureNames,trainingMat,classIdx);

myModel = trainWekaClassifier(trainWeka,myClassifier,myParameter);

numPixel=length(I0(:));