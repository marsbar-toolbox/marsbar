function [I,D,changef]=ui_get_contrasts(D, varargin)
% wrapper for spm_conman, adding indicator for change of xCon
% FORMAT [I,D,changef]=ui_get_contrasts(D, varargin)
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

xCon = mars_struct('getifthere', SPM, 'xCon');
conlen = length(xCon);
[I xCon] = spm_conman(xX,xCon,varargin{:});
if length(xCon) == conlen
  changef = 0;
else
  changef = 1;
  SPM.xCon = xCon;
  D = des_struct(D, SPM);
end