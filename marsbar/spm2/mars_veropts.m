function varargout = mars_veropts(arg, varargin)
% returns SPM version specific parameters
% FORMAT varargout = mars_veropts(arg, varargin)
%  
% This the SPM 2 version
%
% $Id$
  
if nargin < 1
  varargout = {};
  return
end

switch lower(arg)
 case 'template_ext' % extension for template images
  varargout = {'.mnc'}; 
 case 'get_img_ext' % default image extension for spm_get
  varargout = {'IMAGE'};
 case 'des_conf'     % filter for configured, not estimated SPM designs
  varargout = {'SPM.mat'};
 case 'stat_buttons' 
  varargout = {{'PET', 'fMRI', 'Basic models'...
	 'Review design', '-> Bayesian', 'Estimate', 'Results'}};
 case 'flip_option'
  varargout = {spm_flip_analyze_images};
 otherwise
  error(['You asked for ' arg ', which is strange']);
end
