function I = event_cols(D, e_spec)
% method gets design columns for single event 
% 
% $Id$
  
if nargin < 2
  error('Need design and event spec');
end
if ~is_fmri(D)
  error('Needs FMRI design');
end

SPM   = des_struct(D);
Sess  = SPM.Sess;
bf    = SPM.xBF.bf;
ss    = e_spec(1);
en    = e_spec(2);
I     = Sess(ss).col(Sess(ss).Fc(en).i(1:size(bf,2)));
