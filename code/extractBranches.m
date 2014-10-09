function [branchList, singleCross]= extractBranches(singleCross, singleBP, ctl, labMat)
se3=strel('square',3);
currentBP = imdilate(singleCross,se3);
numPixelBP=length(singleBP);
numBranch=0;
branchList=cell(3,1);
nbr=[-1 -1;-1 0;-1 1;0 -1;0 1;1 -1;1 0;1 1];
[dimx,dimy]=size(ctl);
[BPx,BPy]=ind2sub([dimx,dimy],singleBP);
ws = warning('off','all');  % Turn off warning

for j=1:1:numPixelBP
    tx=BPx(j);
    ty=BPy(j);
    for k=1:1:8
        px=tx+nbr(k,1);
        py=ty+nbr(k,2);

        if(ctl(px,py)==1 && singleCross(px,py)==0)
            numBranch=numBranch+1;     
            pixelList = [];
            %%%% search until bp/ep %%%%
            flag=1;
            while(flag && labMat(px,py)==2)
                pixelList=cat(1,pixelList,[px,py]);
                singleCross(px,py)=1;
                flag=0;
                for kk=1:1:8
                    cx=px+nbr(kk,1);
                    cy=py+nbr(kk,2);
                    if(cx<1 || cy<1 || cx>dimx || cy>dimy)
                        continue;
                    end
                    if(ctl(cx,cy)==1 && singleCross(cx,cy)==0)
                        px=cx;py=cy;
                        flag=1;
                        break;
                    end
                end
            end
            
            if(labMat(px,py)==1)
                pixelList=cat(1,pixelList,[px,py]);
                singleCross(px,py)=1;
            end
            
            branchLength=size(pixelList,1);

            if(currentBP(px,py)>0 && branchLength>2)
                % self-loop
                branchLength1 = floor(branchLength/2);
                try
                pixelList1 = pixelList(1:1:branchLength1,1:2);
                catch
                    keyboard
                end
                
                ft = fittype(['a*(x-' num2str(tx) ')+'...
                    num2str(ty)],'dependent','y','independent',...
                    'x','coefficients',{'a'});
                
                if(branchLength1>6)
                    cf = fit(pixelList1(1:6,1), pixelList1(1:6,2),ft);
                    ori1=atan(coeffvalues(cf));
                elseif(branchLength1>1)
                    cf = fit(pixelList1(:,1), pixelList1(:,2),ft);
                    ori1=atan(coeffvalues(cf));
                else % length =1
                    ori1=atan((pixelList1(end,2)-ty)/(pixelList1(end,1)-tx));
                end
                
                branchList{numBranch}=struct('pixelList',...
                    pixelList1,'branchLength',branchLength1,'orientation',ori1);
                
                numBranch = numBranch +1;
                branchLength2 = branchLength - branchLength1 ;
                pixelList2 = pixelList(end:-1:branchLength1+1,1:2);
                
                ft = fittype(['a*(x-' num2str(px) ')+'...
                    num2str(py)],'dependent','y','independent',...
                    'x','coefficients',{'a'});
                
                if(branchLength2>6)
                    cf = fit(pixelList2(1:6,1), pixelList2(1:6,2),ft);
                    ori2=atan(coeffvalues(cf));
                elseif(branchLength2>1)
                    cf = fit(pixelList2(:,1), pixelList2(:,2),ft);
                    ori2=atan(coeffvalues(cf));
                else % length =1
                    ori2=atan((pixelList(end-1,2)-...
                        pixelList(end,2))/(pixelList(end-1,1)-pixelList(end,2)));
                end
                
                branchList{numBranch}=struct('pixelList',...
                    pixelList2,'branchLength',branchLength2,'orientation',ori2);
                continue;
            end
            
            ft = fittype(['a*(x-' num2str(tx) ')+'...
                 num2str(ty)],'dependent','y','independent',...
                 'x','coefficients',{'a'});

            if(branchLength>6)
                cf = fit(pixelList(1:6,1), pixelList(1:6,2),ft);
                ori=atan(coeffvalues(cf));
                %polypara = polyfit(pixelList(1:6,1) , pixelList(1:6,2), 1);
                %ori=atan(polypara(1));
            elseif(branchLength>1)
                cf = fit(pixelList(:,1), pixelList(:,2),ft);
                ori=atan(coeffvalues(cf));
                %polypara = polyfit(pixelList(:,1) , pixelList(:,2), 1);
                %ori=atan(polypara(1));
            else % length =1
                ori=atan((py-ty)/(px-tx));
            end
            
            branchList{numBranch}=struct('pixelList',...
                pixelList,'branchLength',branchLength,'orientation',ori);
        end
    end
end
warning(ws)