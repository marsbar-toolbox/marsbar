function SPM = er_model_spm2(sess_dir, sesses, ana_dir)
% SPM2 batch script wrapper for ER data
% FORMAT SPM = er_model_spm2(sess_dir, sesses)
%
% sess_dir        - directory containing session directories
% sesses          - string or cell array of session directory names
% ana_dir         - analysis directory
% 
% Returns
% SPM             - SPM model structure after configuration
% 
% The script is specific to this design...
%
% $Id: er_model_spm2.m,v 1.1.1.1 2004/08/14 00:07:52 matthewbrett Exp $

if nargin < 1
  error('Need directory containing session subdirectories');
end
if nargin < 2
  error('Need directory names for sessions');
end
if nargin < 3
  ana_dir = pwd;
end

if ischar(sesses), sesses = cellstr(sesses); end
nsessions = length(sesses);

pwd_store = pwd;
cd(ana_dir);

% load SPM defaults
if ~exist('defaults', 'var')
  global defaults;
  spm_defaults; 
end

% Specify some design stuff
SPM.xY.RT          =  2.02726;                              % seconds

% Specify design
%===========================================================================
% global normalization: OPTOINS:'Scaling'|'None'
%---------------------------------------------------------------------------
SPM.xGX.iGXcalc    = 'None';

% low frequency confound: high-pass cutoff (secs) [Inf = no filtering]
%---------------------------------------------------------------------------
SPM.xX.K(1).HParam    = 60;

% intrinsic autocorrelations: OPTIONS: 'none'|'AR(1) + w'
%-----------------------------------------------------------------------
SPM.xVi.form       = 'AR(1) + w';

% basis functions and timing parameters
%---------------------------------------------------------------------------
% OPTIONS:'hrf'
%         'hrf (with time derivative)'
%         'hrf (with time and dispersion derivatives)'
%         'Fourier set'
%         'Fourier set (Hanning)'
%         'Gamma functions'
%         'Finite Impulse Response'
%---------------------------------------------------------------------------
SPM.xBF.name       = 'hrf (with time derivative)';
SPM.xBF.length     = 24;                % length in seconds 
SPM.xBF.order      = 1;                 % order of basis set
SPM.xBF.T          = 16;                % number of time bins per scan
SPM.xBF.T0         = 1;                 % first time bin (see slice timing)
SPM.xBF.UNITS      = 'scans';           % OPTIONS: 'scans'|'secs' for onsets
SPM.xBF.Volterra   = 1;                 % OPTIONS: 1|2 = order of convolution

condnames = {'vis_stim'};
nconds = length(condnames);

% specify filter for filenames
Filter             = 's*.img';

PP = ''; stimons = [];
for ss = 1:nsessions
  % directory containing scans
  fildir = fullfile(sess_dir, sesses{ss});

  % Condition stuff - onset times for visual stimulus
  condir = fullfile(fildir, 'onsets');
  condfile = spm_get('Files', condir, 'flash*.txt');
  condons = spm_load(condfile);
  tmp = condons(:,2); % get stimulus column
  tmp(tmp < 0) = 0; % correct negative onsets
  stimons{1} = tmp;  

  for cno = 1:nconds
    SPM.Sess(ss).U(cno).name      =condnames(cno);
    SPM.Sess(ss).U(cno).P(1).name = 'none'; % Parametric modulation
    SPM.Sess(ss).U(cno).ons = stimons{cno};
    SPM.Sess(ss).U(cno).dur = 0;
  end
    
  % file selection
  P         = spm_get('files',fildir,Filter);
  SPM.nscan(ss) = size(P,1);
  
  % covariates 
  SPM.Sess(ss).C.C    = [];       % [n x c double] covariates
  SPM.Sess(ss).C.name = {};       % [1 x c cell]   names

  % set files
  PP           = strvcat(PP, P);

end

% set files
SPM.xY.P           = PP;

% Configure design matrix
SPM = spm_fmri_spm_ui(SPM);

% Return to original directory
cd(pwd_store);