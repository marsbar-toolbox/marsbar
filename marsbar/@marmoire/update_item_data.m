function o = update_item_data(o, item, data, filename)
% updates data for item (sets data, flags change)
% FORMAT o = update_item_data(o, item, data, filename)
%
% o        - object
% item     - name of item to update for
% data     - data to set 
% filename - filename for data
% 
% Returns
% o        - object with data updated
% 
% $Id$

if nargin < 2
  error('Need item to set to');
end
if nargin < 3
  data = NaN;
end
if nargin < 4
  filename = NaN;
end

I = get_item_struct(o, item);
I = pr_set(I, 'update', data, filename);
I.has_changed = 1;
o.items = setfield(o.items, item, I);
