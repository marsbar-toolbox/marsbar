function tf = is_marsed(o)
% returns 1 if design has been processed with MarsBaR
tf = isfield(o.des_struct, 'xMars');
