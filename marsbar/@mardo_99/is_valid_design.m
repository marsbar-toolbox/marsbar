function tf = is_valid_design(o)
% returns 1 if object contains valid SPM/MarsBaR design
tf = isfield(des_struct(o), 'xX');
