function tf = my_design(des)
% returns 1 if design looks like it is of SPM5 / 8 type
% 
% $Id: my_design.m 328 2004-03-03 01:56:03Z matthewbrett $
  
tf = 0;
if isfield(des, 'SPM'), des = des.SPM; end
if isfield(des, 'SPMid')
  tf = ~isempty(strmatch('SPM5', des.SPMid)) | ...
       ~isempty(strmatch('SPM8', des.SPMid)) | ...
       ~isempty(strmatch('SPM12', des.SPMid));
end
