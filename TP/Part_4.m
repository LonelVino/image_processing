clc; clear; close all
% Part.4  Extraction of the contour of the shape
%% 1. Calculate boundaries of regions in the image.
root = './appr/';
img_test = imread([root, 'mesure100.png']);
BW = imbinarize(img_test);

[B,L,N,A] = bwboundaries(BW);
% Display the image with the boundaries overlaid. Add the region number next to every boundary (based on the label matrix). Use the zoom tool to read individual labels.
figure
subplot(2,2,1), imshow(BW); title('Original Image'), hold on;
colors=['b' 'g' 'r' 'c' 'm' 'y'];
for k=1:length(B)
  boundary = B{k};
  cidx = mod(k,length(colors))+1;
  subplot(2,2,2), plot(boundary(:,1), boundary(:,2),...
       colors(cidx),'LineWidth',2); 
  title('The contour of the binary image')

  % randomize text position for better visibility
  rndRow = ceil(length(boundary)/(mod(rand*k,7)+1));
  col = boundary(rndRow,2); row = boundary(rndRow,1);
  h = text(col+1, row-1, num2str(L(row,col)));  % text the label of each boundary on the image
  set(h,'Color',colors(cidx),'FontSize',14,'FontWeight','bold');
end

B_re_build = rebuild(B);
subplot(2,2,3), plot(B_re_build);

%% Fourier Transform of the boundary and find the best cmax
% coeff=dfdir(z,cmax),  z=dfinv(coeff,N)
function re_build = rebuild(B)
    complex_BW = B{1}(:,1) + i*B{1}(:,2);
    coeff = dfdir(complex_BW, 50);
    re_build = dfinv(coeff, 314);
end

