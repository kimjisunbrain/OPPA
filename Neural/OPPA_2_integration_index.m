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
% - final_degree_pattern.mat

roi_name = {'L_PrC', 'R_PrC', 'L_PhC', 'R_PhC', 'L_EC', 'R_EC', 'L_CA1', 'R_CA1', 'L_CA3DG', 'R_CA3DG'};
phase_name = {'Object', 'Object-place', 'Nav'};


% Calculate pattern similarity between each pair
for roi_ct=1:length(roi_name)
    for sbj_ct=1:length(sbjlist)

        if ismember(sbj_ct, sbj_exclude)
            continue
        else

            for phase_ct=1:3
                for i=1:size(final_degree_pattern{roi_ct,sbj_ct}{phase_ct},2)
                    for ii=1:size(final_degree_pattern{roi_ct,sbj_ct}{phase_ct},2)
                        if i==ii
                            continue
                        else
                            trial_corr{roi_ct,sbj_ct}{phase_ct}(i,ii)= corr(final_degree_pattern{roi_ct,sbj_ct}{phase_ct}(:,i), final_degree_pattern{roi_ct,sbj_ct}{phase_ct}(:,ii), 'rows','complete');
                        end
                    end
                end
            end
        end
    end 
    fprintf([roi_name{roi_ct} '(' num2str(roi_ct) ') done \n']);
end

% Integration index: House
for roi_ct=1:length(roi_name)
    for sbj_ct=1:length(sbjlist)
        if ismember(sbj_ct,sbj_exclude)
            for phase_ct=1:3
                same{roi_ct,phase_ct}(sbj_ct,1)=NaN;
                diff{roi_ct,phase_ct}(sbj_ct,1)=NaN;
                same_diff{roi_ct,phase_ct}(sbj_ct,1)=NaN;
            end

        else
            for phase_ct=1:3
                same_log = false(size(run_idx{sbj_ct,phase_ct},1),size(run_idx{sbj_ct,phase_ct},1));
                diff_log = false(size(run_idx{sbj_ct,phase_ct},1),size(run_idx{sbj_ct,phase_ct},1));
                for x=1:size(run_idx{sbj_ct,phase_ct},1)
                    for y=1:size(run_idx{sbj_ct,phase_ct},1)
                        if x==y
                            continue
                        else
                            if correctness_idx{sbj_ct,phase_ct}(x)==1 && correctness_idx{sbj_ct,phase_ct}(y)==1
                                if run_idx{sbj_ct,phase_ct}(x) == run_idx{sbj_ct,phase_ct}(y)
                                    continue
                                else
                                    if house_corner{sbj_ct,phase_ct}(x,1) == house_corner{sbj_ct,phase_ct}(y,1)
                                        same_log(x,y)=true;
                                    else
                                        diff_log(x,y)=true;
                                    end
                                end
                            else
                                continue
                            end
                        end
                    end
                end

                clear trial_corr_phase
                trial_corr_phase = trial_corr{roi_ct,sbj_ct}{phase_ct};

                same_log_upper = triu(same_log);
                diff_log_upper = triu(diff_log);
                same{roi_ct,phase_ct}(sbj_ct,1) = nanmean(trial_corr_phase(same_log_upper));
                diff{roi_ct,phase_ct}(sbj_ct,1) = nanmean(trial_corr_phase(diff_log_upper));
                same_diff{roi_ct,phase_ct}(sbj_ct,1) = nanmean(trial_corr_phase(same_log_upper)) - nanmean(trial_corr_phase(diff_log_upper));
            end
        end
    end
    fprintf(['Done for ' roi_name{roi_ct} '(' num2str(roi_ct) ')\n']);
end
RetPS_house.same = same;
RetPS_house.diff = diff;
RetPS_house.same_diff = same_diff;

