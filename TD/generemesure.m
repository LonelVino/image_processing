% fichier generemesure.m
% [Y,map,X,moy1,sigma1,moy2,sigma2]=generemesure

function [Y,map,X,moy1,sigma1,moy2,sigma2]=generemesure
[X,map]=imread('objets.bmp');
moy1=150;
sigma1=15;
moy2=120;
sigma2=40;

X_l=size(X,1);
X_c=size(X,2);
Y=zeros(size(X));

Y=...
   (moy1+sigma1*randn(X_l,X_c)).*(double(X)==0)+...
   (moy2+sigma2*randn(X_l,X_c)).*(double(X)==1);
Y=(Y>=0).*Y;
Y=(Y<=255).*Y+255*(Y>255);
Y=uint8(Y);
iptsetpref('ImshowBorder','tight')
figure
imshow(X,map)
drawnow
figure
map=gray(256);
imshow(Y,map)
drawnow