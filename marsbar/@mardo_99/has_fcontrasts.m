function tf = has_fcontrasts(o)
% returns 1 if design contains F contrast information
tf = isfield(des_struct(o), 'F_iX0');
