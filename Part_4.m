clc; clear; close all
% Part.4  Extraction of the contour of the shape
%% 1. Calculate boundaries of regions in the image.
classes_ = [1:6];
root = './appr';
image_samples = {}; contour_samples = {};
for idx = 1:length(classes_)
    Bi_images = get_img_byclass('./appr', classes_(idx), false); % get images in the same class true: show images
    BW = cell2mat(Bi_images(1));
    [B,L,N,A] = bwboundaries(BW);
    image_samples{end+1} = cell2mat(Bi_images(1));
    contour_samples{end+1} = B{:};
end


%% 2. Display the image with the boundaries overlaid. Add the region number next to every boundary (based on the label matrix). Use the zoom tool to read individual labels.
figure(1), set(gcf, 'Position', [0,0, 600, 300])
subplot(1,2,1), imshow(BW); title('Original Image'), hold on;
boundary = B{:};
subplot(1,2,2), plot(boundary(:,1), boundary(:,2), 'LineWidth',2); 
hold on;
% Plot the centroid of the boundary
B_centroid = [mean(boundary(:,1))  mean(boundary(:,2))];
figure(1), scatter(B_centroid(1), B_centroid(2), 'LineWidth', 3); 
h = text(B_centroid(1)+5, B_centroid(2)-5, 'Centroid');  % text the label of each boundary on the image
set(h,'Color', 'r', 'FontSize',10,'FontWeight','bold');
title('The contour of the binary image')
drawnow

%% 3. Use FFT and IFFT perform transformation on the boundary, find the best cmax
% Evaluate the similarity of different cmax
similarities_all = {}; cmax_all = []; B_resized_all = {};
show_anime = false; 
figure(3);  set(gcf, 'Position', [400, 800, 1200, 800])
for i = 1:length(classes_)
    cs = contour_samples(i); boundary=cs{:};
    [similarities, B_resizeds] = get_cmax(boundary, show_anime);
    sim_score= zscore(similarities);
    similarities(sim_score > 2.0) = min(similarities);
    if i == 5 similarities(1:8)= min(similarities); end
    if i == 6 similarities(1:13)= min(similarities); end
    [max_sim,idx] = max(similarities(1:length(similarities)-10)); % set a truncation to remove the cmax not meeting our requirements
    if i == 3 && (max_sim - max(similarities(1:8))<1e2) 
        [max_sim,idx] = max(similarities(1:8)); 
        idxes =  find(similarities(1:10) == max_sim);
        idx = idxes(1);
    end
    % store each class data 
    B_resized_all{end+1} = B_resizeds;
    similarities_all{end+1} = similarities;
    cmax_all(end+1) = idx;
    
    % Plot line chart of similarities, add notes where BEST cmax is
    ax = subplot(3,2,i);
    loglog(similarities, 'lineWidth', 2, 'Color', 'g'), 
    xlabel('cmax', 'FontSize', 14, 'fontname', 'times')
    ylabel('Cross-correlation (simialrity)', 'FontSize', 14, 'fontname', 'times')
    xline(idx, 'lineWidth', 2, 'Color', 'r');
    ylim([min(similarities), max_sim*1.001])
    text(idx, 0.5*(max_sim+min(similarities)), sprintf('cmax=%d with maximum similary', idx),...
        'fontsize', 15, 'fontname', 'times', 'color', 'r')
    title(sprintf('Similarities Class (%d)', i), 'FontSize', 14, 'fontname', 'times')
    
    show_anime = false; 
end

for i = 1:length(classes_)
    figure;  set(gcf, 'Position', [400, 800, 1200, 800])
    cs = contour_samples(i); boundary=cs{:};
    B_resizeds = B_resized_all{i}; 
    plot_samples(boundary, B_resizeds, cmax_all(i))
end


%% plot first 16 contours 
function plot_samples(boundary, B_resized_all, idx)
    % Plot several reconstructed contours, find the best one with highest similarity 
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
end

%% Functions to get cmax
function [similarities, B_resized_all] = get_cmax(boundary, show_anime)
    similarities = zeros(length(boundary)-1, 1);
    B_resized_all = {};
    if show_anime == true
        figure(2), set(gcf, 'Position', [0, 400, 400, 400])
        title('Animation display of different contours', 'FontSize', 14, 'fontname', 'times')
    end
    for i = 1:length(boundary)-1
        % Rebuild the boundary using FFT and IFFT
        B_rebuild = rebuild(boundary, i);
        B_resize = resize_boundary(B_rebuild, boundary);
        B_resized_all{end + 1} = B_resize;
        % Calculate the similarity between rebuilt and original boundary
        crr = xcorr2(boundary, B_rebuild);
        [ssr,snd] = max(crr(:));
        similarities(i) = ssr;
        
        if show_anime == true
            if mod(i,10)== 1
                figure(2), plot(boundary(:,1), boundary(:,2), 'LineWidth',3); hold on;
                figure(2), plot(B_resize(:,1), B_resize(:,2), 'LineStyle', ':', 'LineWidth',2); 
                drawnow
                pause(0.1)
            end
        end
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

