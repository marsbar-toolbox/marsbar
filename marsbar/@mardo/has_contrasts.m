function tf = has_contrasts(D)
% method returns 1 if design has contrasts
% 
% $Id$
  
tf = isfield(des_struct(D), 'xCon');