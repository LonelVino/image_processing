%% Part 1.3 Obtaining a binary image
root = './appr/';
img_test = imread([root, 'mesure100.png']);

BW = imbinarize(img_test);
figure
imshowpair(img_test, BW, 'montage'), title('Original Images(left); Binarized Image(right)')

% Show the histogram of the gray img
% img_int = typecast(img_test(:), 'int');
figure; set(gcf, 'Position', [0 0 800 600]);
bar3(img_test), title('3D Histogram of the gray level of the image') 
figure; set(gcf, 'Position', [0 600 800 600]);
bar3(BW), title('3D Histogram of the binarized, level of the image')