function varargout = mars_veropts(arg, varargin)
% returns SPM version specific parameters
% FORMAT varargout = mars_veropts(arg, varargin)
%  
% This the SPM 99 version
%
% $Id$
  
if nargin < 1
  varargout = {};
  return
end

switch lower(arg)
 case 'template_ext' % extension for template images
  varargout = {'.img'};
 case 'get_img_ext'  % default image extension for spm_get
  varargout = {'img'}; 
 case 'des_conf'     % filter for configured, not estimated SPM designs
  varargout = {'SPMcfg.mat'};
 case 'stat_buttons'
  varargout = {{'PET/SPECT models', 'fMRI models','Basic models'...
	 'Explore design', 'Estimate', 'Results'}};
 otherwise
  error(['You asked for ' arg ', which is strange']);
end