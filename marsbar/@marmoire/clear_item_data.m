function o = clear_item_data(o, item)
% sets data for item to empty
% FORMAT o = clear_item_data(o, item);
%
% o        - object
% item     - name of item to clear data for
% 
% Returns
% o        - object with data cleared for this item
% 
% $Id$

if nargin < 2
  error('Need item to clear data');
end

o = do_set(o, item, 'clear', [], '');
