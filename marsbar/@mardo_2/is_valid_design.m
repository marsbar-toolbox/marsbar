function tf = is_valid_design(o)
% returns 1 if object contains valid SPM/MarsBaR design
tf = isfield(o.des_struct, 'xX');