% Integration index: Corner
for roi_ct=1:length(roi_name)
    for sbj_ct=1:length(sbjlist)
        if ismember(sbj_ct,sbj_exclude)
            for phase_ct=1:2
                same{roi_ct,phase_ct}(sbj_ct,1)=NaN;
                diff{roi_ct,phase_ct}(sbj_ct,1)=NaN;
                same_diff{roi_ct,phase_ct}(sbj_ct,1)=NaN;
            end
        else
            for phase_ct=1:2
                same_log = false(size(run_idx{sbj_ct,phase_ct},1),size(run_idx{sbj_ct,phase_ct},1));
                diff_log = false(size(run_idx{sbj_ct,phase_ct},1),size(run_idx{sbj_ct,phase_ct},1));
                for x=1:size(run_idx{sbj_ct,phase_ct},1)
                    for y=1:size(run_idx{sbj_ct,phase_ct},1)
                        if x==y
                            continue
                        else
                            if correctness_idx{sbj_ct,phase_ct}(x)==1 && correctness_idx{sbj_ct,phase_ct}(y)==1
                                if run_idx{sbj_ct,phase_ct}(x) == run_idx{sbj_ct,phase_ct}(y)
                                    continue
                                else
                                    if house_corner{sbj_ct,phase_ct}(x,1) == house_corner{sbj_ct,phase_ct}(y,1)
                                        if house_corner{sbj_ct,phase_ct}(x,2) == house_corner{sbj_ct,phase_ct}(y,2)
                                            same_log(x,y)=true;
                                        else
                                            diff_log(x,y)=true;
                                        end
                                    end
                                end
                            else
                                continue
                            end
                        end
                    end
                end

                clear trial_corr_phase
                trial_corr_phase = trial_corr{roi_ct,sbj_ct}{phase_ct};

                same_log_upper = triu(same_log);
                diff_log_upper = triu(diff_log);
                same{roi_ct,phase_ct}(sbj_ct,1) = nanmean(trial_corr_phase(same_log_upper));
                diff{roi_ct,phase_ct}(sbj_ct,1) = nanmean(trial_corr_phase(diff_log_upper));
                same_diff{roi_ct,phase_ct}(sbj_ct,1) = nanmean(trial_corr_phase(same_log_upper)) - nanmean(trial_corr_phase(diff_log_upper));
            end
        end
    end

    fprintf(['Done for ' roi_name{roi_ct} '(' num2str(roi_ct) ')\n']);
end
RetPS_corner.same = same;
RetPS_corner.diff = diff;
RetPS_corner.same_diff = same_diff;

% (Supplementary) Integration index: Landmark (View)
viewpoint{1} = [3 7; 6 4; 9 1; 12 10];
viewpoint{2} = [3 10; 6 7; 9 4; 12 1];
viewpoint{3} = [3 4; 6 1; 9 10; 12 7];
viewpoint{4} = [3 1; 6 10; 9 7; 12 4];

