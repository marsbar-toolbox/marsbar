function [o, errf] = update_item_data(o, item, data, filename)
% updates data for item (sets data, flags change)
% FORMAT [o, errf] = update_item_data(o, item, data, filename)
%
% o        - object
% item     - name of item to update for
% data     - data to set 
% filename - filename for data
% 
% Returns
% o        - object with data (probably) updated
% errf     - flag is 1 if data was not updated for some reason
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

[o errf] = do_set(o, item, 'update', data, filename);
