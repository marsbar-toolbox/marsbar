function [D,descrip] = ui_get_filter(D)
% method to get filter via GUI
% FORMAT [D,descrip] = ui_get_filter(D)
%
% Input 
% D       - design
% 
% Returns
% D       - design with modified filter
% descrip - cell array of strings describing filter
%
% $Id$  
  
SPM = des_struct(D);
[SPM.xX.K str] = pr_get_filter(SPM.xY.RT, SPM.Sess);
if ~isfield(SPM, 'xsDes')
  SPM.xsDes = [];
end
SPM.xsDes.High_pass_Filter = str;

% return args
D = des_struct(D, SPM);
descrip = {str};
