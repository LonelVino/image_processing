clc; clear; close all
% Part.5  Geometric Parameters
%% 1. Load the images and generate binarized image
root = './appr/';
img_test = imread([root, 'mesure100.png']);
BW = imbinarize(img_test);
[B,L,N,A] = bwboundaries(BW);

%% 2. Find parameters that also independent of translation, rotation and homothetics.
orig_params = regionprops(BW);
% Affine transformation of the orignal binary image
trans_X = 30; trans_Y =20;
trans_img = imtranslate(BW, [trans_X trans_Y]);

rota_angle = 20;
rota_img = imrotate(BW, rota_angle);

scale_size = 0.8;
scale_img = imresize(BW, scale_size);

figure, set(gcf, 'Position', [0,0,800, 400])
subplot(2,2,1), imshow(BW), title('The Original Image')
subplot(2,2,2), imshow(trans_img), title('The Tranlated Image')
subplot(2,2,3), imshow(rota_img), title('The Rortated Image')
subplot(2,2,4), imshow(scale_img), title('The scaled Image')

trans_params = regionprops(trans_img, 'all');
rotate_params = regionprops(rota_img, 'all');
scale_params = regionprops(scale_img, 'all');
disp(orig_params); disp(trans_params); disp(rotate_params); disp(scale_params);

for i in

cen_x = [orig_params.Centroid(1) trans_params.Centroid(1)];
cen_y = [orig_params.Centroid(2) trans_params.Centroid(2)];
figure, scatter(cen_x, cen_y)