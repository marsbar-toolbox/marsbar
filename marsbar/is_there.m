function tf = is_there(st, varargin)
% determines if field specified by string input is present and not empty
% FORMAT tf = is_there(st, varargin)
%
% $Id$
  
tf = 0;
if nargin < 2
  return
end
res = [];
tmp = st;
for i = 1:length(varargin)
  if isfield(tmp, varargin{i})
    tmp = getfield(tmp, varargin{i});
  else
    return
  end
end
tf = ~isempty(tmp);