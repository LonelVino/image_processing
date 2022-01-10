clear; clc; close all

classes = [1:3; 4:6]'; num_class = 3;
for classes_ = classes
    figure, set(gcf, 'Position', [200,200,1200,2400])
    for class = 1:length(classes_)
        Bi_images = get_img_byclass('./appr', classes_(class), false); % get images in the same class true: show images
        [keys, all_params] = get_params(Bi_images);  % get parmaeters and keys of images, keys and correpsongding parameters values
        [ind_params_key, ind_params_val] = find_ind_params(keys, all_params); % find independent parameters

        %% Count the independent parameters
        uni_ind_params_key = unique(ind_params_key); 
        uni_ind_params_val = {};
        appr_count = [];
        for i = uni_ind_params_key
            appr_count(end+1) = sum(ind_params_key==i);
            ind_param_val = ind_params_val(ind_params_key==i);
            uni_ind_params_val{end+1} = ind_param_val;
        end


        subplot(num_class,3,class*3-2); 
        imshow(cell2mat(Bi_images(1)))
        xlabel(sprintf('Origin Image(Class %d)',  classes_(class)), 'fontname', 'times', 'fontsize', 18)

        subplot(num_class,3,class*3-1); title('Count independent parameters', 'fontname', 'times', 'fontsize', 20)
        params_name = categorical(uni_ind_params_key);
        b = bar(params_name, appr_count);
        xtips1 = b(1).XEndPoints;
        ytips1 = b(1).YEndPoints;
        labels1 = string(b(1).YData);
        ax = gca; ax.XAxis.FontSize = 14; ax.YAxis.FontSize = 14;  ax.XAxis.FontName= 'times'; ax.YAxis.FontName= 'times';  ax.XColor=[0, 0.6, 0];
    %     xlabel('Independent Parameters', 'fontsize', 16, 'FontName','Times', 'Color', [0, 0, 0]); ylabel('Appeerance Times' ,'fontsize', 16, 'fontname', 'times')
        text(xtips1,ytips1,labels1,'HorizontalAlignment','center','VerticalAlignment','bottom',...
            'FontName','Times', 'FontWeight','bold', 'FontSize', 16)

        subplot(num_class,3,class*3); title('Visualize independent parameters value', 'fontname', 'times', 'fontsize', 20)
        for i = 1:length(uni_ind_params_key)
            data_ = uni_ind_params_val(i);
            data = cell2mat(data_{:});
            scatter(ones(length(data),1)*i, data, 105, 'filled');
            hold on; grid on;
        end
        xticks([1:5]); xticklabels(uni_ind_params_key); xtickangle(30)
        ax = gca; ax.XAxis.FontSize = 14; ax.YAxis.FontSize = 14;  ax.XAxis.FontName= 'times'; ax.YAxis.FontName= 'times';  ax.XColor=[0, 0.6, 0];
    %     xlabel('Independent Parameters', 'fontsize', 16, 'FontName','Times', 'Color', [0, 0, 0]); ylabel('Value' ,'fontsize', 16, 'fontname', 'times')

    end
end


function [keys, all_params] = get_params(Bi_images)
%% Storeage Properties
    all_params = {};
    for idx = 1:length(Bi_images)
        image = Bi_images(idx);
        params = regionprops(cell2mat(image), 'all');
        all_params{end+1} = struct2cell(params);
    end
    fieldname = fieldnames(params);
    keys = [];
    for i = 1:length(fieldname)
        key  = string(fieldname(i));
        keys = [keys key];
    end
end

function [ind_params, ind_params_val] = find_ind_params(keys, all_params)
%% Compare all Parameters
    ref_params = all_params(1);
    ref_params = cell2struct(ref_params{:}, keys);% set a reference image as benchmark
    ind_params = []; ind_params_val = {}; flag=true; eps = 1e-2;  % the tolerable error
    for idx = 2:length(all_params)
        test_params = all_params(idx);
        test_params = cell2struct(test_params{:}, keys);
        for key = keys
            ref_value = ref_params.(key); test_value = test_params.(key);
            if isa(test_value,'double') == true && (length(test_value) == 1)
                if abs(test_value - ref_value) >= eps
                    flag = false;
                end
            elseif ~isequal(ref_value, test_value) 
                flag = false;
            end
            if flag == true
                ind_params= [ind_params key];
                ind_params_val{end+1} = test_value;
            end
            flag=true;
        end
    end
end