function [c, d] = my_fillsplit(a, b)
% fills fields in a from those present in b, returns a, remaining b
% FORMAT c = my_fillsplit(a, b)
% a, b are structures
% c, d are returned structure
%
% $Id$
  
if nargin < 2
  error('Must specify a and b')
end
c = a; d = b;
if isempty(b)
  return
end

cf = fieldnames(c);
for i=1:length(cf)
  if isfield(d, cf{i})
    dfc = getfield(d,cf{i});
    if ~isempty(dfc) 
      c = setfield(c, cf{i}, dfc);
    end
    d = rmfield(d, cf{i});
  end
end

return