function ctl = checkCircle(ctl,opt)

cc= bwconncomp(ctl);
ep= bwmorph(ctl,'endpoint');
[dimx,dimy]=size(ctl);

for i=1:1:cc.NumObjects
    a=cc.PixelIdxList{i};
    tmp=ep(a);
    t=nnz(tmp);
    if(t~=2)
        if(t==0)
            timg=zeros(dimx,dimy);
            timg(a)=1;
            idxList=sortPixels(timg, dimx, dimy);
            [newImg,flag]=Curvature(idxList,timg,opt);
            while(~flag)
                opt.maxCurvature = 0.9*opt.maxCurvature;
                [newImg,flag]=Curvature(idxList,timg,opt);
            end
            ctl(a)=0;
            ctl(newImg)=1;
        end
    end
end