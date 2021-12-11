% transrot.m file
% Command
% transrot (anglei, transi)
% anglei: angle of rotation in degrees
% transi: translation vector (example [10 20])
%
% Principle:
% We apply to the image X the transformation constituted
% of a translation and a rotation to obtain the image Y. 
%
% allow measure the rotation independently of the translation.
% The result is displayed at the end ('estimated angle').
% 
% To measure this angle, we represent the modulus of the transform Fourier
% of the two images X and Y in a system of polar coordinates (r, theta). 
% Then we apply a translation measurement method on these two representations.


function transrot(anglei,transi)
if nargin == 0
    anglei = 10;
    transi = [0 0];
end
close all

%% Part0: Parameters
N = 400;
rmin = 0.05;rmax = 0.4;
r = linspace(rmin,rmax,300);
theta = -pi:pi/180:pi-pi/180;
w = hanning(N)*hanning(N)';  % add hanning window


%% Part1: rotation and transformation, then visualize the real image
[ima1,map] = imread('140.context.bmp');  % Load image
ima1 = flipud(ind2gray(ima1,map));  % flipud Flip array in up/down direction.
ima2 = imrotate(ima1,-anglei,'bicubic');  
% Resize image 1 and image 2, and transformation of image 2
lx = floor(size(ima1,1)/2); cx = floor(size(ima1,2)/2);  % length of X dimension and Y dimension (Image 1)
ly = floor(size(ima2,1)/2); cy = floor(size(ima2,2)/2);  % length of X dimension and Y dimension (Image 2)
X = ima1(lx-N/2:lx+N/2-1,cx-N/2:cx+N/2-1);
Y = ima2(ly-N/2+transi(2):ly+N/2-1+transi(2),...
    cy-N/2+transi(1):cy+N/2-1+transi(1));
clear ima1 ima2

figure
subplot(1,2,1), imshow(X)
axis xy, title('Initial Image'), xlabel('x'), ylabel('y')
subplot(1,2,2), imshow(Y)
axis xy, title('Image after rotation and transfromation'), xlabel('x'), ylabel('y')
drawnow

%% Part2: Interpolation of the FT 
%TFX = log10(abs(fftshift(fft2(X.*w))));
%TFY = log10(abs(fftshift(fft2(Y.*w))));
TFX = abs(fftshift(fft2(double(X).*w)));
TFY = abs(fftshift(fft2(double(Y).*w)));
xi = r'*cos(theta);  yi = r'*sin(theta); % the query points of FFT
[x,y] = meshgrid((-N/2:N/2-1)/N,(-N/2:N/2-1)/N);

% Interpolation
% Vq = interp2(X,Y,V,Xq,Yq) interpolates to find Vq, the values of the
%     underlying 2-D function V at the query points in matrices Xq and Yq.
%     Matrices X and Y specify the points at which the data V is given.
%  
%     Xq can be a row vector, in which case it specifies a matrix with
%     constant columns. Similarly, Yq can be a column vector and it
%     specifies a matrix with constant rows.
TFXpol = interp2(x,y,TFX,xi,yi,'cubic');  
TFYpol = interp2(x,y,TFY,xi,yi,'cubic');

figure, set(gcf, 'Position', [0,0,800,400])
subplot(1,2,1), imagesc(theta*(180/pi),r,TFXpol)  % X axis: angle (degree), Y axis: reduced frequency, gray intensity: amplitude of TTF
colormap([(255:-1:0)'/256 (255:-1:0)'/256 (255:-1:0)'/256]) 
axis xy; title('tf of initial image (After interpolation)')
xlabel('angle (en degre)'), ylabel('reduced frequence'), grid on

subplot(1,2,2),  imagesc(theta*(180/pi),r,TFYpol)  % X axis: angle (degree), Y axis: reduced frequency, gray intensity: amplitude of TTF
colormap([(255:-1:0)'/256 (255:-1:0)'/256 (255:-1:0)'/256])
axis xy; title('tf of transformed and rotated image (After interpolation)')
xlabel('angle (en degre)'), ylabel('reduced frequence'), grid on
drawnow

%% Part3: calculate the correlation of phase
%TODO: Understand the Correlation theorem and calculation
TFTFX = fft2(TFXpol);
TFTFY = fft2(TFYpol);
correlphase = real(fftshift(ifft2(TFTFY./(TFTFX+1e-10))));

figure, set(gcf, 'Position', [0,400,800,400])
axecorrel = -size(correlphase,1)/2:size(correlphase,1)/2-1;
subplot(1,2,1), imagesc(180*theta/pi, axecorrel,correlphase)
colormap([(255:-1:0)'/256 (255:-1:0)'/256 (255:-1:0)'/256])
axis xy, title('correlation de phase'), grid on

[tab,posx] = max(correlphase);
[~,posy] = max(tab);
anglem = 180*theta(posy)/pi;
if(anglem<-90)
    anglem = anglem+180;
elseif(anglem>90)
    anglem = anglem-180;
end
disp(['maximum at ' num2str(axecorrel(posx(posy)))])
disp(['initial angle  =  ' num2str(anglei)])
disp(['estimated angle  =  ' num2str(anglem)])

subplot(1,2,2), mesh(180*theta/pi,...
    axecorrel(posx(posy)-10:posx(posy)+10),...
    correlphase(posx(posy)-10:posx(posy)+10,:));
title('correlation de phase')

