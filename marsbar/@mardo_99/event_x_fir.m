function Xn = event_x_fir(D, e_spec, bin_length, bin_no)
% method to return FIR design matrix columns for session
% FORMAT Xn = event_x_fir(D, e_spec, bin_length, bin_no)
% 
% D          - design object
% e_spec     - event specification for single event
%                [session no; event no]
% bin_length - bin length in seconds
% bin_no     - number of bins for FIR
% 
% Returns
% Xn         - columns in design matrix for FIR model
%
% Note that we have a problem, in that the assumed start bin is not saved
% in the SPM99 design format, so we have to hope it has not changed from
% the current defaults.
%
% $Id$

% global parameters
global fMRI_T; 
global fMRI_T0; 
if isempty(fMRI_T),  fMRI_T  = 16; end;
if isempty(fMRI_T0), fMRI_T0 = 1;  end;

if nargin < 2
  error('Need event specfication');
end
if nargin < 3
  bin_length = [];
end
if nargin < 4
  bin_no = [];
end
s = e_spec(1);
e = e_spec(2);
if isempty(bin_length)
  bin_length = tr(D);
end
if isempty(bin_no)
  bin_no = round(25/bin_length);
end

SPM         = des_struct(D);
Sess        = SPM.Sess{s};
dt          = SPM.xX.dt;

% Check dt against fMRI_T, warn if it differs
recorded_fMRI_T = round(SPM.xX.RT / dt);
if recorded_fMRI_T ~= fMRI_T & verbose(D)
  warning(sprintf([...
      'fMRI_T (%d) does not match recorded dt, using recorded dt (%d).\n' ...
      'The original fMRI_T0 has not been recorded, assuming %d.'],...
		  fMRI_T, recorded_fMRI_T, fMRI_T0));
end

bf          = kron(eye(bin_no),ones(round(bin_length/dt),1));
BF{1}       = pr_spm_orth(bf);
sf          = Sess.sf{e};
SF{1}       = sf(:, 1);  
k           = length(Sess.row);

Xn          = pr_spm_volterra(SF,BF,{'FIR'},1);

% Resample design matrix {X} at acquisition times
%-----------------------------------------------
Xn          = Xn([0:k-1]*recorded_fMRI_T + fMRI_T0,:);
