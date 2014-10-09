function I=loadPrediction(str,dimx,dimy)

I=zeros(dimx,dimy);

fid=fopen(str,'r');
a=fgetl(fid);
while(~strcmp(a,'@data'))
    a=fgetl(fid);
end
a=fgetl(fid);
sig=1;
while(~feof(fid))
    I(sig)=str2double(a(end-2));
    a=fgetl(fid);
    sig=sig+1;
end
