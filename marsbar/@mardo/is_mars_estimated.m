function tf = is_mars_estimated(D)
% method returns 1 if design has been estimated in MarsBaR
% 
% $Id$
  
tf = isfield(D.des_struct, 'marsY');