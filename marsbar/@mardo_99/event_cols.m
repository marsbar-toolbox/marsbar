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
ss    = e_spec(1);
en    = e_spec(2);

j    = 1:size(Sess{ss}.sf{en},2):length(Sess{ss}.ind{en});
I    = Sess{ss}.col(Sess{ss}.ind{en}(j));
