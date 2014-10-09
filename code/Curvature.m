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
    
    ft = fittype(['a*(x-' num2str(xp0) ')+',num2str(yp0)],...
    'dependent','y','independent','x','coefficients',{'a'});

    pl= ctlList(i-appLength+1:1:(i-1), :);
    cf = fit(pl(:,1), pl(:,2),ft);
    a=confint(cf);
    if(a(2)-a(1)>1)
        fty = fittype(['a*(x-' num2str(yp0) ')+',num2str(xp0)],...
        'dependent','y','independent','x','coefficients',{'a'});
        cfy = fit(pl(:,2), pl(:,1),fty);
        b=confint(cfy);
        if((b(2)-b(1)) < (a(2)-a(1)))
            ori1=atan(1/coeffvalues(cfy));
        else
            ori1=atan(coeffvalues(cf));
        end
    else
        ori1=atan(coeffvalues(cf));
    end
    
%     polypara= polyfit(pl(:,1),pl(:,2), 1);
%     if(isnan(polypara(1)))
%         ori1=pi/2;
%     else
%         ori1=atan(polypara(1));
%     end
    xp1=ctlList(i-appLength+1,1); 
    yp1=ctlList(i-appLength+1,2);
    
    
    pl= ctlList((i+1):1:i+appLength-1, :);
    cf = fit(pl(:,1), pl(:,2),ft);
    a=confint(cf);
    if(a(2)-a(1)>1)
        fty = fittype(['a*(x-' num2str(yp0) ')+',num2str(xp0)],...
        'dependent','y','independent','x','coefficients',{'a'});
        cfy = fit(pl(:,2), pl(:,1),fty);
        b=confint(cfy);
        if((b(2)-b(1)) < (a(2)-a(1)))
            ori2=atan(1/coeffvalues(cfy));
        else
            ori2=atan(coeffvalues(cf));
        end
    else
        ori2=atan(coeffvalues(cf));
    end
    
%     polypara = polyfit(pl(:,1),pl(:,2), 1);
%     if(isnan(polypara(1)))
%         ori2=pi/2;
%     else
%         ori2=atan(polypara(1));
%     end
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