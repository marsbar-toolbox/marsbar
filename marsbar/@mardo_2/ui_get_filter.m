function [K,descrip] = ui_get_filter(D)
% method to get filter via GUI
% FORMAT [K,descrip] = ui_get_filter(D)
%
% Input 
% D       - design
% 
% Returns
% K       - filter (structure)
% descrip - cell array of strings describing filter
%
% $Id$  
  
SPM = des_struct(D);
[K str] = pr_get_filter(SPM.xY.RT, SPM.Sess);
descrip = {str};
