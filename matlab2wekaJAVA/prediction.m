function predicted=prediction(myModel, I0, numPixel, opt)

%%%% program parameters %%%%
opt_frangi=opt.opt_frangi;
se_tophat=opt.se_tophat;
%%%%%%%%%%%%%%%%%%%
[dimx,dimy]=size(I0);
dumbLabel = cell(numPixel,1);
for i=1:1:9
    dumbLabel{i}='background';
end
for i=10:1:numPixel
    dumbLabel{i}='cellBody';
end

[feaMatNew, numFeature,featureNames]=FeatureGeneration(I0,opt_frangi,se_tophat);
newMat=[num2cell(feaMatNew),dumbLabel];

classIdx=numFeature+1;
    
testWeka = matlab2weka('segmentation_test',featureNames,newMat,classIdx);
predicted = wekaClassify(testWeka,myModel,2);
    
predicted =reshape(predicted,dimx,dimy);
predicted = (predicted>0);
   
%str=['./sq',num2str(sqNum),'/segmentation/img0',num2str(idxBase+i),'.png'];
%imwrite(tempImg,str);

