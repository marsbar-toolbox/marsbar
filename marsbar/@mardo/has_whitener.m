function tf = has_whitener(D)
% returns 1 if design has whitening filter
%
% $Id$
  
% Which is not the case for default, SPM99 designs
tf = 0;