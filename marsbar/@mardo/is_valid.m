function tf = is_valid(o)
% returns 1 if object contains valid SPM/MarsBaR design
% 
% $Id$
  
tf = isfield(des_struct(o), 'xX');
