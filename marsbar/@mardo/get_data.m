function d = get_data(D)
% method to get data from design object
% 
% $Id$
  
SPM = des_struct(D);
d = [];
if isfield(SPM, 'marsY')
  d = SPM.marsY;
end