function tf = isempty_item_data(o, item)
% returns 1 if no data for this item
% FORMAT tf = sjjs(o, item)
% 
% o     - object
% item  - item name
% 
% tf    - flag, 1 if not empty
% 
% $Id$

if nargin < 2
  error('Need item')
end
I  = get_item_struct(o, item);
tf = pr_isempty(I);
  