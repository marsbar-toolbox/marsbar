function o = set_item_data_ui(o, item)
% sets data for item using GUI
% FORMAT o = set_item_data_ui(o, item)
%
% o        - object
% item     - name of item to set for
% 
% Returns
% o        - object with data set
% 
% $Id$

if nargin < 2
  error('Need item to set to');
end
I = get_item_struct(o, item);
I = pr_set_ui(I);
o.items = setfield(o.items, item, I);
