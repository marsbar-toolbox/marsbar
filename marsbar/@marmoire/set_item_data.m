function [o, errf] = set_item_data(o, item, data, filename)
% sets data for item
% FORMAT [o errf] = set_item_data(o, item, data, filename)
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
% errf     - flag is 1 if data was not set
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

if pr_is_nan(data) & pr_is_nan(filename)
  action = 'set_ui';
else
  action = 'set';
end
[o errf] = do_set(o, item, action, data, filename);
