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

  % Do any required processing of design
  [I.data I.has_changed] = mars_process_design(I.data);
  
  % Unload roi data if design has been set, and data exists
  if ~mars_armoire('isempty', 'roi_data')
    mars_armoire('clear', 'roi_data');
    fprintf('Reset of design, cleared ROI data...\n');
  end
  res = I;
  
 case 'set_results'
  % callback for setting results 
  % FORMAT [data errf msg] = mars_arm_call('set_results', data);
  % Need to set default data from results, and load contrast file
  % if not present (this is so for old MarsBaR results)
  
  data = varargin{1};
  if isempty(data), return, end
  mars_armoire('set', 'roi_data', data.marsY);
  fprintf('Set ROI data from estimated design...\n');
  if ~is_there(data, 'xCon'),
    tmp = load(spm_get(1, 'x?on.mat',...
		       'Select contrast file')); 
    data.xCon=tmp.xCon;
  end
  res = data;
 otherwise
  error(['Peverse request for ' action]);
end