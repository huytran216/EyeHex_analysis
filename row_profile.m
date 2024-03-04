%% Run the file:
xy_neighbor = [1 0  -1  -1  0  1;...
            0  1  1  0 -1 -1]';
%% Setup direction posterior anterior:
figure;
imshow(I_ori);
% draw x-y axis:
pttmp_x = [];
pttmp_y = [];
for i=0:20
    idx_new = find((xy_idx(:,1)==i) & (xy_idx(:,2)==0));
    if idx_new
        pttmp_x = [pttmp_x idx_new];
    end
    idx_new = find((xy_idx(:,1)==0) & (xy_idx(:,2)==i));
    if idx_new
        pttmp_y = [pttmp_y idx_new];
    end
end
%hold on;
%plot(xy_pos(pttmp_x,2),xy_pos(pttmp_x,1),'color','b','LineStyle','-','LineWidth',3);
%plot(xy_pos(pttmp_y,2),xy_pos(pttmp_y,1),'color','b','LineStyle','--','LineWidth',3);
title('Click on two points to define the posterior - anterior direction:');
[yi,xi] = getpts(gca);
% take only last two points:
xi = xi(end-1:end);
yi = yi(end-1:end);
close(gcf);
%% Get the closest points that have at least 3 neighbor:
closest_dst = 1e10;
closest_idx = 0;
for i=1:size(xy_pos,1)
    % find the next one:
    dst = sqrt(sum((xy_pos(i,:) - [xi(1) yi(1)]).^2));
    if dst <closest_dst
        cnt_nbg = 0;
        for j=1:6
            xy_new = xy_idx(i,:) + xy_neighbor(j,:);
            idx_new = find((xy_idx(:,1)==xy_new(1)) & (xy_idx(:,2)==xy_new(2)));
            if idx_new
                cnt_nbg = cnt_nbg + 1;
            end
        end
        if cnt_nbg>=6
            closest_dst = dst;
            closest_idx = i;
        end
    end
end
%% Find the closest orientation:
nbg_list= [];
for j=1:6
    xy_new = xy_idx(closest_idx,:) + xy_neighbor(j,:);
    idx_new = find((xy_idx(:,1)==xy_new(1)) & (xy_idx(:,2)==xy_new(2)));
    if idx_new
        nbg_list(j) = idx_new;
    end
end
% Normalized input vector:
i = closest_idx;
vector_i = [diff(xi) diff(yi)]; vector_i = vector_i/sqrt(sum(vector_i.^2));
% find vector from center to neibor
vector_j = [];
for j=1:6
    vector_j(j,:) = [xy_pos(nbg_list(j),:) - xy_pos(i,:)];
    vector_j(j,:) = vector_j(j,:)./sqrt(sum(vector_j(j,:).^2));
end
% Which mid-vector from center between two neibors
small_sim = 0;
small_j = 0;
for j=1:6
    % next neibor
    nj = mod(j+1,6);
    if nj==0
        nj = 6;
    end
    newvector = vector_j(j,:) + vector_j(nj,:);
    newvector = newvector./sqrt(sum(newvector.^2));
    angle_ = sum((newvector + vector_i).^2);
    if angle_ >small_sim
        small_sim = angle_;
        small_j = j;
    end
end
figure;
scatter(vector_j(:,2),vector_j(:,1));
hold on;
scatter(vector_j(1,2),vector_j(1,1),'MarkerFaceColor','r','Display','1st');
scatter(vector_j(2,2),vector_j(2,1),'MarkerFaceColor','k','Display','2nd');
scatter(vector_j(small_j,2),vector_j(small_j,1),'MarkerFaceColor','g','Display','Next');
plot([0 vector_i(2)],[0 vector_i(1)],'b');
legend show;
set(gca, 'YDir','reverse');
%% Angle to turn:
xy_idx_new = xy_idx - ones(size(xy_idx,1),1)*xy_idx(closest_idx,:);
figure;
scatter(xy_idx_new(:,1),xy_idx_new(:,2),'MarkerFaceColor','b','Display','Original');
for i = 1:size(xy_idx_new,1)
    % convert to xyz coordinate
    xyz = [xy_idx_new(i,2) -xy_idx_new(i,2)-xy_idx_new(i,1) xy_idx_new(i,1)];
    % rotate angle 60o anticlock wise
    for j = 1:small_j-1
        xyz = -xyz;
        xyz = xyz([3 1 2]);
    end
    xy_idx_new(i,:) = xyz([3 1]);
end
hold on;
scatter(xy_idx_new(:,1),xy_idx_new(:,2),'MarkerFaceColor','r','Display','New');
title(['angle: ' num2str(small_j)]);
axis equal
xlim([-40 40]);
ylim([-40 40]);
legend show;
%% Plot rows
figure;

row_idx = mean(xy_idx_new,2,'omitnan')*2;
imshow(I_ori); hold on;
scatter(xy_pos(mod(row_idx,3)==1,2),xy_pos(mod(row_idx,3)==1,1),'r','MarkerFaceColor','r'); hold on;
scatter(xy_pos(mod(row_idx,3)==2,2),xy_pos(mod(row_idx,3)==2,1),'b','MarkerFaceColor','b'); hold on;
scatter(xy_pos(mod(row_idx,3)==0,2),xy_pos(mod(row_idx,3)==0,1),'g','MarkerFaceColor','g');
title('Ommatidia color-sorted by columns from Posterior to Anterior of Compound eye');
axis equal
box on
xlim([0 1600])
ylim([0 1200])
set(gca,'XTick',[],'YTick',[]);

row_num = unique(row_idx);
row_count = hist(row_idx,row_num);
%% make row profile:
figure(100);
row_num = row_num - min(row_num);
plot(row_num - min(row_num),row_count,'Display',img_name); hold on;
xlabel('Row number');
ylabel('count number');
%% save data:
mkdir('data');
save(['data/' img_name '.mat'],'row_num','row_count','xy_idx_new','xy_pos','xy_idx','row_idx','img_name');