% fichier testpark.m

x=1;
y=1;
K=1e-3;
N=300;
F=30;
numiter=50;

ima=double(imread('park','bmp'));
ima=ima(x:256+x-1,y:256+y-1)-1;
figure
imshow(ima,[0 255],'InitialMagnification','fit');
set(gca,'Position',[0 0 1 1])
zoom on
drawnow
IMA=fft2(ima);
figure;
imshow(log10(abs(fftshift(IMA))),[0 5],'InitialMagnification','fit');
set(gca,'Position',[0 0 1 1])
zoom on
drawnow
res=128*ones(N);
%H=modflou(N,F*(N/256),F*(N/256));
H=modflou2(N,(F/256),(F/256));

res(1:256,1:256)=ima;
imares=real(ifft2(fft2(res).*...
   (conj(fftshift(H))./((abs(fftshift(H)).^2)+K))));
imares=(imares>=0).*imares;
imares=(imares<=255).*imares+255*(imares>255);

figure;
imshow(log10(abs(H)),[-5 0],'InitialMagnification','fit');
set(gca,'Position',[0 0 1 1])
zoom on
drawnow

figure
imshow(res,[0 255],'InitialMagnification','fit')
set(gca,'Position',[0 0 1 1])
hold on
plot([1 256 256 1 1],[1 1 256 256 1],'r')
hold off
zoom on
drawnow

figure
imshow(imares,[0 255],'InitialMagnification','fit')
set(gca,'Position',[0 0 1 1])
hold on
plot([1 256 256 1 1],[1 1 256 256 1],'r')
hold off
zoom on
drawnow

lignesans=imares(50,:);

figure
for k=1:numiter
   res(1:256,1:256)=ima;
   imshow(res,[0 255],'InitialMagnification','fit')
   set(gca,'Position',[0 0 1 1])
   hold on
   plot([1 256 256 1 1],[1 1 256 256 1],'r')
   hold off
   RES=fft2(res);
   RES=fftshift(RES);
   RES=RES.*H;
   RES=fftshift(RES);
   res=real(ifft2(RES));
   disp(['etape ' int2str(k)  ' : ' ...
      num2str(sum(sum((ima-res(1:256,1:256)).^2)))]) 
   drawnow
end
zoom on

res(1:256,1:256)=ima;
imares=real(ifft2(fft2(res).*...
   (conj(fftshift(H))./((abs(fftshift(H)).^2)+K))));

figure
imshow(imares,[0 255],'InitialMagnification','fit')
set(gca,'Position',[0 0 1 1])
hold on
plot([1 256 256 1 1],[1 1 256 256 1],'r')
hold off
zoom on
drawnow
%imares=imares(1:256,1:256);
imares=(imares>=0).*imares;
imares=(imares<=255).*imares+255*(imares>255);

ligneavec=imares(50,:);

%imwrite(imares,gray(256),'parknet.bmp','bmp');
figure
plot(...
1:N,ligneavec,'y',...
1:N,[ima(50,:) res(50,257:N)],...
1:N,ima(50,1)*ones(1,N),'r')
axis([1 N 0 255])
figure
plot(...
1:N,lignesans,'y',...
1:N,[ima(50,:) 128*ones(1,(N-256))],...
1:N,ima(50,1)*ones(1,N),'r')
axis([1 N 0 255])