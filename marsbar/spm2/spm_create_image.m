function V = spm_create_image(V)
% Wrapper for spm_create_vol, for compatibility with SPM99
% FORMAT V = spm_create_image(V)
%
% Actually, MarsBaR itself does not use this function; it's included here
% for compatibility with Phiwave (phiwave.sourceforge.net), that depends
% on MarsBaR for its design interface and such.
%
% $Id$

V = spm_create_vol(V);
