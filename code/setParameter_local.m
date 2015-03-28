function opt=setParameter_local()

%%%% data information %%%%
sqNum=5;
numFrame=73;
idxBase=100;
imgType='.jpg';

%%%% program parameters %%%%
trainingFrame=1;
%trainingFrame=[1,85];
opt_frangi=struct('FrangiScaleRange', [1 2], ...
    'FrangiScaleRatio', 1, 'FrangiBetaOne', 0.5, ...
    'FrangiBetaTwo', 5, 'verbose',false,...
    'BlackWhite',false);
se_tophat=strel('disk',10,0);

myClassifier='trees.RandomForest';
myParameter={'-I 10 -K 3 -S 1'};

opt=struct('sqNum',sqNum,'numFrame',numFrame,...
    'idxBase',idxBase,'imgType',imgType,'trainingFrame',...
    trainingFrame,'opt_frangi',opt_frangi,...
    'se_tophat',se_tophat,'myClassifier',myClassifier,...
    'myParameter',myParameter);

%%%% parameter for step 2 %%%%%%
opt.minArea=30;
opt.MBL=10;

%%% paramter for step 4 %%%%
opt.maxLength=45;
opt.minLength=6; %%% means len>=6
opt.maxCurvature=1.2;


