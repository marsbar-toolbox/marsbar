function [res, o] = get_item_data(o, item)
% get data for item
% FORMAT [res o] = get_item_data(o, item);
%
% o     - object
% item  - name of item to get data for
% 
% If the item contains no data, GUI set is assumed
% 
% Returns
% res   - data for item
% o     - object, which may have been modified if has done GUI set
% 
% $Id$

if nargin < 2
  error('Need item');
end
I = get_item_struct(o, item);
if pr_isempty(I)
  I = pr_set_ui(I);
  o.items = setfield(o.items, item, I);
end
res = I.data;
if isempty(res) & ~isempty(I.file_name)
  res = load(I.file_name, ['-' I.file_type]);
end

  