function [I,xCon,changef]=mars_conman(varargin)
% wrapper for spm_conman, adding indicator for change of xCon
% FORMAT [I,xCon,changef]=mars_conman(xX,xCon,STATmode,n,Prompt,Mcstr,OK2chg)
%
% See spm_conman for details of call
%
% $Id$  

if nargin < 2
  error('Need xCon argument')
end
xCon = varargin{2};
conlen = length(xCon);
[I xCon] = spm_conman(varargin{:});
if length(xCon) == conlen
  changef = 0;
else
  changef = 1;
end