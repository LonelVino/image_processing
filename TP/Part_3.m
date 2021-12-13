%% Part 1.3 Obtaining a binary image
root = './appr/';
img_test = imread([root, 'mesure100.png']);

BW = imbinarize(img_test);
figure
subplot(2,2,1), imshowpair(img_test, BW, 'montage'), title('Binarized Image')

% Show the histogram of the gray img
% img_int = typecast(img_test(:), 'int');
subplot(2,2,3), bar3(img_test), title('3D Histogram of the gray level of the image')
subplot(2,2,4), bar3(BW), title('3D Histogram of the binarized, level of the image')