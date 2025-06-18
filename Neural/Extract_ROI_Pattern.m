function ROI_data = Extract_ROI_Pattern(ROI, Beta_img)

Y = spm_read_vols(spm_vol(ROI),1);
indx = find(Y>0);
[x,y,z] = ind2sub(size(Y),indx);
XYZ = [x y z]';
ROI_data = spm_get_data(Beta_img, XYZ);

end


