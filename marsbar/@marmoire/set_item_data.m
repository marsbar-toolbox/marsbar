function o = set_item_data(o, item, data, filename)
% sets data for item
% FORMAT o = set_item_data(o, item, data, filename)
%
% o        - object
% item     - name of item to set for
% data     - data to set 
% filename - filename for data
% 
% If neither data nor filename are set, then GUI set is assumed
% 
% Returns
% o        - object with data set
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

I = get_item_struct(o.items, item);

if pr_is_nan(data) & pr_is_nan(filename)
  I = pr_set_ui(I);
else
  I = pr_set(I, 'set', data, filename);
end
o.items = setfield(o.items, item, I);
