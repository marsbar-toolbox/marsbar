function o = add_if_absent(o, item, data)
% Adds item only if not already present
% 
% $Id$
  
if nargin < 2
  error('Need name of item to add');
end
if nargin < 3
  error('Need data to put into item');
end
if ~item_exists(o, item)
  o = add_item(o, item, data);
end