function ev_tc = canonical_event(D, ss, en, dur)
% method gets estimated regressor for single event 
% 
% $Id$
  
if nargin < 3
  error('Need design, session no and event no');
end
if nargin < 4
  dur = 0;
end
if ~is_fmri(D)
  error('Needs FMRI design');
end
if ~is_mars_estimated(D)
  error('Needs MarsBaR estimated design');
end

SPM   = des_struct(D);
Sess  = SPM.Sess;
dt    = SPM.xBF.dt;
bf    = SPM.xBF.bf;

if ~dur, dur = dt; end
sf    = ones(round(dur/dt), 1);
X = [];
for b = 1:size(bf,2)
  X = [X conv(sf, bf(:,b))];
end
j     = Sess(ss).col(Sess(ss).Fc(en).i(1:size(X,2)));
B     = SPM.betas(j);
ev_tc = X*B;
