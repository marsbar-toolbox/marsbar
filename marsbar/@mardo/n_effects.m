function n = n_effects(o)
% get number of effects (columns) in design
% 
% $Id$ 

SPM = des_struct(o);  
n = size(SPM.xX.X, 2);