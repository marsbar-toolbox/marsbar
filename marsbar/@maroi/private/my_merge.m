function c = my_merge(a, b)
% function my_merge - merges two structures
%
% $Id$

if nargin < 2
  error('Need two structures');
end

c = a;
if isempty(b), return, end

for bf = fieldnames(b)';
  if ~isfield(a, bf{1})
    c = setfield(c, bf{1}, getfield(b, bf{1}));
  end
end