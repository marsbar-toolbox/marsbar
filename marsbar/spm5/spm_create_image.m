function V = spm_create_image(V)
% Wrapper for spm_create_vol, for compatibility with SPM99
% FORMAT V = spm_create_image(V)
% 
% $Id: spm_create_image.m 510 2004-11-17 01:51:58Z matthewbrett $

V = spm_create_vol(V);
