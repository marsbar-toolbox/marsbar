function Xn = event_x_fir(D, e_spec, bin_length, bin_no, opts)
% method to return FIR design matrix columns for session
% FORMAT Xn = event_x_fir(D, e_spec, bin_length, bin_no, opts)
% 
% D          - design object
% e_spec     - event specification for single event
%                [session no; event no]
% bin_length - bin length in seconds  [TR]
% bin_no     - number of bins for FIR [25 seconds / bin_length]
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
% $Id$

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

xBF         = SPM.xBF;
xBF.name    = 'Finite Impulse Response';
xBF.order   = bin_no;
xBF.length  = xBF.order*bin_length;
xBF         = pr_spm_get_bf(xBF);

U           = SPM.Sess(s).U(e);
k           = SPM.nscan(s);

% If all the durations are zero, the model is already single.  The stick
% function values have been set to 1/dt though, which is confusing, so
% we'll reset the stick functions to have 1s
if ~any(U.dur), opts.single = 1; end

if isfield(opts, 'single')
  U.u = sf_ones_ons(U, xBF, k);
  if verbose(D)
    if any(diff(U.dur))
      warning(['Different event durations; ' ...
	       'single FIR model likely to be invalid']);
    end
  end
else
  U.u = U.u(:,1);
end

Xn          = pr_spm_volterra(U,xBF.bf,1);
Xn          = Xn([0:(k - 1)]* xBF.T + xBF.T0 + 32,:);

return

function sf = sf_ones_ons(U, xBF, k)
% Return onsets with only 1s in start time bin for each event
  
ons   = U.ons;
T     = xBF.T;
dt    = xBF.dt;
switch xBF.UNITS
 case 'scans'
  TR = T*dt;
 case 'secs'
  TR = 1;
end

ton       = round(ons*TR/dt) + 32;
sf        = sparse((k*T + 128),1);
for j = 1:length(ton)
  sf(ton(j),:) = sf(ton(j),:) + 1;
end

return