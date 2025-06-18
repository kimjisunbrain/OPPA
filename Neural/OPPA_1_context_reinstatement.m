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

% Calculate pattern similarity between each pair
for roi_ct=1:length(roi_name)
    for sbj_ct=1:length(sbjlist)

        if ismember(sbj_ct,sbj_exclude)
            continue
        else
            for phase_ct=1:length(phase_name)
                for i=1:size(final_degree_pattern{roi_ct,sbj_ct}{phase_ct},2)
                    for ii=1:size(final_degree_pattern{roi_ct,sbj_ct}{phase_ct},2)
                        if i==ii
                            continue
                        else
                            trial_corr{roi_ct,sbj_ct}{phase_ct}(i,ii)= corr(final_degree_pattern{roi_ct,sbj_ct}{phase_ct}(:,i), final_degree_pattern{roi_ct,sbj_ct}{phase_ct}(:,ii), 'rows','complete');
                        end
                    end  %-- end of ii
                end  %-- end of for i

            end  %-- end of for phase_ct
        end
    end  %-- end of for sbj_ct
    fprintf([roi_name{roi_ct} '(' num2str(roi_ct) ') done \n']);
end  %-- end of for roi_ct

% Context Reinstatement calculation
