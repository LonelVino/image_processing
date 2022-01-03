% TD 2-5
clear; clf; clc; close all
%% 5.1 Linear Quantification
% [X,map]=imread('img/lena512.bmp'); 
% figure,imshow(X,map) 
% 
% f1 = figure('Name', 'Gray Level');
% f1.Position = [200 200 540 400];
% idx = 0;
% for i = 2:2:32
%     idx = idx + 1;
%     I=ind2gray(X,map); 
%     [X2,map2]=gray2ind(I, i);  
%     
%     subplot(4,4,idx);
%     imshow(X2,map2) 
%     title(['Gray Level: ', int2str(i)]);
% end

%% 5.2  Error propagation representation (monochrome image)
% gammas = linspace(0.1,5,16);
% q_levels = (2:4:64);
% 
% f2 = figure('Name', 'Quantized Level');
% f2.Position = [0 0 800 800];
% idx = 0;
% for q_level = q_levels
%     idx = idx+1;
%     [X3,map3]=propagation_g('img/lena512.bmp', q_level, 1); % gamma: 1(default)
%     subplot(4,4, idx)
%     imshow(X3,map3) 
%     title(['Level: ', int2str(q_level)]);
% end
% 
% f3 = figure('Name', 'Gamma Level');
% f3.Position = [600 1000 800 800];
% idx = 0;
% for gamma = gammas
%     idx = idx+1;
%     [X4,map4]=propagation_g('img/lena512.bmp', 36, gamma); % quantized level: 1(default, original)
%     subplot(4,4, idx)
%     imshow(X4,map4) 
%     title(['Gamma: ', int2str(gamma)]);
% end
% 
% drawnow
% 

%% 5.3 Optimal 

[X5,map5]=optimnb('img/fillebmp.bmp',16); 
[X6,map6]=optimnb('lena512.bmp',16); 
