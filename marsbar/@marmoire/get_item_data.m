function [res, o, errf] = get_item_data(o, item)
% get data for item
% FORMAT [res o errf] = get_item_data(o, item);
%
% o     - object
% item  - name of item to get data for
% 
% If the item contains no data, GUI set is assumed
% data is loaded from data filename if empty.
%
% Returns
% res      - data for item
% o        - object, which may have been modified if has done GUI set
% errf     - flag is 1 if data modification was attempted but failed
% 
% $Id$

if nargin < 2
  error('Need item');
end
errf = 0;
if isempty_item_data(o, item)
  [o errf] = do_set(o, item, 'set_ui');
end
I = get_item_struct(o, item);
res = I.data;
if isempty(res) & ~isempty(I.file_name)
  res = load(I.file_name, ['-' I.file_type]);
end

  