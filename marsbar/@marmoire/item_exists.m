function tf = item_exists(o, item)
% returns true if there is an item of this name
%
% $Id$

tf = 0;
if ~isempty(o.items)
  tf = ismember(item, fieldnames(o.items));
end