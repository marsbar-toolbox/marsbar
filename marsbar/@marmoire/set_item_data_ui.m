function [o, errf] = set_item_data_ui(o, item)
% sets data for item using GUI
% FORMAT [o, errf] = set_item_data_ui(o, item)
%
% o        - object
% item     - name of item to set for
% 
% Returns
% o        - object with data set (probably)
% errf     - flag is 1 if data was not set
%
% $Id$

if nargin < 2
  error('Need item to set to');
end

[o errf] = do_set(o, item, 'set_ui');
