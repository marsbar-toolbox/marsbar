function V = spm_create_vol(V)
% Wrapper for spm_create_image, for compatibility with SPM2
% FORMAT V = spm_create_vol(V)
% 
% $Id$

V = spm_create_image(V);
