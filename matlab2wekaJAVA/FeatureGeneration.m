function [feaMat, numFeature,featureNames]=FeatureGeneration(I0,opt,se)

[dimx,dimy]=size(I0);

%%% apply frangi filter %%%
Iex=zeros(dimx+20,dimy+20);
Iex(11:end-10, 11:end-10) = I0(:,:);
tValue=mean(I0(:));
Iex(1:1:10,:)=tValue; Iex((end-9):1:end,:)=tValue; 
Iex(:,1:1:10)=tValue; Iex(:,(end-9):1:end)=tValue; 
[outImEX,whatScaleEX,FrangiDirectionEX] = FrangiFilter2D(double(Iex), opt);

%%% Feature 1: raw intensity [0,1] %%%
I=mat2gray(I0);

%%% Feature 2: intensity after tophat [0,1]%%%
I_tophat=mat2gray(imtophat(I,se));

%%% Feature 3: vesselness [0,1] %%%
vess=mat2gray(outImEX(11:end-10, 11:end-10));

%%% Feature 4: the selected scale [0,1]%%%
vessScale = mat2gray(whatScaleEX(11:end-10, 11:end-10)); 

%%% Feature 5: local orderness %%%
xx=vess.*cos(FrangiDirectionEX(11:end-10, 11:end-10));
yy=vess.*sin(FrangiDirectionEX(11:end-10, 11:end-10));

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
Iex=zeros(dimx+20,dimy+20);
Iex(11:end-10, 11:end-10)=I_tophat;
tValue=mean(I_tophat(:));
Iex(1:1:10,:)=tValue; Iex((end-9):1:end,:)=tValue; 
Iex(:,1:1:10)=tValue; Iex(:,(end-9):1:end)=tValue; 
[outIm_top_EX,~,~] = FrangiFilter2D(double(Iex),opt);
vessTophat=mat2gray(outIm_top_EX(11:end-10, 11:end-10));

%%% build Feature Matrix %%%
numFeature=6;

feaMat=cat(2,I(:),I_tophat(:),vess(:),vessScale(:),...
    orderMat(:),vessTophat(:));

featureNames={'rawIntens','tophatIntens','vess',...
    'vessScale','orderMat','vessTophat','class'};