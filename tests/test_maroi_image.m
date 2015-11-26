function test_maroi_image;
% Test creation of maroi_image objects
pth = fileparts(mfilename('fullpath'));
img_fname = fullfile(pth, 'img01.img');
vol = spm_vol(img_fname);
data = spm_read_vols(vol);
msk = data ~= 0;
vol_mean = mean(data(msk));
roi1 = maroi_image(img_fname);
assert_equal(vol_mean, mean(getdata(roi1, img_fname)))
roi2 = maroi_image(vol);
assert_equal(vol_mean, mean(getdata(roi2, img_fname)))
