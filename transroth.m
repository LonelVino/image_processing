% file transroth.m
% Command
% transroth (anglei, transi, hoi)
% anglei: angle of rotation in degrees (example 10)
% transi: translation vector (example [0 0])
% hoi: homothety (example 0.9)
%
% Principle:
% We apply to the image X the transformation constituted of a translation, a rotation and a homothety to obtain
% 
% Then measure the rotation and the homothety independently of the translation,
% this assuming that we only have X and Y.
% The result is displayed at the end ('estimated angle').
% It can be compared to the rotation value used
% to generate the image Y ('initial angle').
% It is the same for the homothety; we display the result
% ('estimated homothety') and we compare it to the value used
% to generate Y ('initial homothety')
% To measure this angle, we represent the modulus of the transform Fourier
% of the two images X and Y in a system of
% polar coordinates (log10 (r), theta). Then we apply a
% translation measurement method on these two representations.


function transroth(anglei,transi,hoi)
if nargin==0
    anglei=10;
    transi=[0 0];
    hoi=0.9;
end
close all

[ima1,map]=imread('140.context.bmp');
N = 400;

rmin=0.05;rmax=0.4;
r=logspace(log10(rmin),log10(rmax),300);
theta=-pi:pi/180:pi-pi/180;
w=hanning(N)*hanning(N)';


lx=floor(size(ima1,1)/2);
cx=floor(size(ima1,2)/2);
ima1=flipud(ind2gray(ima1,map));
ima2=imrotate(ima1,-anglei,'bicubic');
ima2=imresize(ima2,hoi,'bicubic');
ly=floor(size(ima2,1)/2);
cy=floor(size(ima2,2)/2);
X=ima1(lx-N/2:lx+N/2-1,cx-N/2:cx+N/2-1);
Y=ima2(ly-N/2+transi(2):ly+N/2-1+transi(2),...
    cy-N/2+transi(1):cy+N/2-1+transi(1));
clear ima1 ima2
figure
imshow(X)
axis xy
title('X')
xlabel('x')
ylabel('y')
drawnow
figure
imshow(Y)
axis xy
title('Y')
xlabel('x')
ylabel('y')
drawnow
TFX=abs(fftshift(fft2(double(X).*w)));
TFY=abs(fftshift(fft2(double(Y).*w)));
xi=r'*cos(theta);
yi=r'*sin(theta);
[x,y]=meshgrid((-N/2:N/2-1)/N,(-N/2:N/2-1)/N);
TFXpol=interp2(x,y,TFX,xi,yi,'cubic');
TFYpol=interp2(x,y,TFY,xi,yi,'cubic');
figure, set(gcf, 'Position', [0,0,800,800])
subplot(2,2,1), mesh(-N/2:N/2-1,-N/2:N/2-1,x), title('X of sampling'); 
subplot(2,2,2), mesh(-N/2:N/2-1,-N/2:N/2-1,y), title('Y of sampling');
subplot(2,2,3), plot(xi), title('Cosine of Interpolation');
subplot(2,2,4), plot(yi), title('Sine of Interpolation')

figure
imagesc(180*theta/pi,log10(r),TFXpol)
colormap([(255:-1:0)'/256 (255:-1:0)'/256 (255:-1:0)'/256])
set(gca,'YTick',log10(rmin:0.05:rmax));
set(gca,'YTickLabel',rmin:0.05:rmax);
axis xy
title('tf de X')
xlabel('angle (en degre)')
ylabel('frequence reduite')
grid on
figure
imagesc(180*theta/pi,log10(r),TFYpol)
colormap([(255:-1:0)'/256 (255:-1:0)'/256 (255:-1:0)'/256])
set(gca,'YTick',log10(rmin:0.05:rmax));
set(gca,'YTickLabel',rmin:0.05:rmax);
axis xy
title('tf de Y')
xlabel('angle (en degre)')
ylabel('frequence reduite')
grid on
drawnow
TFTFX=fft2(TFXpol);
TFTFY=fft2(TFYpol);
correlphase=real(fftshift(ifft2(TFTFY./(TFTFX+1e-10))));
figure
axecorrel=-size(correlphase,1)/2:size(correlphase,1)/2-1;
imagesc(180*theta/pi,...
    axecorrel,correlphase)
colormap([(255:-1:0)'/256 (255:-1:0)'/256 (255:-1:0)'/256])
axis xy
title('correlation de phase')
grid on
drawnow
[tab,posx]=max(correlphase);
[~,posy]=max(tab);
anglem=180*theta(posy)/pi;
if(anglem<-90)
    anglem=anglem+180;
elseif(anglem>90)
    anglem=anglem-180;
end
disp(['angle initial = ' num2str(anglei)])
disp(['angle estime = ' num2str(anglem)])
disp(['homothetie initiale = ' ...
        num2str(hoi)])
disp(['homothetie estimee = ' ...
        num2str((r(end)/r(1))^(-axecorrel(posx(posy))/length(r)))])
set(figure,'Renderer','zbuffer');
mesh(180*theta/pi,...
    axecorrel(posx(posy)-10:posx(posy)+10),...
    correlphase(posx(posy)-10:posx(posy)+10,:));
title('correlation de phase')

