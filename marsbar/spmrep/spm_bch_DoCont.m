function status = spm_bch_DoCont
% SPM batch system: Contrast computation - disabled for MarsBar
% FORMAT status = spm_bch_DoCont
%
% $Id$

%- initialise status
%-----------------------------------------------------------------------
status.str = '';
status.err = 0;
swd = pwd;

% and return
return