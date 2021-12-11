clc; clear; close all;


%% Part 2.1 Test the infleunce of Sampling period
% ima=genesin(30,30);
% imaech=echantil(ima,0.01,0.01); 
% imaech=echantil(ima,0.02,0.02);


%% Part 2.2 Create an image by a gray level, use imresize() to resize the image
N=800; 
ima=zeros(N,N);

for i = 1:N
    for j = 1:N
            cos_val = cos(pi*(i^2+j^2)/(2*N));
            ima(i,j) =1/2+1/2*cos_val;
    end
end

figure
subplot(2,2,1), imshow(ima), title('Original Image (cosine)');

% imresize(A, SCALE,method) returns an image that is SCALE times the
%    size of A, which is a grayscale, RGB
ima_nearest=imresize(ima,0.5,'nearest');%ima est l�image g�n�r�e 
subplot(2,2,2), imshow(ima_nearest), title('Resize Image, size: 0.5, nearest')
ima3=imresize(ima,0.5,'bilinear'); 
subplot(2,2,3), imshow(ima3),  title('Resize Image, size: 0.5, bilinear') 
ima4=imresize(ima,0.8,'bilinear'); 
subplot(2,2,4), imshow(ima4),  title('Resize Image, size: 0.8, bilinear') 

figure
ima5=imresize_old(ima,1,'bilinear'); 
subplot(2,2,1), imshow(ima5), title('Resize Image, size: 0.5,  filter: 11, bilinear') 
ima6=imresize_old(ima,0.5,'bilinear', 0); 
subplot(2,2,2), imshow(ima6), title('Resize Image, size: 0.5,  filter: 0, bilinear')  
ima7=imresize_old(ima,0.5,'bilinear', 51); 
subplot(2,2,3), imshow(ima7), title('Resize Image, size: 0.5,  filter: 51, bilinear') 
ima8=imresize_old(ima,0.8,'bilinear', 51); 
subplot(2,2,4), imshow(ima8), title('Resize Image, size: 0.8,  filter: 51, bilinear')