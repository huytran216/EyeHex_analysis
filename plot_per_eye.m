    % Creating plots
    figure;
    Dat_stitch = load(['data/' img_name '_stitch.mat']);
    Dat_row = load(['data/' img_name '.mat']);
    xy_pos = Dat_row.xy_pos;
    xy_idx_new = Dat_row.xy_idx_new;
    row_num = Dat_row.row_num;
    row_count = Dat_row.row_count;
    t = tiledlayout(2,2,'TileSpacing','Compact','Padding','Compact');
    % Draw stiched image
        ax1=nexttile;
        imshow(Dat_stitch.Istitch);
        title('Original image');
    % Draw altitude:
        ax2=nexttile;
        fmap_alt_fit_show = Dat_stitch.fmap_fit(end:-1:1,:)*dz;
        fmap_alt_fit_show(Dat_stitch.I_bg(end:-1:1,:)) = 0;
        contour(fmap_alt_fit_show,10,'ShowText','off','LineWidth',1.5);
        hColorbar = colorbar(gca,'westoutside');
        ylabel(hColorbar,'Ommatidia altitude (micron)','Rotation',90);
        set(gca,'XTick',[],'YTick',[]);
        axis equal
        axis on
        title('Ommatidia altitude profile');
    % Draw spacing
        ax3=nexttile;       
        fmap_dst_fit_show = Dat_stitch.fmap_dst_fit(end:-1:1,:);
        fmap_dst_fit_show(Dat_stitch.I_bg(end:-1:1,:)) = 7;
        contour(fmap_dst_fit_show,10,'ShowText','off','LineWidth',1.5);
        set(gca,'XTick',[],'YTick',[]);
        hColorbar = colorbar(gca,'westoutside');
        ylabel(hColorbar,'Ommatidia spacing (micron)','Rotation',90);
        axis equal
        axis on
        title('Ommatidia spacing profile');
    % Draw row profile
        ax4=nexttile;
        row_idx = mean(xy_idx_new,2,'omitnan');
        scatter(xy_pos(mod(row_idx,3)==1,2),size(Dat_stitch.I_bg,1) - xy_pos(mod(row_idx,3)==1,1),3,'Marker','o','MarkerFaceColor','r'); hold on;
        scatter(xy_pos(mod(row_idx,3)==2,2),size(Dat_stitch.I_bg,1) - xy_pos(mod(row_idx,3)==2,1),3,'Marker','o','MarkerFaceColor','b'); hold on;
        scatter(xy_pos(mod(row_idx,3)==0,2),size(Dat_stitch.I_bg,1) - xy_pos(mod(row_idx,3)==0,1),3,'Marker','o','MarkerFaceColor','g');
        scatter(xy_pos(row_idx==min(row_idx),2),size(Dat_stitch.I_bg,1) - xy_pos(row_idx==min(row_idx),1),10,'Marker','o','MarkerFaceColor','k'); hold on;
        set(gca,'XTick',[],'YTick',[]);
        box on
        axis equal
        xlim([0 size(Dat_stitch.I_bg,2)]);
        ylim([0 size(Dat_stitch.I_bg,1)]);
        title({'Ommatidia sorted by column','(bold = posterior-dorsal corner)'});
        set(gcf, 'Position',[262   339   924   639]);
        linkaxes([ax1 ax2 ax3 ax4],'xy');
    % Draw row profile
        figure;
        plot(row_num - mean(row_num),row_count); hold on;
        xlabel('Column index');
        ylabel('Ommatidia count');
        xlim([-20 20]);
        ylim([0 40]);
        box on
        title({'Column profile'});