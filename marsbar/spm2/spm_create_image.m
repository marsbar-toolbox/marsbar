function V = spm_create_image(V)
% Wrapper for spm_create_vol, for compatibility with SPM99
% FORMAT V = spm_create_image(V)
% 
% $Id$

V = spm_create_vol(V);
