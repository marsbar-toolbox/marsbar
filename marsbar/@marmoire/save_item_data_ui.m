function [saved_f, o] = save_item_data_ui(o, item, flags, filename)
% save data for item to file using GUI
% FORMAT [saved_f o] = save_item_data_ui(o, item, flags, filename)
%
% o        - object
% item     - name of item
% flags    - flags for save; see save_item_data.m for details
% filename - filename for save
% 
% Returns
% saved_f  - flag set to 1 if save done, 0 not done, -1 if cancel
%            Note that, if saving with more than one item, then the value
%            is from the last value saved/not saved.  Cancel aborts the
%            attempt to save.
% o        - possibly modified object (changed filename, maybe data is
%            left as a file, and data field made empty) 
% 
% $Id$

if nargin < 2
  error('Need item');
end
if nargin < 3
  flags = NaN;
end
if nargin < 4
  filename = NaN;
end

if ~isstruct(flags), flags = []; end
flags.ui = 1;

[saved_f o] = save_item_data(o, item, flags, filename);