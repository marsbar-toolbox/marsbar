function o = set_item_struct(o, item, item_struct)
% set whole item structure, including parameters
% FORMAT I = get_item_struct(o, item, item_struct)
% 
% o           - object
% item        - item name
% item_struct - item structure
% 
% Returns
% o           - object with item structure set
%
% $Id$

% We might consider error checking here.  But hey.
o.items = setfield(o.items, item, item_struct);
