function tf = my_design(des)
% returns 1 if design looks like it is of SPM2 type
tf = isfield(des, 'SPM') | isfield(des, 'xY');