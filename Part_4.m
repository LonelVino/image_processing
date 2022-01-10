clc; clear; close all
% Part.4  Extraction of the contour of the shape
%% 1. Calculate boundaries of regions in the image.
root = './appr/';
img_test = imread([root, 'mesure100.png']);
BW = imbinarize(img_test);

[B,L,N,A] = bwboundaries(BW);

%% 2. Display the image with the boundaries overlaid. Add the region number next to every boundary (based on the label matrix). Use the zoom tool to read individual labels.
figure(1), set(gcf, 'Position', [0,0, 600, 300])
subplot(1,2,1), imshow(BW); title('Original Image'), hold on;
colors=['b' 'g' 'r' 'c' 'm' 'y'];
for k=1:length(B)
    boundary = B{k};
    cidx = mod(k,length(colors))+1;
    subplot(1,2,2), plot(boundary(:,1), boundary(:,2),...
       colors(cidx),'LineWidth',2); 
    hold on;
    % Plot the centroid of the boundary
    B_centroid = [mean(boundary(:,1))  mean(boundary(:,2))];
    figure(1), scatter(B_centroid(1), B_centroid(2), 'LineWidth', 3); 
    h = text(B_centroid(1)+5, B_centroid(2)-5, 'Centroid');  % text the label of each boundary on the image
    set(h,'Color', 'r', 'FontSize',10,'FontWeight','bold');
    title('The contour of the binary image')
    drawnow
end

%% 3. Use FFT and IFFT perform transformation on the boundary, find the best cmax
% Evaluate the similarity of different cmax
similarities = zeros(length(boundary)-1, 1);

B_resized_all = {};
figure(2), set(gcf, 'Position', [0, 400, 400, 400])
title('Animation display of different contours', 'FontSize', 14, 'fontname', 'times')
for i = 1:length(boundary)-1
    % Rebuild the boundary using FFT and IFFT
    B_rebuild = rebuild(boundary, i);
    B_resize = resize_boundary(B_rebuild, boundary);
    B_resized_all{end + 1} = B_resize;
    % Calculate the similarity between rebuilt and original boundary
    crr = xcorr2(boundary, B_rebuild);
    [ssr,snd] = max(crr(:));
    similarities(i) = ssr;
    % Plot the rebuilt boundary 
    if mod(i,10)== 1
        figure(2), plot(boundary(:,1), boundary(:,2), 'LineWidth',3); hold on;
        figure(2), plot(B_resize(:,1), B_resize(:,2), 'LineStyle', ':', 'LineWidth',2); 
        drawnow
        pause(0.1)
    end
end


%% Plot line chart of similarities, add notes where BEST cmax is
figure,  set(gcf, 'Position', [400, 800, 600, 600])
loglog(similarities, 'lineWidth', 2, 'Color', 'g'), 
xlabel('cmax', 'FontSize', 14, 'fontname', 'times')
ylabel('Cross-correlation (simialrity)', 'FontSize', 14, 'fontname', 'times')
[max_sim,idx] = max(similarities(1:length(similarities)-10)); % set a truncation to remove the cmax not meeting our requirements
xline(idx, 'lineWidth', 2, 'Color', 'r');
text(idx, min(similarities)*1.01, sprintf('cmax=%d with maximum similary', idx),...
    'fontsize', 15, 'fontname', 'times', 'color', 'r')
title('The similarity between original and rebuilt boundary', 'FontSize', 14, 'fontname', 'times')

% Plot several reconstructed contours, find the best one with highest similarity 
figure,  set(gcf, 'Position', [1000, 400, 1000, 800])
text( 0.5, 0, 'My Nice Title', 'FontSize', 14', 'FontWeight', 'Bold', ...
      'HorizontalAlignment', 'Center', 'VerticalAlignment', 'Bottom' ) ;
% title('Rebuild Contours \n(green contour -- original contour)\n(blue contour -- rebuild contour)',...
%     'FontSize', 20, 'fontname', 'times')
for i = 1:16
    subplot(4,4,i);
    plot(boundary(:,1), boundary(:,2), 'LineWidth',3); hold on;
    B_rebuild = cell2mat(B_resized_all(i));
    plot(B_rebuild(:,1), B_rebuild(:,2),  'lineWidth', 2, 'Color', 'g');
    set(gca,'xtick',[],'ytick',[])
    title(sprintf('Truncation length: %d', i), 'fontsize', 12, 'fontname', 'times');
    if i == idx
        text(min(B_rebuild(:,1)), mean(B_rebuild(:,2)), 'Best Reconstruction', 'FontSize', 14, 'fontname', 'times', 'color', 'r')
    end
end

%% Fourier Transform of the boundary and find the best cmax
% coeff=dfdir(z,cmax),  z=dfinv(coeff,N)
function re_build = rebuild(B, cmax)
    complex_BW = B(:,1) + 1i*B(:,2);
    coeff = dfdir(complex_BW, cmax);
    ifft_B = dfinv(coeff, 1000);
    re_build(:,1) = real(ifft_B(:,1));
    re_build(:,2) = imag(ifft_B(:,1));
end

function resize_B = resize_boundary(B_rebuild, boundary)
    % Resize the rebuilt boundary according to the original boundary
    ratio_x = (max(boundary(:,1))-min(boundary(:,1))) / (max(B_rebuild(:,1))-min(B_rebuild(:,1))); 
    ratio_y = (max(boundary(:,2))-min(boundary(:,2))) / (max(B_rebuild(:,2))-min(B_rebuild(:,2))); 
    B_rebuild(:,1) = B_rebuild(:,1) * ratio_x; B_rebuild(:,2) = B_rebuild(:,2) * ratio_y;  
    % Translate according to the distance between the Centroids of 2 boundary
    re_B_centroid = [mean(B_rebuild(:,1)) mean(B_rebuild(:,2))]; B_centroid = [mean(boundary(:,1))  mean(boundary(:,2))];
    disp_dist = B_centroid - re_B_centroid;
    resize_B(:,1) = B_rebuild(:,1) + disp_dist(1); resize_B(:,2) = B_rebuild(:,2) + disp_dist(2); 
end

