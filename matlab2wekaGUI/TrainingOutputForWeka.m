function TrainingOutputForWeka(fileName, feaMat, labelMat, numFeature, numPixel)

str=[fileName,'_training.arff'];
fid=fopen(str,'w');

%%%%%%% write  file header %%%%%%%
fprintf(fid,'@RELATION iris\n\n');

for i=1:1:numFeature
    stringOut=['@ATTRIBUTE ',num2str(100+i),'  NUMERIC\n'];
    fprintf(fid,stringOut);
end
%     fprintf(fid,'@ATTRIBUTE intensity  NUMERIC\n');
%     fprintf(fid,'@ATTRIBUTE intensityNbr  NUMERIC\n');
%     fprintf(fid,'@ATTRIBUTE FrangiOne  NUMERIC\n');
%     fprintf(fid,'@ATTRIBUTE FrangiTwo  NUMERIC\n');
%     fprintf(fid,'@ATTRIBUTE FrangiTemp  NUMERIC\n');

fprintf(fid,'@ATTRIBUTE class {1,0}\n');

%%%%%%% write data %%%%%%%%
fprintf(fid,'\n@DATA\n');
for i=1:1:numPixel
    for j=1:1:numFeature
        fprintf(fid,'%f,',feaMat{j}(i));
    end
    fprintf(fid,'%d\n',labelMat(i));
end
%%%%%%% complete %%%%%%%%
fclose(fid);
