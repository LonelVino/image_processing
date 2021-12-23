% fichier transfou.m
% Transfer image with FFT(2D) and FFTshift
% Assign the maximum value to the left upper corner value of the image 

function transfou (ima)
[m,n]=size(ima);
wx=blackman(n);
wy=blackman(m);
tfima=fft2(ima.*(wy*wx'));
tfima(1,1)=0;
maxi=max(max(abs(tfima)));
tfima(1,1)=maxi;
tfima_shifted=fftshift(tfima);


set(figure, 'Name', 'Orignal FFT VS FFTShif')
subplot(2,2,1), imagesc(sqrt(abs(tfima))), title('Original FFT of image')
axis('xy'), xlabel('u (en m^-^1)'), ylabel('v (en m^-^1)'), grid on
subplot(2,2,2), imagesc(sqrt(abs(tfima_shifted))), title('Shifted FFT of image')
axis('xy'), xlabel('u (en m^-^1)'), ylabel('v (en m^-^1)'), grid on
subplot(2,2,3), mesh(ifft2(tfima)), title('Original IFFT of image')
subplot(2,2,4), mesh(ifft2(tfima_shifted)), title('Shifted IFFT of image')

set(figure,...
'MenuBar','none',...
'Name','Transforme de Fourier');

imagesc([-n/2 n/2],[-m/2 m/2],sqrt(maxi)-sqrt(abs(tfima_shifted)))
colormap(gray(256)), axis('square'), axis('xy'), xlabel('u (en m^-^1)'), ylabel('v (en m^-^1)')
set(gca,...
'Xgrid','on', 'Ygrid','on',...
'Xtick',(-n/2:n/10:n/2),...
'Ytick',(-m/2:m/10:m/2))