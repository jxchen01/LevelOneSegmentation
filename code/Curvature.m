function [ctlImg,flag]=Curvature(ctlList,ctlImg,opt)

appLength=6;
ctlImg=logical(ctlImg);
ctlLength=size(ctlList,1);
ws = warning('off','all');  % Turn off warning

curveValue=zeros(1,ctlLength);

% %%%%% compute dx and dy %%%%%%
% dx=zeros(1,ctlLength); dxx=zeros(1,ctlLength);
% dy=zeros(1,ctlLength); dyy=zeros(1,ctlLength);
% 
% dx(2:1:(end-1))=0.5.*(ctlList(3:1:end,1) - ctlList(1:1:(end-2),1));
% dy(2:1:(end-1))=0.5.*(ctlList(3:1:end,2) - ctlList(1:1:(end-2),2));
% 
% dxx(3:1:(end-2))=0.5.*(dx(4:1:(end-1)) - dx(2:1:(end-3)));
% dyy(3:1:(end-2))=0.5.*(dy(4:1:(end-1)) - dy(2:1:(end-3)));
             
for i=appLength:1:(ctlLength-appLength+1)
%     curveValue(i)=(dx(i)*dyy(i)-dy(i)*dxx(i))/...
%         (hypot(dx(i),dy(i)))^3;
    xp0=ctlList(i,1); yp0=ctlList(i,2);
    
    ori1=OrientFit(ctlList(i-appLength+1:1:(i-1),:), xp0, yp0);
    xp1=ctlList(i-appLength+1,1); 
    yp1=ctlList(i-appLength+1,2);
    
    ori2=OrientFit(ctlList((i+1):1:i+appLength-1, :), xp0,yp0);
    xp2=ctlList(i+appLength-1,1); 
    yp2=ctlList(i+appLength-1,2);
    
    dtheta = abs(ori1-ori2);
    
    sgn=(xp2-xp0)*(xp1-xp0)+(yp2-yp0)*(yp1-yp0);    
    if(sgn>0 && dtheta<pi/2)
        dtheta=pi-dtheta;
    elseif(sgn<=0 && dtheta>pi/2)
        dtheta=pi-dtheta;
    end
    curveValue(i)=dtheta;
end

cutIdx=find(curveValue>opt.maxCurvature);
%newList = [];
%ss=cell(1,1);
if(numel(cutIdx)>0) 
    for i=1:1:numel(cutIdx)
        ctlImg(ctlList(cutIdx(i),1),ctlList(cutIdx(i),2))=false;
    end
    ctlImg=bwmorph(ctlImg, 'spur');
    flag=true;
else
    flag=false;
end

% cc = bwconncomp(ctlImg);
% 
% unsolved=0;
% for i=1:1:cc.NumObjects
%     tmp=cc.PixelIdxList{i};
%     newLength=numel(tmp);
%     if(newLength<opt.maxLength)
%         if(newLength>opt.minLength)
%             newList=cat(1,newList,tmp);
%         end
%     else
%         unsolved=unsolved+1;
%         znew = zeros(size(ctlImg));
%         znew(tmp)=1;
%         ss{unsolved}=struct('pList',tmp,'ctl',znew);
%     end
% end
% 
% if(unsolved>0)
%     flag=-1;
% else
%     flag=1;
% end

warning(ws)