function Xn = event_x_fir(D, e_spec, bin_length, bin_no)
% method to return FIR design matrix columns for session
% FORMAT Xn = event_x_fir(D, e_spec, bin_length, bin_no)
% 
% D          - design object
% e_spec     - event specification for single event
%                [session no; event no]
% bin_length - bin length in seconds  [TR]
% bin_no     - number of bins for FIR [25 seconds / bin_length]
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
U.u         = U.u(:,1);
Xn          = pr_spm_volterra(U,xBF.bf,1);
k           = SPM.nscan(s);
Xn          = Xn([0:(k - 1)]* xBF.T + xBF.T0 + 32,:);
