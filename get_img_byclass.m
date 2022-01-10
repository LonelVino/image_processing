function Bi_images = get_img_byclass(root, class, img_show)
%% Categorized according to image's label
    Bi_images = {}; img_paths= {};
    % read txt file(labels) in a folder
    filePattern = sprintf('%s/*.txt', root);
    baseFileNames = dir(filePattern);
    numberOfFiles = length(baseFileNames);
    for K = 1 : numberOfFiles
        label_path = sprintf('%s/%s', root, baseFileNames(K).name);
        img_path = sprintf('%spng', label_path(1:length(label_path)-3));
        label = load(label_path); %load just this file
    %   fprintf( 'File #%d, "%s", value: %g\n', K, thisfilename, thisdata);   %displaydata
        if label == class
            ori_img = imread(img_path);
            BW = imbinarize(ori_img);
            [B,L,N,A] = bwboundaries(BW);
            Bi_images{end+1}=BW; img_paths{end+1}=img_path;
        end
    end
    if img_show == true
        figure, set(gca, 'Position', [0,0,800,800])
        for i = 1:9
            subplot(3,3,i)
            imshow(cell2mat(Bi_images(i)));
            title(string(img_paths(i)), 'fontsize', 12, 'fontname', 'times')
        end
    end