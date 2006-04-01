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
 case 'defaults'
  varargout = {};
 case 'default_design'
  varargout = {mardo_99};
 case 'template_ext' % extension for template images
  varargout = {'.img'};
 case 'get_img_ext'  % default image extension for spm_get
  varargout = {'img'}; 
 case 'pref_img_out_ext' % preferred extension for writing images
  varargout = {'img'}; 
 case 'des_conf'     % filter for configured, not estimated SPM designs
  varargout = {'SPMcfg.mat'};
 case 'flip_option'
  varargout = {0};
 case 'design_filter_spec' 
  varargout = {{...
    'SPMcfg.mat','99 with imgs: SPMcfg.mat';...
    'SPM.mat','SPM.mat; 2(all)/99 (estimated: SPM.mat)';...
    'SPM_fMRIDesMtx.mat','99,FMRI,no imgs: SPM*fMRI*'}}; 
 otherwise
  error(['You asked for ' arg ', which is strange']);
end