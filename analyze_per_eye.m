function []=analyze_per_eye(img_name,DATA_FOLDER,dxy,dz)
        addpath fstack
    %% Load original image
    I_ori = imread(fullfile(DATA_FOLDER,'raw', [img_name '.tif']));
    isredo = 'y';
    if exist(['data/' img_name '_stitch.mat'],'file')
        isredo = input('Analysis file exists. Redo analysis (y/n)? ','s');
    end
    warning('off','curvefit:fit:equationBadlyConditioned');
    if strcmp(isredo,'y')
        %% Load compound eye's background image:
        I_bg =imread(fullfile(DATA_FOLDER,'probability_map', [img_name '_inout.tif']));
        I_bg = I_bg<graythresh(I_bg);
        I_bg = ~imfill(~I_bg,8,'holes');
        CC = bwconncomp(~I_bg);
        size_patch = [];
        for i=1:CC.NumObjects
            size_patch(i) = numel(CC.PixelIdxList{i});
        end
        [~,biggest] = max(size_patch);
        I_bg = I_bg*0;
        I_bg(CC.PixelIdxList{biggest})=1;
        I_bg = ~I_bg;
            %% Load label image and data:
        I_mask = imread(fullfile(DATA_FOLDER,'output_label', [img_name '.tif']));
        datamat = dlmread(fullfile(DATA_FOLDER,'output_csv', [img_name '.csv']),'\t',1,0);
        xy_pos = datamat(:,[2 3]);
        xy_idx = datamat(:,[4 5]);
        %% Load all single-focused images in raw_stack folder:
        listing_tmp = dir(fullfile(DATA_FOLDER,'raw_stack',[img_name '_*.tif']));
        NumberOfImages = numel(listing_tmp);
        I = cell(1,NumberOfImages);
        for i=1:NumberOfImages
            Itmp = imread(fullfile(DATA_FOLDER,'raw_stack',listing_tmp(i).name));
            % Check if color image
            if size(Itmp,3)>1
                I{i} = Itmp;
            else
                I{i} = cat(3,Itmp,Itmp,Itmp);
            end
        end
        %% Find focus:
        [Istitch, fmap] = fstack(I);
        fmap(I_bg) = NaN;
        %% Fit the map:
        disp('Fitting the eye surface...');
        [xtmp,ytmp]= meshgrid(1:size(fmap,2),1:size(fmap,1));
        sf = fit([ytmp(~isnan(fmap)), xtmp(~isnan(fmap))], fmap(~isnan(fmap)), 'poly33');
        fout = sf([ytmp(~isnan(fmap)), xtmp(~isnan(fmap))]);
        z_pos = sf([xy_pos(:,1), xy_pos(:,2)]);
        fmap_fit = fmap*0;
        fmap_fit(~isnan(fmap))=fout;
        disp('Done fitting');
        %% map label:
        figure;
        imagesc(I_mask);
        hold on;
        scatter(xy_pos(:,2),xy_pos(:,1),'r');
        %% Calculating ommatidia area:
        xy_neighbor = [1 0  -1  -1  0  1;...
                    0  1  1  0 -1 -1]';
    
        dst_mean = [];
    
        for i=1:size(xy_pos,1)
            % find the next one:
            dst = zeros(1,6)*NaN;
            for j=1:6
                xy_new = xy_idx(i,:) + xy_neighbor(j,:);
                idx_new = find((xy_idx(:,1)==xy_new(1)) & (xy_idx(:,2)==xy_new(2)));
                if idx_new
                    dst(j) = sqrt(sum(xy_pos(idx_new,:) - xy_pos(i,:)).^2*dxy^2 + (z_pos(idx_new)-z_pos(i)).^2*dz^2);
                else
                    dst(j) = NaN;
                end
            end
            dst_mean(i) = mean(dst,'omitnan');
        end
        dst_mean = dst_mean(:);
        %% Plot the distance:
        sf_dst = fit(xy_pos(~isnan(dst_mean),:), dst_mean(~isnan(dst_mean)), 'poly55');
        fout_dst = sf_dst([ytmp(~isnan(fmap)), xtmp(~isnan(fmap))]);
        fmap_dst_fit = fmap*0;
        fmap_dst_fit(~isnan(fmap))=fout_dst;
        %% Save the analysis data:
        mkdir('data');
        save(['data/' img_name '_stitch.mat'],'fmap_dst_fit','Istitch','I_bg','dst_mean','sf_dst','fmap','sf','fmap_fit','dxy','dz');
        %% Extract the row profile
        row_profile;
        %% Close all
        close all;
    end
    warning('on','curvefit:fit:equationBadlyConditioned');
    
    plot_per_eye;
end