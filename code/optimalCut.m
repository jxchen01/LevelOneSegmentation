function opt_ctlList=optimalCut(ctlList, ctl, rg, Grad, Iv)

smoothness=2;
minJump=10;
colLength = 10;
[dimx,dimy]=size(Iv);

%%%%%%%%%%%%%%%%%%%%%%%%
%%%%% get outer boundary %%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%
se_dil = strel('disk',8);
se_1 = strel('disk',1);
dilatedCell = imdilate(ctl,se_dil);
bounding = dilatedCell & rg;
outer_med = imdilate(bounding, se_1) - bounding;
outer_med = bwmorph(outer_med,'thin',1);
outerList = sortPixels(outer_med, dimx, dimy);

%%%%%%%%%%%%%%%%%%%%%%%%
%%%%% get inner boundary %%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%
[inX,inY] = ind2sub([dimx,dimy], ctlList(2:1:(end-1)));
innerList=cat(2,inX, inY);

%%%%%%%%%%%%%%%%%%%%%%%%
%%%%% build column graph %%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%
colWidth = size(outerList,1);
GV=zeros(colLength,colWidth);
GVtoRaw=cell(colLength,colWidth);
for i=1:1:colWidth
    tx=outerList(i,1); ty=outerList(i,2);
    idx=knnsearch(innerList,[tx ty]);
    px=innerList(idx,1); py=innerList(idx,2);
    
    dx=(tx-px)/(colLength-1);
    dy=(ty-py)/(colLength-1);
    GV(1,i)=Grad(px,py)*Iv(px,py);
    GVtoRaw{1,i}=[px,py];
    for j=1:1:colLength-1
        sx=round(px+dx*j);
        sy=round(py+dy*j);
        GV(j+1,i)=Grad(sx,sy)*Iv(px,py);
        GVtoRaw{j+1,i}=[sx,sy];
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% convert GV to an edge-weighted graph %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%

numNode=colWidth*colLength+2;
GE_init=zeros(numNode*(2*smoothness+1),3);
sid=0;
for i=1:1:(colWidth-1)
    for j=1:1:colLength
        ind1=sub2ind([colLength,colWidth],j,i);
        for k=-smoothness:1:smoothness
            j2=j+k;
            if(j2<1 || j2>colLength)
                continue;
            end
            ind2=sub2ind([colLength,colWidth],j2,i+1);
            sid=sid+1;
            GE_init(sid,1)=ind1;
            GE_init(sid,2)=ind2;
            GE_init(sid,3)=GV(ind2);
        end
    end
end
sid0=sid;

%%%%%%%%%%%%%%%%%%%%%%%%
%%%%% all pair shortest path %%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%

GE_all= sparse(GE_init(1:sid,1), GE_init(1:sid,2), GE_init(1:sid,3), numNode-2, numNode-2);
dist_all = graphallshortestpaths(GE_all);
rangeMat = zeros(colWidth,colWidth);
for i=1:1:colWidth
    ind1=sub2ind([colLength,colWidth],1,i);
    for j=(i+minJump):1:colWidth
        ind2=sub2ind([colLength,colWidth],1,j);
        rangeMat(i,j)=dist_all(ind1,ind2)/(j-i);
    end
end
rangeMat(rangeMat==0)=Inf;

for i=2:1:colWidth
    ind1=sub2ind([colLength,colWidth],1,i);
    for j=(i+minJump+2):1:colWidth
        ind2=sub2ind([colLength,colWidth],1,j);
        %queryMat=rangeMat((i+1):1:(j-2),(i+1):1:(j-1));
        %minCost = min(queryMat(:));
        %if(minCost<Inf)
        if(rangeMat(i+1,j-1)<Inf)
            sid=sid+1;
            GE_init(sid,1)=ind1;
            GE_init(sid,2)=ind2;
            %GE_init(sid,3)=(j-i+1)*minCost;
            GE_init(sid,3)=(j-i+1)*rangeMat(i+2,j-2);
        end
    end
end

%%%% node S %%%%
for j=1:1:colLength
    ind2=sub2ind([colLength,colWidth],j,1);
    sid=sid+1;
    GE_init(sid,1)=numNode-1;
    GE_init(sid,2)=ind2;
    GE_init(sid,3)=GV(ind2);
end

%%%% node T %%%%
for j=1:1:colLength
    ind1=sub2ind([colLength,colWidth],j,colWidth);
    sid=sid+1;
    GE_init(sid,1)=ind1;
    GE_init(sid,2)=numNode;
    GE_init(sid,3)=1;
end

% sid=sid+1;
% GE_init(sid,1)=numNode;
% GE_init(sid,2)=numNode-1;
% GE_init(sid,3)=1;

GE= sparse(GE_init(:,1), GE_init(:,2), GE_init(:,3), numNode, numNode);

[dist, path, ~] = graphshortestpath(GE, ...
    numNode-1, numNode, 'Method','Acyclic');

%disp(dist)

R= zeros(dimx,dimy);
len = length(path);
jumpFlag=0;

[ti,tj]=ind2sub([colLength,colWidth],path(2));
t=GVtoRaw{ti,tj};
if(~isempty(t))
        R(t(1),t(2))=1;
else
    disp('wrong path');
    keyboard
end
px=t(1);py=t(2);
px0=t(1);py0=t(2);
t0=tj;

for k=3:1:(len-1)
    [ti,tj]=ind2sub([colLength,colWidth],path(k));
    t=GVtoRaw{ti,tj};
    [xx,yy]=bresenham(px,py,t(1),t(2));
    
    for j=1:1:length(xx)
        R(xx(j), yy(j))=1;
    end
    px=t(1);py=t(2);

    if(tj>t0+1)
        %disp('jump')
        %disp([t0,tj])
        if(jumpFlag)
            %disp('multiple jump');
            %keyboard
            opt_ctlList = find(ctl>0);
            return
        end
        jumpFlag=1;
        %queryMat=rangeMat((t0+1):1:(t0+10),(tj-10):1:(tj-1));
        %queryMat=rangeMat((t0+1):1:(tj-1),(t0+1):1:(tj-1));
        %[tmp, a] = min(queryMat);
        %[tmp, b] = min(tmp);
        %disp([t0+a(b),t0+b]);
        ind1=sub2ind([colLength,colWidth],1, t0+2);
        ind2=sub2ind([colLength,colWidth],1, tj-2);
        GE_ij= sparse(GE_init(1:sid0,1), GE_init(1:sid0,2), GE_init(1:sid0,3), numNode-2, numNode-2);
        [~, path_ij, ~] = graphshortestpath(GE_ij,ind1, ind2, 'Method','Acyclic');
        
        [tik,tjk]=ind2sub([colLength,colWidth],path_ij(1));
        t=GVtoRaw{tik,tjk};
        pxk=t(1); pyk=t(2);
        for kk=2:1:length(path_ij)
            [tik,tjk]=ind2sub([colLength,colWidth],path_ij(kk));
            t=GVtoRaw{tik,tjk};
            [xx,yy]=bresenham(pxk,pyk,t(1),t(2)); 
            for j=1:1:length(xx)
                R(xx(j), yy(j))=1;
            end
            pxk=t(1);pyk=t(2);
        end
    end
    
    t0=tj;
end
%%% link the first and the last node %%%
[xx,yy]=bresenham(px0,py0,px,py);
for j=1:1:length(xx)
    R(xx(j), yy(j))=1;
end

%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%% extract the centerline %%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%
Rs=imfill(R,'holes');
opt_ctl=bwmorph(Rs,'thin',Inf);
opt_ctlList = find(opt_ctl>0);

