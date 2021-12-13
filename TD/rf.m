% fichier rf
close all
N=5;

[X,map]=imread('mesure.bmp');
I=ind2gray(X,map);
if isa(I,'uint8')
    I=double(I)/255.0;
end
clear X map

MOY = colfilt(I,[N N],'sliding','mean'); 
SIGMA = colfilt(I,[N N],'sliding','std'); 

m1=0.35;s1=0;
m2=0.8;s2=0.18;
A=([m1 s1;m2 s2])\[1;1];
segm=(A(1)*MOY+A(2)*SIGMA)>1;
figure(1);imshow(segm);drawnow
[label,N]=bwlabel(segm);
figure(2);imshow(label,[0 N]);drawnow;
surf=zeros(1,N);
peri=zeros(1,N);
for n=1:N
   surf(n)=sum(sum(label==n));
   peri(n)=sum(sum(bwperim(label==n)));
end
disp(4*pi*surf./(peri.^2))




