function [I,D,changef]=ui_get_contrast(D, varargin)
% wrapper for spm_conman, adding indicator for change of xCon
% FORMAT [I,D,changef]=ui_get_contrast(D, varargin)
%
% See spm_conman for details of call
%
% $Id$  

SPM = des_struct(D);
xX = SPM.xX;

% A little hack to make spm_conman compatible between SPM 99 and 2
if isfield(xX, 'name')
  xX.Xnames = xX.name;
elseif isfield(xX, 'Xnames')
  xX.name = xX.Xnames;
end

conlen = length(SPM.xCon);
[I SPM.xCon] = spm_conman(xX,SPM.xCon,varargin{:});
if length(SPM.xCon) == conlen
  changef = 0;
else
  changef = 1;
  D = des_struct(D, SPM);
end