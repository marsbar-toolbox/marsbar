function n = n_time_points(o)
% get number of time_points in design
% 
% $Id$ 

SPM = des_struct(o);  
n = size(SPM.xX.X, 1);