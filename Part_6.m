clc; clear; close all
% Part.6  Geometric Parameters
%% 1. Load the images and generate binarized image
root = './appr/';
coeffs = zeros(201,100);
for i = 1:100
    if i < 10
        num = strcat('00', num2str(i));
    elseif i == 100
        num = strcat('', num2str(i));
    else
        num = strcat('0', num2str(i));
    end
    
    img_test = imread([root, strcat('mesure' , num, '.png')]);
    BW = imbinarize(img_test);
    [B,L,N,A] = bwboundaries(BW);
    B_coeff = FFT_coeff(B);
    coeffs(:,i) = B_coeff;
end

%% 2. Principal Component Analysis
B_coeff_pca = pca(coeffs);



function coeff = FFT_coeff(B)
    complex_BW = B{1}(:,1) + i*B{1}(:,2);
    coeff = dfdir(complex_BW, 100);  % Todo: modify the length of coefficients
end