for roi_ct=1:length(roi_name)
    for sbj_ct=1:length(sbjlist)

        if ismember(sbj_ct,sbj_exclude)
            for phase_ct=1:2
                same{roi_ct,phase_ct}(sbj_ct,1)=NaN;
                diff{roi_ct,phase_ct}(sbj_ct,1)=NaN;
                same_diff{roi_ct,phase_ct}(sbj_ct,1)=NaN;
            end
        else
            for phase_ct=1:2

                % make true matrix
                same_log = false(size(run_idx{sbj_ct,phase_ct},1),size(run_idx{sbj_ct,phase_ct},1));
                diff_log = false(size(run_idx{sbj_ct,phase_ct},1),size(run_idx{sbj_ct,phase_ct},1));

                for x=1:size(run_idx{sbj_ct,phase_ct},1)
                    for y=1:size(run_idx{sbj_ct,phase_ct},1)
                        if x==y
                            continue
                        else
                            if correctness_idx{sbj_ct,phase_ct}(x)==1 && correctness_idx{sbj_ct,phase_ct}(y)==1
                                if run_idx{sbj_ct,phase_ct}(x) == run_idx{sbj_ct,phase_ct}(y)
                                    continue
                                else
                                    if house_corner{sbj_ct,phase_ct}(x,1) == house_corner{sbj_ct,phase_ct}(y,1)
                                        if house_corner{sbj_ct,phase_ct}(x,2) == house_corner{sbj_ct,phase_ct}(y,2)
                                            same_log(x,y)=true;
                                        end
                                    else  %-- diff house
                                        same_view_num = 0;
                                        degree_x =  house_corner{sbj_ct,phase_ct}(x,:); degree_x(1) = degree_x(1)*3;
                                        degree_y = house_corner{sbj_ct,phase_ct}(y,:); degree_y(1) = degree_y(1)*3;

                                        for view_ct=1:4
                                            is_present = @(cond) any(ismember(viewpoint{view_ct}, cond, 'rows'));
                                            is_present_x = is_present(degree_x);
                                            is_present_y = is_present(degree_y);
                                            if is_present_x && is_present_y
                                                same_view_num = same_view_num+1;
                                            end
                                        end

                                        if same_view_num ==1
                                            continue
                                        else
                                            if degree_x(1) == degree_y(1)
                                                continue
                                            else
                                                diff_log(x,y)=true;
                                            end
                                        end
                                    end
                                end
                            else
                                continue
                            end
                        end
                    end
                end

                clear trial_corr_phase
                trial_corr_phase = trial_corr{roi_ct,sbj_ct}{phase_ct};

                same_log_upper = triu(same_log);
                diff_log_upper = triu(diff_log);
                same{roi_ct,phase_ct}(sbj_ct,1) = nanmean(trial_corr_phase(same_log_upper));
                diff{roi_ct,phase_ct}(sbj_ct,1) = nanmean(trial_corr_phase(diff_log_upper));
            end
        end
    end
    fprintf(['Done for ' roi_name{roi_ct} '(' num2str(roi_ct) ')\n']);
end
RetPS_corner_view.same = same;
RetPS_corner_view.diff = diff;
RetPS_corner_view.same_diff = same_diff;

% Plot results & run statistics
temp_house = RetPS_house.same_diff; temp_corner = RetPS_corner.same_diff;
% temp_corner = RetPS_corner_view.same_diff;
phase_ct=1; phase_ct=2;

figure;
for roi_ct=1:length(roi_name)
    clear temp
    temp{1} = temp_house{roi_ct,phase_ct};
    temp{2} = temp_corner{roi_ct,phase_ct};
    subplot(1,5,roi_ct);

    mean = cellfun(@nanmean,temp);
    err = cellfun(@(x) nanstd(x)/sqrt(length(x)), temp);
    err = err.*1.96;
    b = errorbar(mean,err);

    b(1).FaceColor = 'flat';
    if phase_ct==1
        b.CData(1,:) = [0.9 0.5 0.5];
        b.CData(2,:) = [1 0.9 0.9];
    elseif phase_ct==2
        b.CData(1,:) = [0.6 0.4 0.7];
        b.CData(2,:) = [0.9 0.8 1];
    end
    b.LineWidth = 3;
    yline(0, 'Linewidth', 3);
    set(gca,'FontName','Arial','FontSize',15,'fontweight','bold','linewidth',3, 'box','off');
    set(gca, 'xtick', 1:2, 'xticklabel', {' ',' '}, 'FontSize',17);

    % Statistics
    [h,p,ci,stats] = ttest(temp{1});
    fprintf([roi_name{roi_ct} ' H : t = ' num2str(stats.tstat) ', p = ' num2str(p) '\n']);
    [h,p,ci,stats] = ttest(temp{2});
    fprintf([roi_name{roi_ct} ' C : t = ' num2str(stats.tstat) ', p = ' num2str(p) '\n']);
    [h,p,ci,stats] = ttest(temp{1}, temp{2});
    fprintf([roi_name{roi_ct} ' H vs. C : t = ' num2str(stats.tstat) ', p = ' num2str(p) '\n']);
end  %-- end of for roi_ct
set(gcf,'Position', [100 100 1600 350]);


