function [I,D,changef]=ui_get_contrast(D, varargin)
% wrapper for spm_conman, adding indicator for change of xCon
% FORMAT [I,D,changef]=ui_get_contrast(D, varargin)
%
% See spm_conman for details of call
%
% $Id$  

SPM = des_struct(D);
conlen = length(SPM.xCon);
[I SPM.xCon] = spm_conman(SPM.xX,SPM.xCon,varargin{:});
if length(SPM.xCon) == conlen
  changef = 0;
else
  changef = 1;
  D = des_struct(D, SPM);
end