function [o, errf] = clear_item_data(o, item)
% sets data for item to empty
% FORMAT [o errf] = clear_item_data(o, item);
%
% o        - object
% item     - name of item to clear data for
% 
% Returns
% o        - object with data cleared for this item
% errf     - flag is 1 if data was not cleared for some reason
%
% $Id$

if nargin < 2
  error('Need item to clear data');
end

[o errf] = do_set(o, item, 'clear', [], '');
