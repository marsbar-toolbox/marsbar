function Xn = event_x_fir(D, e_spec, bin_length, bin_no, opts)
% method to return FIR design matrix columns for session
% FORMAT Xn = event_x_fir(D, e_spec, bin_length, bin_no, opts)
% 
% D          - design object
% e_spec     - event specification for single event
%                [session no; event no]
% bin_length - bin length in seconds
% bin_no     - number of bins for FIR
% opts       - structure, containing fields with options
%                'single' - if field present, gives single FIR 
%                 This option removes any duration information, and
%                 returns a simple per onset FIR model, where ones in the
%                 design matrix corresponds to 1 event at the given
%                 offset. See event_fitted_fir.m for more details.
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
if nargin < 5
  opts = [];
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
T           = recorded_fMRI_T;
bf          = kron(eye(bin_no),ones(round(bin_length/dt),1));
bf          = pr_spm_orth(bf);

% Reset columns to 1 after orthogonalization
BF{1}       = bf / bf(1);

k           = length(Sess.row);

if isfield(opts, 'single')
  [onsets durations] = event_onsets(D, e_spec);
  ons   = sparse(k*T,1);
  for p = 1:length(onsets)
    q  = round(onsets(p)*T + 1);
    ons(q) = 1;
  end
  SF{1} = ons(1:(k*T));
  if verbose(D) & any(diff(durations))
      warning(['Apparently there were different event durations; ' ...
	       'single FIR model likely to be invalid']);
  end
else
  SF{1}       = Sess.sf{e}(:,1);
end

Xn          = pr_spm_volterra(SF,BF,{'FIR'},1);

% Resample design matrix {X} at acquisition times
%-----------------------------------------------
Xn          = Xn([0:k-1]*T + fMRI_T0,:);
