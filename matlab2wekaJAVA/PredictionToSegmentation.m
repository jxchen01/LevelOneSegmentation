%%%% data information %%%%
sqNum=3;
numFrame=1;
idxBase=100;
imgType='.png';
dimx=300;dimy=300;

for i=1:1:numFrame
    str=['./sq',num2str(sqNum),'/prediction/img0',num2str(idxBase+i),'.arff'];
    I=loadPrediction(str,dimx,dimy);
    str=['./sq',num2str(sqNum),'/segmentation/img0',num2str(idxBase+i),'.png'];
    imwrite(I,str);
end