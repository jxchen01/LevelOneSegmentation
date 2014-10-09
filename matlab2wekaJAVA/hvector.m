% hvector - Hessian matrix eigenvector and rod-like shape measure
%
% Usage:  [cim, epx, epy] = hvector(im, sigma, thresh, radius, disp)
%
% Arguments:   
%            im     - image to be processed.
%            sigma  - standard deviation of smoothing Gaussian. Typical
%                     values to use might be 1-3.
%            thresh - threshold (optional). Try a value ~1000.
%            radius - radius of region considered in non-maximal
%                     suppression (optional). Typical values to use might
%                     be 1-3.
%            disp   - optional flag (0 or 1) indicating whether you want
%                     to display corners overlayed on the original
%                     image. This can be useful for parameter tuning.
%
% Returns:
%            cim    - rod-like shape measure.
%            epx      - x coordinate of the eigenvector e+.
%            epy      - y coordinate of the eigenvector e-.
%

% Author: 
% Xiaomin Liu   
% Department of Computer Science & Engineering
% University of Notre Dame
% xliu9@nd.edu
%
% November 2010

function [cim, epx, epy] = hvector(I, sigma, thresh, radius, disp)
    
    error(nargchk(2,5,nargin));
    
    % Generate Gaussian filter of size 6*sigma (+/- 3sigma) and of
    % minimum size 1x1.
    g = fspecial('gaussian',max(1,fix(6*sigma)), sigma);
    
    im = conv2(I, g, 'same');
    %figure, imshow(im);
    
    dx = [-1 0 1; -1 0 1; -1 0 1]; % Derivative masks
    dy = dx';
    
    Ix = conv2(im, dx, 'same');    % Image derivatives
    Iy = conv2(im, dy, 'same');    

   
    Ix2 = conv2(Ix, dx, 'same'); % Smoothed squared image derivatives
    Iy2 = conv2(Iy, dy, 'same');
    Ixy = conv2(Ix, dy, 'same');
    
    alpha = sqrt((Ix2-Iy2).^2+4*Ixy.^2);
    N = sqrt((Iy2-Ix2+alpha).^2+4*Ixy.^2);
    %eigen vector e+
    epx = 2*Ixy./N;
    epy = (Iy2-Ix2+alpha)./N;
    %eigen vector e-
    enx = (Iy2-Ix2+alpha)./N;
    eny = -2*Ixy./N;
    [A,B] = size(I);
    %[x,y] = meshgrid(1:1:B,1:1:A);
    %figure, quiver(x,y,epx,epy);      %display the vector field   
    
    %cim = (Ix2.*Iy2 - Ixy.^2).*(Ix2+Iy2)./abs(Ix2+Iy2); % elliptic measure
    %cim = (Ix2.*Iy2 - Ixy.^2); % elliptic measure
    
    %eigen vlaues
    lamda1 = (Ix2+Iy2)+sqrt((Ix2-Iy2).^2+4*Ixy.^2);
    lamda2 = (Ix2+Iy2)-sqrt((Ix2-Iy2).^2+4*Ixy.^2);
    %cim = (-min(lamda1,lamda2)+max(lamda1,lamda2)).*(-max(lamda1,lamda2));
    %cim = (-min(lamda1,lamda2)+max(lamda1,lamda2)).*(min(lamda1,lamda2));
    lvalue1 = abs(lamda1);
    lvalue2 = abs(lamda2);
    cim = zeros(A,B);
    for i = 1:A
        for j = 1:B
            if lvalue1(i,j)>lvalue2(i,j)
                cim(i,j) = -sign(lamda1(i,j))*(lvalue1(i,j)-lvalue2(i,j));
                %cim(i,j) = lamda2(i,j)-lamda1(i,j);
            else
                if lvalue2(i,j)>lvalue1(i,j)
                    cim(i,j) = -sign(lamda2(i,j))*(lvalue2(i,j)-lvalue1(i,j));
                    %cim(i,j) = lamda1(i,j)-lamda2(i,j);
                end
            end
        end
    end
       
    %figure, imshow(cim<-30);
   
    
    
