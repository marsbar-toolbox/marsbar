function tf = my_design(des)
% returns 1 if design looks like it is of SPM99 type
% 
% $Id$
  
tf = 0;
if isfield(des, 'SPMid')
  % Can be SPM99 design with SPM99 tag or MarsBaR tag
  % (MarsBaR tag used only by MarsBaR <= 0.23)
  tf = ~isempty(strmatch('SPM99', des.SPMid)) | ...
       ~isempty(strmatch('MarsBar', des.SPMid));
end