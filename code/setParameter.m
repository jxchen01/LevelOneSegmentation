function opt=setParameter()

%%%%% may need user input %%%%
frangi_min=5;
frangi_max=10;
frangi_ratio=1;

DoG_min=5;
DoG_max=10;
DoG_ratio=1;

Gaussian_min=2;  % also use for gaussian gradient
Gaussian_max=8;
Gaussian_ratio=1;

LoG_min=5;
LoG_max=10;
LoG_ratio=1;

top_hat_size=20;
numTraining = 1;

%%%% program parameters %%%%
opt_frangi=struct('FrangiScaleRange', [frangi_min frangi_max], ...
    'FrangiScaleRatio', 1, 'FrangiBetaOne', 0.5, ...
    'FrangiBetaTwo', 5, 'verbose',false,...
    'BlackWhite',false);
se_tophat=strel('disk',top_hat_size,0);

myClassifier='trees.RandomForest';
myParameter={'-I 10 -K 3 -S 1'};

opt=struct('opt_frangi',opt_frangi,'se_tophat',se_tophat,'myClassifier',myClassifier,...
    'myParameter',myParameter,'numTraining',numTraining);

% %%%% parameter for step 2 %%%%%%
% opt.minArea=30;
% opt.MBL=10;
% 
% %%% paramter for step 4 %%%%
% opt.maxLength=45;
% opt.minLength=6; %%% means len>=6
% opt.maxCurvature=1.2;


