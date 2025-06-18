% OPPA task
% fMRI experiment
% Written by J.S.Kim

% Load data:
% - sbjlist.mat
% - BHV.mat
% - RT.mat

% Object recognition
bhv_metric = BHV.metric(:,1);
nanmean(bhv_metric)
nanstd(bhv_metric)
[h,p,ci,stats] = ttest(bhv_metric, 0.5)

% Object-place associate retrieval
% Accuracy
bhv_metric = BHV.metric(:,2);
nanmean(bhv_metric)
nanstd(bhv_metric)
[h,p,ci,stats] = ttest(bhv_metric, 0.25)

% RT
bhv_metric = RT.RT_mean(:,2);
nanmean(bhv_metric)
nanstd(bhv_metric)

% Memory performance index
metric(1:30,1) = RT.RT_correct_mean(:,2) ./ BHV.metric(:,2);
figure;
bin_edges = [0:2:20];
temp = metric;
h = histogram(temp, 'BinEdges', bin_edges);
ylim([0 10]);
xlim([0 20]);
er.Color = [0,0,0]; er.LineStyle= 'none';
ax = gca;
ax.XAxis.FontSize=13;
ax.XAxis.FontWeight='bold';
ax = gca;
set(gca,'FontName','Arial','FontSize',14,'fontweight','bold','linewidth',2, 'box','off');
ax.XAxis.FontSize=15; ax.XAxis.FontWeight='bold';
h.FaceColor = [0.9 0.8 1];
h.LineWidth = 1.5;
set(gcf,'position',[100,100,500,250]);
hold on; x_mean = xline(nanmean(temp), ':'); x_mean.LineWidth = 3.5;

% Spatial navigation
bhv_metric = BHV.metric(:,3);
nanmean(bhv_metric)
nanstd(bhv_metric)
[h,p,ci,stats] = ttest(bhv_metric, 0.25)

% Supplementary: Individual objects
for sbj_ct=1:length(sbjlist)
    clear sbj_xlsx
    sbj_xlsx = xlsread([master_dir '\TrialInfo_EXP_' sbjlist{1,sbj_ct} '.xlsx']);
    oprp_obj(:,sbj_ct) = sbj_xlsx(:,5);
end %-- end of for sbj_ct
obj_idx = sbj_xlsx(:,10:13);
obj_corner = unique(obj_idx(:,2));

for bldg_ct=1:length(obj_corner)
    bldg_idx = find(obj_idx(:,2)==obj_corner(bldg_ct));
    oprp_obj_corner{bldg_ct} = oprp_obj(bldg_idx,:);
    obj_order_idx{bldg_ct} = bldg_idx;
end  %-- end of for obj_ct

for bldg_ct=1:4

    for i = 1:10
        data{i} = oprp_obj_corner{bldg_ct}(i,:);
    end
    [avg,err] = jh_mean_err(2,data);

    figure; jh_bar_dot(avg,err,data);
    ylim([0 1]);
    er.Color = [0,0,0]; er.LineStyle= 'none'; er.LineWidth = 3;
    ax = gca;
    ax.XAxis.FontSize=15;
    ax.XAxis.FontWeight='bold';
    ylabel('Accuracy');
    ax = gca;
    set(gca,'FontName','Arial','FontSize',14,'fontweight','bold','linewidth',2, 'box','off');
    ax.XAxis.FontSize=15; ax.XAxis.FontWeight='bold';
    yline(0.5, ':', 'linewidth', 3);
    ax.Children(2).LineWidth = 1.5;
    ax.Children(3).LineWidth = 2;
    ax.Children(3).FaceColor='flat';
    ax.Children(3).CData = [0.5 0.7 0.8];
    
    set(gcf,'position',[100,100,600,200]);
end
