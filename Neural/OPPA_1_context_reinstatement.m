% OPPA task
% fMRI experiment
% Written by J.S.Kim

% Load data:
% - sbjlist.mat
% - sbj_exclude.mat
% - house_corner.mat
% - correctness_idx_correct.mat
% - run_idx.mat
% - trial_idx.mat

roi_name = {'L_PrC', 'R_PrC', 'L_PhC', 'R_PhC', 'L_EC', 'R_EC', 'L_CA1', 'R_CA1', 'L_CA3DG', 'R_CA3DG'};
phase_name = {'Object', 'Object-place', 'Nav'};

% Extract activation pattern
for sbj_ct=1:length(sbjlist)
    if ismember(sbj_ct,sbj_exclude)
        continue
    else
        sbj_dir = [singletrial_dir '\' sbjlist{1,sbj_ct} '\betas\Sess001'];
        for roi_ct=1:length(roi_name)
            final_degree_pattern {roi_ct, sbj_ct}=[];
            roi_file = [roi_dir '\SUB' num2str(sbj_ct) '\mri\r' roi_name{roi_ct} '.nii'];

            % Object, Object-place
            cond_match = dir([sbj_dir '\E_OCP_*']);
            oprp_match = dir([sbj_dir '\E_OPRP_*']);
            for trial_ct=1:length(cond_match)
                final_degree_pattern{roi_ct,sbj_ct}{1}(:,trial_ct) = Extract_ROI_Pattern(roi_file, [sbj_dir '\' cond_match(trial_ct).name '\beta_0001.nii']);
                final_degree_pattern{roi_ct,sbj_ct}{2}(:,trial_ct) = Extract_ROI_Pattern(roi_file, [sbj_dir '\' oprp_match(trial_ct).name '\beta_0001.nii']);
            end  %-- end of for trial_ct

            % Nav
            final_degree_pattern{roi_ct,sbj_ct}{3} = [];
            smp_match = dir([sbj_dir '\E_SMP_Corr_*']);
            for trial_ct=1:length(smp_match)
                final_degree_pattern{roi_ct,sbj_ct}{3}(:,trial_ct) = Extract_ROI_Pattern(roi_file, [sbj_dir '\' smp_match(trial_ct).name '\beta_0001.nii']);
            end
        end  %-- end of for roi_ct
    end
end

% Calculate pattern similarity between each pair
for roi_ct=1:length(roi_name)
    for sbj_ct=1:length(sbjlist)
        if ismember(sbj_ct, sbj_exclude)
            continue
        else
            for phase_ct=1:2
                for ret_ct=1:size(final_degree_pattern{roi_ct,sbj_ct}{phase_ct},2)
                    for smp_ct=1:size(final_degree_pattern{roi_ct,sbj_ct}{3},2)
                        ret_trial_corr{roi_ct,sbj_ct}{phase_ct}(ret_ct,smp_ct) = ...
                            corr(final_degree_pattern{roi_ct,sbj_ct}{phase_ct}(:,ret_ct), final_degree_pattern{roi_ct,sbj_ct}{3}(:,smp_ct), 'rows','complete');
                    end  %-- end of for smp_ct
                end  %-- end of for ret_ct
            end  %-- end of for phase_ct
        end
    end  %-- end of for sbj_ct
    fprintf(['Done for: ' roi_name{roi_ct} '(' num2str(roi_ct) ')\n']);
end  %-- end of for roi_ct

% Context Reinstatement calculation
for roi_ct=1:length(roi_name)
    for sbj_ct=1:length(sbjlist)
        if ismember(sbj_ct, sbj_exclude) || sbj_ct==7 || sbj_ct==14
            for phase_ct=1:2
            same{roi_ct,phase_ct}(sbj_ct,1) = NaN;
            diff{roi_ct,phase_ct}(sbj_ct,1) = NaN;
            same_diff{roi_ct,phase_ct}(sbj_ct,1) = NaN;
            end
        else
            for phase_ct=1:2

                % make true matrix
                same_log = false(size(ret_trial_corr{roi_ct,sbj_ct}{phase_ct},1),size(ret_trial_corr{roi_ct,sbj_ct}{phase_ct},2));
                diff_log = false(size(ret_trial_corr{roi_ct,sbj_ct}{phase_ct},1),size(ret_trial_corr{roi_ct,sbj_ct}{phase_ct},2));
                for x=1:size(ret_trial_corr{roi_ct,sbj_ct}{phase_ct},1)
                    for y=1:size(ret_trial_corr{roi_ct,sbj_ct}{phase_ct},2)
                        if correctness_idx{sbj_ct,phase_ct}(x)==1
                            if (run_idx{sbj_ct,phase_ct}(x) == run_idx{sbj_ct,3}(y)) ...
                                    && (trial_idx{sbj_ct,phase_ct}(x) == trial_idx{sbj_ct,3}(y))
                                continue
                            else
                                if house_corner{sbj_ct,phase_ct}(x,1) == house_corner{sbj_ct,3}(y,1)
                                    same_log(x,y)=true;
                                else
                                    diff_log(x,y)=true;
                                end
                            end
                        else
                            continue
                        end
                    end  %-- end of for y
                end  %-- end of for x

                sbj_roi_pattern = ret_trial_corr{roi_ct,sbj_ct}{phase_ct};
                same{roi_ct,phase_ct}(sbj_ct,1) = nanmean(sbj_roi_pattern(same_log));
                diff{roi_ct,phase_ct}(sbj_ct,1) = nanmean(sbj_roi_pattern(diff_log));
                same_diff{roi_ct,phase_ct}(sbj_ct,1) = same{roi_ct,phase_ct}(sbj_ct,1) - diff{roi_ct,phase_ct}(sbj_ct,1);

            end  %-- end of for phase_ct
        end
    end  %-- end of for sbj_ct
    fprintf(['Done for: ' roi_name{roi_ct} '(' num2str(roi_ct) ')\n']);
end  %-- end of for roi_ct

% Statistical testing
clear temp
phase_ct=1; % phase_ct=2;
for roi_ct=1:length(roi_idx)
    temp{roi_ct} = same_diff{roi_ct,phase_ct};
    [h,p,ci,stats] = ttest(temp{roi_ct});
    fprintf([roi_name{roi_ct} ': t = ' num2str(stats.tstat) ', p = ' num2str(p) '\n']);
end

% Plot results
figure;
mean = cellfun(@nanmean,temp);
err = cellfun(@(x) nanstd(x)/sqrt(length(x)), temp);
err = err.*1.96;
b = errorbar(mean,err);
b(1).FaceColor = 'flat';
b(1).FaceColor = [0.9 0.5 0.5]; % phase_ct=1;
b(1).FaceColor = [0.8 0.6 0.9]; % phase_ct=2;
b(1).BarWidth = 0.6;
b.LineStyle = 'none';
b.CapSize = 10;
b.LineWidth = 2;
yline(0, 'Linewidth', 2);

set(gca,'FontName','Arial','FontSize',10,'fontweight','bold','linewidth',2, 'box','off');
set(gca, 'xtick', 1:5, 'xticklabel', {' ',' '}, 'FontSize', 15);
set(gcf,'Position', [100 100 900 250]);



