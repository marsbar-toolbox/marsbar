function cols = block_cols(D)
% method gets design columns for block (session / subject)
% FORMAT cols = block_cols(D)
% 
% Returns cell array of column indices (one per session)
%
% $Id$
  
if ~is_fmri(D)
  error('Needs FMRI design');
end

SPM   = des_struct(D);
Sess  = SPM.Sess;
for i = 1:length(Sess)
  cols{i} = Sess{i}.col;
end
