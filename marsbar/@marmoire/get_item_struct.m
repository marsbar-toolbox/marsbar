function I = get_item_struct(o, item)
% get whole item structure, including parameters
% FORMAT I = get_item_struct(o, item)
% 
% This is used internally, and might be useful for debugging
% 
% o       - object
% item    - item name
%
% Returns
% I       - item structure, with data in field 'data' and/or specified in
%           field 'filename'
%
% $Id$

if ~item_exists(o, item)
  error('Item does not exist');
end
I = getfield(o.items, item);
