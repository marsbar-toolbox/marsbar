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
  % Clear ROI data if design has changed

  I = varargin{1};

  % Make design into object, do conversions
  [I.data errf msg] = sf_check_design(I.data);
  if errf
    res = [];
    return
  end
  
  % Unload roi data if design has been set, and data exists
  if ~mars_armoire('isempty', 'roi_data')
    mars_armoire('save_ui', 'roi_data', 'y');
    mars_armoire('clear', 'roi_data');
    fprintf('Reset of design, cleared ROI data...\n');
  end
  res = I;
  
 case 'set_data'
  % callback for setting design
  % FORMAT [data errf msg] = mars_arm_call('set_data', I);

  I = varargin{1};

  % Make data into object, do conversions
  [I.data errf msg] = sf_check_data(I.data);
  if errf
    res = [];
    return
  end

  % Clear default region if data has changed
  global MARS;
  if isfield(MARS, 'WORKSPACE')
    if isfield(MARS.WORKSPACE, 'default_region')
      if ~isempty(MARS.WORKSPACE.default_region)
	MARS.WORKSPACE.default_region = [];
	fprintf('Reset of data, cleared default region...\n');
      end
    end
  end
  res = I;
  
 case 'set_results'
  % callback for setting results 
  % FORMAT [data errf msg] = mars_arm_call('set_results', data);
  % Need to set default data from results, and load contrast file
  % if not present (this is so for old MarsBaR results)

  data = varargin{1};
  if isempty(data), return, end
  
  % Make design into object, do conversions
  [data errf msg] = sf_check_design(data);
  if errf
    res = [];
    return
  end
  if ~is_estimated(data)
    error('Design has not been estimated')
  end
  
  % Deal with case of old MarsBaR designs
  if ~has_contrasts(data);
    tmp = load(spm_get(1, '*x?on.mat',...
		       'Select contrast file')); 
    data = set_contrasts(data, tmp);
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