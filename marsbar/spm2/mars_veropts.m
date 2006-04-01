function varargout = mars_veropts(arg, varargin)
% returns SPM version specific parameters
% FORMAT varargout = mars_veropts(arg, varargin)
%  
% This is the SPM 2 version
%
% $Id$
  
if nargin < 1
  varargout = {};
  return
end

switch lower(arg)
 case 'defaults'
  global defaults
  if isempty(defaults)
    spm_defaults;
    spm('defaults','FMRI');
  end
  varargout = {defaults};
 case 'default_design'
  varargout = {mardo_2};
 case 'template_ext' % extension for template images
  varargout = {'.mnc'}; 
 case 'get_img_ext' % default image extension for spm_get
  varargout = {'IMAGE'};
 case 'pref_img_out_ext' % preferred extension for writing images
  varargout = {'img'}; 
 case 'des_conf'     % filter for configured, not estimated SPM designs
  varargout = {'SPM.mat'};
 case 'flip_option'
  varargout = {spm_flip_analyze_images};
 case 'design_filter_spec' 
  varargout = {{...
    'SPM.mat','SPM.mat; 2(all)/99 (estimated: SPM.mat)';...
    'SPMcfg.mat','99 with imgs: SPMcfg.mat';...
    'SPM_fMRIDesMtx.mat','99,FMRI,no imgs: SPM*fMRI*'}}; 
 otherwise
  error(['You asked for ' arg ', which is strange']);
end
