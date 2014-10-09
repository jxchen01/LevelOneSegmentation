function [feaMat, numFeature]=FeatureGeneration(I0,opt,se)

[dimx,dimy]=size(I0);

%%% apply frangi filter %%%
[outIm,whatScale,FrangiDirection] = FrangiFilter2D(double(I0), opt);

%%% Feature 1: raw intensity [0,1] %%%
I=mat2gray(I0);

%%% Feature 2: intensity after tophat [0,1]%%%
I_tophat=imtophat(I,se);

%%% Feature 3: vesselness [0,1] %%%
vess=mat2gray(outIm);

%%% Feature 4: the selected scale [0,1]%%%
vessScale = mat2gray(whatScale); 

%%% Feature 5: local orderness %%%
xx=vess.*cos(FrangiDirection);
yy=vess.*sin(FrangiDirection);

kernelSize=5;
temp=ones(dimx,dimy);
myKernel=ones(kernelSize,kernelSize);
myTemp=conv2(temp,myKernel,'same');
myTemp=myTemp./(kernelSize^2);
myKernel=myKernel./(kernelSize^2);

xc=conv2(xx,myKernel,'same');
yc=conv2(yy,myKernel,'same');

xc=xc./myTemp;
yc=yc./myTemp;

orderMat=hypot(xc,yc);

%%% Feature 6: vessleness after tophat %%%
[outIm_top,whatScale_top,FrangiDirection_top] = FrangiFilter2D(double(I_tophat), opt);
vessTophat=mat2gray(outIm_top);

%%% build Feature Matrix %%%
numFeature=6;
feaMat=cell(1,numFeature);
feaMat{1}=I;
feaMat{2}=I_tophat;
feaMat{3}=vess;
feaMat{4}=vessScale;
feaMat{5}=orderMat;
feaMat{6}=vessTophat;