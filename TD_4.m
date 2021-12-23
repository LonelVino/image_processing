clc, clear; close all
%% Part 1. Load Images and Fourier Transform
global X; global Y; global N;
X = imread('./img/X.bmp'); Y = imread('./img/Y.bmp');
N = size(X,1);

% Fourier Transform
X_fft = fft2(X); Y_fft=fft2(Y);
% Show Images
X_fft_shifted = abs(fftshift(fft2(X))); Y_fft_shifted = abs(fftshift(fft2(Y)));
figure, set(gcf, 'Position', [0,1200,600,400])
subplot(1,2,1), imshow(X), title('X.bmp')
subplot(1,2,2), imshow(Y), title('Y.bmp')
% Perform Fourier Transformation of these 2 images, check the difference
% between their frequency and angle
% transfou(cast(X, 'double')); transfou(cast(Y, 'double'));

%% Part 2. Calculate the Cross correlation
% Cross Correlation 
% Source: https://ww2.mathworks.cn/matlabcentral/fileexchange/43967-circular-cross-correlation-using-fft
C_fft = conj(X_fft).*Y_fft; % Inter-correlation with FFT
C_ifft = ifft2(C_fft);  % Inverse FFT
div_ifft = ifft2(Y_fft./X_fft); %Y/X ifft

% Visualize Inter-Correlation by ifft, compare with ITDF(Y/X)
figure, set(gcf, 'Position', [600,1200,800,800])
subplot(2,2,1), mesh(C_ifft), title('IFFT of Correlation')
subplot(2,2,2), mesh(-N/2:N/2-1, -N/2:N/2-1,fftshift(C_ifft)), title('IFFT with fftshift of Correlation')
subplot(2,2,3), mesh(-N/2:N/2-1, -N/2:N/2-1,fftshift(ifft2(Y_fft./X_fft))), title('IFFT(Y/X) of Correlation')
subplot(2,2,4), mesh(-N/2:N/2-1, -N/2:N/2-1,fftshift(ifft2(X_fft./Y_fft))), title('IFFT(X/Y) of Correlation')

% Calculate the best transformation distance trans_x and trans_y
% Case 1: Cross-Correlation
C_ifft_shifted = fftshift(C_ifft); C_ifft_sorted = sort(C_ifft_shifted(:), 'descend');
pos_xy = zeros(length(C_ifft_sorted), 2);
for idx = 1:10
    [x_idx, y_idx] = find(C_ifft_shifted == C_ifft_sorted(idx));
    pos_xy(idx, 1) = x_idx-N/2; pos_xy(idx, 2) = y_idx-N/2;
end

% Case 2: Correlation by Division
C_div_sorted = sort(fftshift(div_ifft(:)), 'descend');
pos_xy_div = zeros(length(C_div_sorted), 2);
for idx = 1:10
    [x_idx,y_idx] = find(fftshift(div_ifft) == C_div_sorted(idx));
    pos_xy_div(idx, 1) = x_idx-N/2; pos_xy_div(idx, 2) = y_idx-N/2;
end

% Patch images X and Y together using recoverd shift
find_match(C_ifft, pos_xy(3,1), pos_xy(3,2))
find_match(C_ifft, pos_xy_div(1,1), pos_xy_div(1,2))

%% Part 3. Interpolation
rmin=0.05;rmax=0.4;
r=linspace(rmin,rmax,300);  % frequency
theta=-pi:pi/180:pi-pi/180; % angle

xi=r'*cos(theta);
yi=r'*sin(theta);
[x,y]=meshgrid((-N/2:N/2-1)/N,(-N/2:N/2-1)/N);
TFXpol=interp2(x,y,X_fft_shifted,xi,yi,'cubic');
TFYpol=interp2(x,y,Y_fft_shifted,xi,yi,'cubic');    
% figure, set(gcf,'position',[0,0,800,800]);
% subplot(2,2,1), mesh(x), title('Sampling points of X')
% subplot(2,2,2), mesh(y), title('Sampling points of Y')
% subplot(2,2,3), mesh(xi), title('Cosine Interpolation')
% subplot(2,2,4), mesh(yi), title('Sine Interpolation')

%% Part 4. Display Images of FFT and Inter-correlation of phase
figure
x0=800; y0=0; width=1200; height=800;
set(gcf,'position',[x0,y0,width,height])

subplot(2,3,1)
imagesc(180*theta/pi,r,TFXpol)
colormap([(255:-1:0)'/256 (255:-1:0)'/256 (255:-1:0)'/256])
axis xy, title('tf de X'), xlabel('pixel'), ylabel('frequence reduite')
grid on

subplot(2,3,4)
imagesc(180*theta/pi,r,TFYpol)
colormap([(255:-1:0)'/256 (255:-1:0)'/256 (255:-1:0)'/256])
axis xy, title('tf de Y'), xlabel('pixel'), ylabel('frequence reduite')
grid on; 

corre_div = real(fftshift(div_ifft));
subplot(2,3,2)
mesh(-20:20, -20:20, corre_div(80:120, 80:120));
title('3D correlation of division'),

subplot(2,3,5), axis xy, title('2D correlation of division'), grid on
imagesc(-20:20, -20:20, corre_div(80:120, 80:120))

subplot(2,3,3)
mesh(-20:20, -20:20, C_ifft_shifted(80:120, 80:120));
title('3D inter-correlation'),

subplot(2,3,6), axis xy, title('2D inter-correlation'), grid on
imagesc(-20:20, -20:20, C_ifft_shifted(80:120, 80:120))

colormap(parula(5))
drawnow
