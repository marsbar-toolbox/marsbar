function test_get_marsy
% test get_marsy, and nearest neighbor handling bug
% Thanks to Peter Zeidman for spotting this one
pth = fileparts(mfilename('fullpath'));
% Single voxel ROI
mat = diag([2,3,4,1]);
mat(1:3,4) = [-2,-3,-4];
st = struct('XYZ', [3,4,5], 'mat', mat);
roi = maroi_pointlist(st, 'vox');
% Sample from some files
img_paths = strcat(pth, filesep, 'img', {'01', '02', '03'}, '.img');
V = spm_vol(char(img_paths));
% Load the data as a 4D matrix
img_data = spm_read_vols(V);
% Check we have the voxel we expected
assert_equal(voxpts(roi, V(1)), [3,4,5]');
% Check the data comes back as expected
my = get_marsy(roi, V, 'mean');
assert_equal(summary_data(my), squeeze(img_data(3,4,5,:)))
% At the moment we're doing trilinear resampling.  There is a NaN in the third
% image, at voxel 2, 2, 2.
assert_true(isnan(img_data(2,2,2,3)));
st = struct('XYZ', [2,1,1], 'mat', mat);
roi = maroi_pointlist(st, 'vox');
assert_equal(voxpts(roi, V(1)), [2,1,1]');
% With trilinear resampling we will pick up the NaN
my = get_marsy(roi, V, 'mean');
disp('(Expected warning about No valid data for roi 1)');
assert_true(isempty(my));
% Not so for nearest neighbor resampling
nn_roi = spm_hold(roi, 0);
my = get_marsy(nn_roi, V, 'mean');
assert_equal(summary_data(my), squeeze(img_data(2,1,1,:)))
% Check sampling from two voxels and two images
st = struct('XYZ', [2,2,1; 2,2,2]', 'mat', mat, 'spm_hold', 0);
nn_roi = maroi_pointlist(st, 'vox');
assert_equal(spm_hold(nn_roi), 0)
my = get_marsy(nn_roi, V(1:2), 'mean');
% Giving predictable result for one image
assert_equal(summary_data(my), mean(squeeze(img_data(2,2,1:2,1:2)), 1)');
my = get_marsy(nn_roi, V(1), 'mean');
assert_equal(summary_data(my), mean(squeeze(img_data(2,2,1:2,1))))
% Check that NaN in single image does not squelch all data
my = get_marsy(nn_roi, V(3), 'mean');
assert_equal(summary_data(my), squeeze(img_data(2,2,1,3)))
