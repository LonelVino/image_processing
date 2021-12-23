clc; clear; close all
% Part.5  Geometric Parameters
%% 1. Load the images and generate binarized image
root = './appr/';
ori_img = imread([root, 'mesure100.png']);
BW = imbinarize(ori_img);
[B,L,N,A] = bwboundaries(BW);


%% 2. Perform translation, rotation and homothetics of the original image
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
params = [trans_params rotate_params scale_params];


%% 3. Find parameters that also independent of translation, rotation and homothetics.
fields = fieldnames(trans_params);
ind_fields = {}; eps = 1e-2;  % the tolerable error
for i = 1:length(fields)
    k = fields(i); key = k{1};
    first_param = params(1).(key); flag = true; 
    for j = 2:3
        param = params(j);
        value = param.(key);
        if isa(value,'double') == true && (length(value) == 1)
            if abs(value - first_param) >= eps
                flag = false;
            end
        elseif ~isequal(value, first_param) 
            flag = false;
        end
    end
    if flag == true
        disp(['Independent Key:' key])
        ind_fields{end+1} = key;
    end
end


%% 4.Display boundaries of the 4 kinds of images in a same figure
ori_B = bwboundaries(BW); ori_B = ori_B{1};
trans_B = bwboundaries(trans_img); trans_B = trans_B{1};
rota_B = bwboundaries(rota_img); rota_B = rota_B{1};
scale_B = bwboundaries(scale_img); scale_B = scale_B{1};

figure, set(gcf, 'Position', [0,400, 600, 400])
plot(ori_B(:,1), ori_B(:,2),'LineWidth',3); hold on;
plot(trans_B(:,1), trans_B(:,2), 'LineWidth',2); hold on;
plot(rota_B(:,1), rota_B(:,2), 'LineWidth',2); hold on;
plot(scale_B(:,1), scale_B(:,2), 'LineWidth',2); hold on;
legend('Origin', 'Translation', 'Rotation', 'Homothetics')
drawnow
