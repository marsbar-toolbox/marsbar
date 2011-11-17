% MarsBaR batch script to show off MarsBaR batching
% This script replicates most of the work in the MarsBaR tutorial.
% See http://marsbar.sourceforge.net
%
% The script assumes that the current directory is the 'batch' directory
% of the example data set files.
%
% $Id: run_tutorial.m,v 1.3 2004/08/15 01:19:43 matthewbrett Exp $

% Start marsbar to make sure spm_get works
marsbar('on')

% You might want to define the path to the example data here, as in
% subjroot = '/my/path/somewhere';
subjroot = get_subjroot();

% Directory to store (and load) ROIs
roi_dir = fullfile(subjroot, 'rois');

% MarsBaR version check
v = str2num(marsbar('ver'));
if v < 0.35
  error('Batch script only works for MarsBaR >= 0.35');
end

% SPM version check. We need this to guess which model directory to use and
% to get the SPM configured design name. 
spm_ver = spm('ver');
sdirname = [spm_ver '_ana'];
if strcmp(spm_ver, 'SPM99')
  conf_design_name = 'SPMcfg.mat';
else
  spm_defaults;
  conf_design_name = 'SPM.mat';
end

% Set up the SPM defaults, just in case
spm('defaults', 'fmri');

% Subdirectory for reconfigured design
mars_sdir = 'Mars_ana';

% Get SPM model for session 2
sess2_model_dir = fullfile(subjroot, 'sess2', sdirname);
sess2_model = mardo(fullfile(sess2_model_dir, 'SPM.mat'));
if ~is_spm_estimated(sess2_model)
  error(['Session 2 model has not been estimated. ' ...
	'You may need to run the run_preprocess script']);
end

% Get activation cluster by loading T image
con_name = 'stim_hrf';
t_con = get_contrast_by_name(sess2_model, con_name);
if isempty(t_con)
  error(['Cannot find the contrast ' con_name ...
	' in the design; has it been estimated?']);
end
% SPM2 stores contrasts as vols, SPM99 as filenames
if isstruct(t_con.Vspm)
  t_con_fname = t_con.Vspm.fname;
else
  t_con_fname = t_con.Vspm;
end
% SPM5 designs can have full paths in their Vspm.fnames
t_pth = fileparts(t_con_fname);
if isempty(t_pth)
    t_con_fname = fullfile(sess2_model_dir, t_con_fname);
end
if ~exist(t_con_fname)
  error(['Cannot find t image ' t_con_fname ...
	 '; has it been estimated?']);
end

% Get t threshold of uncorrected p < 0.05
p_thresh = 0.05;
erdf = error_df(sess2_model);
t_thresh = spm_invTcdf(1-p_thresh, erdf);

% get all voxels from t image above threshold
V = spm_vol(t_con_fname);
img = spm_read_vols(V);
tmp = find(img(:) > t_thresh);
img = img(tmp);
XYZ = mars_utils('e2xyz', tmp, V.dim(1:3));

% make into clusters, find max cluster
cluster_nos = spm_clusters(XYZ);
[mx max_index] = max(img);
max_cluster = cluster_nos(max_index);
cluster_XYZ = XYZ(:, cluster_nos == max_cluster);

% Make ROI from max cluster
act_roi = maroi_pointlist(struct('XYZ', cluster_XYZ, ...
				 'mat', V.mat), 'vox');

% Make box ROI to do trimming
box_limits = [-20 20; -66 -106; -20 7]';
box_centre = mean(box_limits);
box_widths = abs(diff(box_limits));
box_roi = maroi_box(struct('centre', box_centre, ...
			   'widths', box_widths));

% Combine for trimmed ROI
trim_stim = box_roi & act_roi;

% Give it a name
trim_stim = label(trim_stim, 'batch_trim_stim');

% save ROI to MarsBaR ROI file, in current directory, just to show how
saveroi(trim_stim, fullfile(roi_dir, 'batch_trim_stim_roi.mat'));

% Save as image
save_as_image(trim_stim, fullfile(subjroot, 'batch_trim_stim.img'));

% We will do estimation for the trimmed functional ROI, and for two
% anatomical ROIs
bg_L_name = fullfile(roi_dir, 'MNI_Putamen_L_roi.mat');
bg_R_name = fullfile(roi_dir, 'MNI_Putamen_R_roi.mat');
roi_array{1} = trim_stim;
roi_array{2} = maroi(bg_L_name);
roi_array{3} = maroi(bg_R_name);

% MarsBaR estimation for sessions 1 and 3 follows
pwd_orig = pwd;
sesses = {'sess1', 'sess3'};

% event specification for getting fitted event time-courses
% A bit silly here, as we only have one session per model and one event type
event_session_no = 1;
event_type_no = 1;
event_spec = [event_session_no; event_type_no];
event_duration = 0; % default SPM event duration 

clear model_file
for roi_no = 1:length(roi_array)
  roi = roi_array{roi_no};
  for ss = 1:length(sesses)
    % Run SPM model configuration, just to show we don't need to do SPM
    % estimation before using MarsBaR
    % We only need to do this for the first ROI, because we reuse the
    % design for each ROI
    if roi_no == 1
      model_file{ss} = configure_er_model(subjroot, sesses{ss}, mars_sdir);
    end
    D = mardo(model_file{ss});
    % Extract data
    Y = get_marsy(roi, D, 'mean');
    % MarsBaR estimation
    E = estimate(D, Y);
    % Add contrast, return model, and contrast index
    [E Ic] = add_contrasts(E, 'stim_hrf', 'T', [1 0 0]);
    % Get, store statistics
    stat_struct(ss) = compute_contrasts(E, Ic);
    % And fitted time courses
    [this_tc dt] = event_fitted(E, event_spec, event_duration);
    % Make fitted time course into ~% signal change
    tc(:, ss) = this_tc / block_means(E) * 100;
  end
  % Show calculated t statistics and contrast values
  % NB this next line only works when we have only one stat/contrast
  % value per analysis
  vals = [ [1 3]; [stat_struct(:).con]; [stat_struct(:).stat]; ];
  fprintf('Statistics for %s\n', label(roi));
  fprintf('Session %d; contrast value %5.4f; t stat %5.4f\n', vals);
  % Show fitted event time courses
  figure
  secs = [0:length(tc) - 1] * dt; 
  plot(secs, tc)
  title(['Time courses for ' label(roi)], 'Interpreter', 'none');
  xlabel('Seconds')
  ylabel('% signal change');
  legend(sesses)
end
