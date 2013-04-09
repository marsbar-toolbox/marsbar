function varargout = mars_veropts(arg, varargin)
% returns SPM version specific parameters
% FORMAT varargout = mars_veropts(arg, varargin)
%  
% This is the SPM 5 version
%
% $Id: mars_veropts.m 350 2004-08-12 06:52:18Z matthewbrett $
  
if nargin < 1
  varargout = {};
  return
end

switch lower(arg)
 case 'defaults'
  global defaults
  if isempty(defaults)
      try
        % SPM8 likes to return the defaults
        defaults = spm('defaults','FMRI');
      catch
        % SPM5 does not
        spm_defaults;
        spm('defaults','FMRI');
      end
  end
  varargout = {defaults};
 case 'default_design'
  varargout = {mardo_5};
 case 'template_ext' % extension for template images
  varargout = {'.nii'}; 
 case 'get_img_ext' % default image extension for spm_get
  varargout = {'image'};
 case 'pref_img_out_ext' % preferred extension for writing images
  varargout = {'.nii'}; 
 case 'des_conf'     % filter for configured, not estimated SPM designs
  varargout = {'SPM.mat'};
 case 'flip_option'
  varargout = {spm_flip_analyze_images};
 case 'design_filter_spec' 
  varargout = {{...
    'SPM.mat','SPM.mat; 5,2 (all)/99 (estimated: SPM.mat)';...
    'SPMcfg.mat','99 with imgs: SPMcfg.mat';...
    'SPM_fMRIDesMtx.mat','99,FMRI,no imgs: SPM*fMRI*'}}; 
 otherwise
  error(['You asked for ' arg ', which is strange']);
end
