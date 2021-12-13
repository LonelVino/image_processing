% fichier segmentation
N=5;

[X,map]=imread('mesure.bmp');
I=ind2gray(X,map);
if isa(I,'uint8')
    I=double(I)/255.0;
end
clear X map

MOY = colfilt(I,[N N],'sliding','mean'); 
SIGMA = colfilt(I,[N N],'sliding','std'); 

figure(1);imshow(I);drawnow
figure(2);imshow(MOY);drawnow
figure(3);imshow(SIGMA);drawnow
figure(4);imhist(I);drawnow
figure(5);imhist(MOY);drawnow
figure(6);imhist(SIGMA);drawnow
figure(7);imshow(MOY>0.55);drawnow
figure(8);imshow(SIGMA<0.09);drawnow
VM=reshape(MOY,256^2,1);
VS=reshape(SIGMA,256^2,1);
figure(9);plot(VM,VS,'.')
m1=0.35;s1=0;
m2=0.8;s2=0.18;
hold on;plot([m1 m2],[s1 s2],'r')
A=([m1 s1;m2 s2])\[1;1];
figure(10);imshow((A(1)*MOY+A(2)*SIGMA)>1)
