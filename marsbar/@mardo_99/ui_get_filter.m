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
[K Hf Lf] = pr_get_filter(SPM.xX.RT, SPM.Sess);
SPM.xX.K = K;
if ~isfield(SPM, 'xsDes')
  SPM.xsDes = [];
end
SPM.xsDes.High_pass_Filter = Lf;
SPM.xsDes.Low_pass_Filter  = Hf;

% return args
D = des_struct(D, SPM);

descrip = {['High_pass_Filter:\t%s', Lf],...
	   ['Low_pass_Filter: \t%s', Hf]};
