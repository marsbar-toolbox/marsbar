function [o, others] = marmoire(params, varargin)
% marmoire - class constructor for marmoire container type
% FORMAT [o, others] = marmoire(params, varargin)
%  
% the marmoire object is to store various bits of stuff
% (armoire is the French for cupboard).
% This cupboard is to put items which I will want to fish out 
% from time to time.
% 
% The items may well be associated with a filename
% If they are associated with a filename when set, they 
% are assumed to have been saved already.
% If not, they are flagged as awaiting a save
%
% If the data changes, you can indicate this with the 
% update method, which changes the data, and flags for a save
%
% The permissable actions are:
%
% add_item         - add an item to the armoire
% item_exists      - ask if there an exists an item of given name
% add_if_absent    - adds item if it does not yet exist
% set_item_data    - sets data for item 
% get_item_data    - gets data from item
% set_item_data_ui - sets data, getting via UI
% save_item_data   - save data for item, if required
% save_item_data_ui - saves, using GUI to ask for filename
% update_item_data  - updates data, sets flag to show change
% clear_item_data   - clears data for item
% isempty_item_data - returns 1 if no data for item
% item_needs_save   - returns 1 if this item needs a save
%
% Each item is stored in a field 'items' in the object
%
% The name of item is the same as the name of the field in the items field
% of the object, and this is the 'item' argument to the various methods.
%
% Each item field cotains a structure, widh the data contained in a field
% 'data'. The rest of the fields in the structure are parameters telling
% the object how to deal with the various manipulations of the data.  So,
% each item requires the following fields:
%                 
% data            - the data 
%                   (or a filename which loads as the data - see the
%                   char_is_filename field)
% has_changed     - flag, if set, means data has changed since first set
% save_if_changed - flag, if set, will try to save changed data when a
%                   save is requested.  Saves can also be forced.
% leave_as_file   - flag, if set, will attempt to leave the data, defined
%                   by the filename, on the disk, not in memory, and only
%                   load the data for a 'get'.  
%                   Otherwise, if a set occurs, and the data field is
%                   empty, will load data into the global variable when
%                   'set'ing field and leave it there.
%                   If the data changes, and requires a save, this field
%                   has no function, until the next save.
% file_name       - file name of .mat file containing data
%                   If data is empty, and file_name is not, 
%                   an attempt to 'get' data will load contents of
%                   file_name
% default_file_name - default filename offered for save 
% file_type       - type of file to load ('mat' or 'ascii')
% char_is_filename - flag, if set, char data is assumed to be a filename
% filter_spec     - filter spec for uigetfile (see help uigetfile)
% prompt          - prompt for uigetfile
% verbose         - flag, if set, displays more information during
%                   processing
% set_action      - actions to perform when item is set
%                   in form of callback string.  This is executed
%                   in the 'i_set' subfunction, and can use all
%                   variables functions defined therein.  See programmers
%                   notes in the function for callback format
% set_action_if_update - flag, if set, applied set_action for 'update' as
%                   well as 'set'
% set_action_if_clear - flag, if set, applied set_action for 'clear' as
%                   well as 'set'
%
% $Id$
  
% Programmers' notes
% ------------------
% set_action callbacks
% callbacks should in the following formats;
%
% [o errf msg] = my_function(args) 
%
%  The return argument 'o' is the modified whole object. If
% 'errf' is set, the routine warns, and aborts the set action with the
% 'msg'.
%
% The preferred args will give a format of are:
% [o errf msg] = my_function(o, item, old_o)
% 
% where o is the object after the data has been set, item is the name of
% the item which has just been set, and old_o is the object before the
% data was set.
% 
% The available args are:
% o               - the whole object with new data set
% item            - the name of the item which has been set
% old_o           - the object before the data was set.
% 
% as well as:
%
% item_struct     - proposed whole item field contents
% data            - proposed data to be inserted 
% passed_filename - filename passed to function
%
% and anything else you can see in context, for the line containing the
% 'eval' statement in the do_set method
  
myclass = 'marmoire';
defstruct = struct('items', []);

if nargin < 1
  params = [];
end
if isa(params, myclass)
  o = params;
  return
end

% fill with defaults, parse into fields for this object, children
[pparams, others] = mars_struct('ffillsplit', defstruct, params);

% add version tag (was CVS; now marsbar version)
pparams.cvs_version = marsbar('ver');

% Set as object
o  = class(pparams, myclass);
