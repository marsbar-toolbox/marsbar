function [res,errf,msg] = mars_arm_call(action, varargin)
% services callbacks from mars_armoire set functions
% FORMAT [res,errf,msg] = mars_arm_call(action, varargin)
% See documentation for mars_armoire for more detail
%
% action     - action string
% 
% Returns
% res        - result (data or whole field for mars_armoire
% errf       - flag, set if error in processing
% msg        - message to examplain error
%
% $Id$
  
if nargin < 1
  error('Need action');
end
errf = 0; msg = ''; res =[];

switch lower(action)
 case 'set_design'
  % callback for setting design
  % FORMAT [data errf msg] = mars_arm_call('set_design', I);
  
  % Check for save of current design
  btn = mars_armoire('save_ui', 'def_design', ...
		     struct('ync', 1, ...
			    'prompt_prefix','previous '));
  if btn == -1
    errf = 1; 
    msg = 'Cancelled save of previous design'; 
    return
  end
  
  % Clear ROI data if design is no longer compatible with data

  I = varargin{1};

  % Make design into object, do conversions
  [I.data errf msg] = sf_check_design(I.data);
  if errf
    res = [];
    return
  end
  
  % Unload roi data if design has been set, and data exists
  % and data is not the same size as design
  if ~mars_armoire('isempty', 'roi_data')
    Y = mars_armoire('get', 'roi_data');
    if n_time_points(Y) ~= n_time_points(I.data)
      fprintf('Design and data have different numbers of rows\n');
      btn = mars_armoire('save_ui', 'roi_data', struct('ync', 1));
      if btn == -1, errf = 1; msg = 'ROI save cancelled'; return, end
      mars_armoire('clear', 'roi_data');
      fprintf('Reset of design, cleared ROI data...\n');
    end
  end
  res = I;
  
 case 'set_data'
  % callback for setting data
  % FORMAT [data errf msg] = mars_arm_call('set_data', I);

  % Check for save of current data
  btn = mars_armoire('save_ui', 'roi_data', ...
  		     struct('ync', 1, ...
			    'prompt_prefix','previous '));
  if btn == -1
    errf = 1; res = [];
    msg = 'Cancelled save of current data'; 
    return
  end
  
  I = varargin{1};

  % Make data into object, do conversions
  [I.data errf msg] = sf_check_data(I.data);
  if errf, res = []; return, end

  % Check data matches default design; clear if not
  if ~mars_armoire('isempty', 'def_design')
    D = mars_armoire('get', 'def_design');
    if n_time_points(D) ~= n_time_points(I.data)
      fprintf('Design and data have different numbers of rows\n');
      btn = mars_armoire('save_ui', 'def_design', struct('ync', 1));
      if btn == -1, errf = 1; msg = 'Design save cancelled'; return, end
      mars_armoire('clear', 'def_design');
      fprintf('Reset of ROI data, cleared default design...\n');
    end
  end

  % Clear default region if data has changed
  global MARS;
  if mars_struct('isthere', MARS, 'WORKSPACE', 'default_region')
    MARS.WORKSPACE.default_region = [];
    fprintf('Reset of data, cleared default region...\n');
  end
  res = I;
  
 case 'set_results'
  % callback for setting results 
  % FORMAT [data errf msg] = mars_arm_call('set_results', data);
  % Need to set default data from results, and load contrast file
  % if not present (this is so for old MarsBaR results)

  data = varargin{1};
  if isempty(data), return, end
  
  % Check for save of current design
  btn = mars_armoire('save_ui', 'est_design', ...
		     struct('ync', 1, ...
			    'prompt_prefix','previous '));
  if btn == -1
    errf = 1; res = [];
    msg = 'Cancelled save of current design'; 
    return
  end

  % Make design into object, do conversions
  [data errf msg] = sf_check_design(data);
  if errf, res = []; return, end
  if ~is_mars_estimated(data)
    error('Design has not been estimated')
  end
  
  % Deal with case of old MarsBaR designs
  if ~has_contrasts(data);
    tmp = load(spm_get(1, '*x?on.mat',...
		       'Select contrast file')); 
    data = set_contrasts(data, tmp);
  end

  % Save and replace data if necessary
  if ~mars_armoire('isempty','roi_data')
    Y  = get_data(data);
    if Y ~= mars_armoire('get', 'roi_data'); 
      btn = mars_armoire('save_ui', 'roi_data', struct('ync', 1));
      if btn == -1
	errf = 1; res = [];
	msg = 'Cancelled save ROI data'; 
	return
      end
      mars_armoire('set', 'roi_data', Y);
      mars_armoire('has_changed', 'roi_data', 0);
      fprintf('Set ROI data from estimated design...\n');
    end
  end

  % Clear default contrast
  global MARS;
  if mars_struct('isthere', MARS, 'WORKSPACE', 'default_contrast')
    MARS.WORKSPACE.default_contrast = [];
    fprintf('Reset of estimated design, cleared default contrast...\n');
  end

  res = data;
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