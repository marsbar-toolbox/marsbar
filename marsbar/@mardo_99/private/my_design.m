function tf = my_design(des)
% returns 1 if design looks like it is of SPM99 type
tf = 0;
if isfield(des, 'SPMid')
  tf = ~isempty(strmatch('SPM99', des.SPMid));
end