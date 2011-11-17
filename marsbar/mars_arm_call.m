function [o,errf,msg] = mars_arm_call(action, o, item, old_o)
% services callbacks from marmoire object set functions
% FORMAT [o,errf,msg] = mars_arm_call(action, o, item)
% See documentation for marmoire object for more detail
%
% action     - action string
% o          - candidate object for checking etc
% item       - name of item that has just been set
% old_o      - object before set
%
% Returns
% o          - possibly modified object
% errf       - flag, set if error in processing
% msg        - message to examplain error
%
% $Id$
  
if nargin < 1
  error('Need action');
end
if nargin < 2
  error('Need object');
end
if nargin < 3
  error('Need item name');
end
if nargin < 4
  error('Need old object');
end

errf = 0; msg = ''; 

item_struct = get_item_struct(o, item);

switch lower(action)
 case 'set_design'
  % callback for setting design

  % Check for save of current design
  [btn o] = save_item_data_ui(old_o, 'def_design', ...
			      struct('ync', 1, ...
				     'prompt_prefix','previous '));
  if btn == -1
    errf = 1; 
    msg = 'Cancelled save of previous design'; 
    return
  end
  
  % Make design into object, do conversions
  [item_struct.data errf msg] = sf_check_design(item_struct.data);
  if errf, o = []; return, end
  o = set_item_struct(o, item, item_struct);
  
  % Unload roi data if design has been set, and data exists
  % and data is not the same size as design
  if ~isempty_item_data(o, 'roi_data')
    [Y o] = get_item_data(o, 'roi_data');
    if n_time_points(Y) ~= n_time_points(item_struct.data)
      fprintf('Design and data have different numbers of rows\n');
      [btn o] = save_item_data_ui(o, 'roi_data', struct('ync', 1));
      if btn == -1, errf = 1; msg = 'ROI save cancelled'; return, end
      o = clear_item_data(o, 'roi_data');
      fprintf('Reset of design, cleared ROI data...\n');
    end
  end
  
 case 'set_data'
  % callback for setting data

  % Check for save of current data
  [btn o] = save_item_data_ui(old_o, 'roi_data', ...
			      struct('ync', 1, ...
				     'prompt_prefix','previous '));
  if btn == -1
    errf = 1; o = [];
    msg = 'Cancelled save of current data'; 
    return
  end
  
  % Make data into object, do conversions
  [item_struct.data errf msg] = sf_check_data(item_struct.data);
  if errf, o = []; return, end
  o = set_item_struct(o, item, item_struct);  

  % Check data matches default design; clear if not
  if ~isempty_item_data(o, 'def_design')
    [D o] = get_item_data(o, 'def_design');
    if n_time_points(D) ~= n_time_points(item_struct.data)
      fprintf('Design and data have different numbers of rows\n');
      [btn o] = save_item_data_ui(o, 'def_design', struct('ync', 1));
      if btn == -1, errf = 1; msg = 'Design save cancelled'; return, end
      o = clear_item_data(o, 'def_design');
      fprintf('Reset of ROI data, cleared default design...\n');
    end
  end

  % Clear default region if data has changed
  global MARS;
  if mars_struct('isthere', MARS, 'WORKSPACE', 'default_region')
    MARS.WORKSPACE.default_region = [];
    fprintf('Reset of data, cleared default region...\n');
  end
  
 case 'set_results'
  % callback for setting results 

  % Need to set default data from results, and load contrast file
  % if not present (this is so for old MarsBaR results)

  data = item_struct.data;
  if isempty(data), return, end
  
  % Check for save of current design
  [btn o] = save_item_data_ui(old_o, 'est_design', ...
			      struct('ync', 1, ...
				     'prompt_prefix','previous '));
  if btn == -1
    errf = 1;
    msg = 'Cancelled save of current design'; 
    return
  end

  % Make design into object, do conversions
  [data errf msg] = sf_check_design(data);
  if errf, return, end
  if ~is_mars_estimated(data)
    error('Design has not been estimated')
  end

  % Deal with case of old MarsBaR designs
  if ~has_contrasts(data);
    fname = spm_get(1, '*x?on.mat', 'Select contrast file');
    [pth, fn, ext] = fileparts(fname);
    tmp = load(fname);
    % Default refreshing
    refreshf = mars_get_option('statistics', 'refresh_contrasts');
    % If the filename does not correspond to marsbar estimation, refresh the
    % contrasts for safety (the user could have selected an SPM xCon fle).
    refreshf = refreshf | ~strcmp(fn, 'mars_xCon.mat')
    data = set_contrasts(data, tmp, refreshf);
  end

  % Put data into object
  item_struct.data = data;
  o = set_item_struct(o, item, item_struct);
  
 otherwise
  error(['Peverse request for ' action]);
end

function [d,errf,msg] = sf_check_design(d)
% Make design into object, do conversions
errf = 0; msg = {};
d = mardo(d);
if ~is_valid(d)
  errf = 1; 
  msg = 'This does not appear to be a valid design';
end
return

function [d,errf,msg] = sf_check_data(d)
% Make data structure into object, do conversions
errf = 0; msg = {};
d = marsy(d);
if ~is_valid(d)
  errf = 1; 
  msg = 'This does not appear to be a valid data structure';
end
return
