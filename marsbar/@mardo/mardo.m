function [o, others] = mardo(params,passf)
% mardo - class constructor for MarsBaR design object
% inputs [defaults]
% params  - structure, either:
%             containing SPM/MarsBaR design or
%             containing fields for mardo object, which should include
%             'des_struct', containing design structure
% passf   - if 1, or not passed, will try children objects to see if
%           they would like to own this design
%
% outputs
% o       - mardo object
% others  - any unrecognized fields from params, for processing by
%           children
%
% mardo is a simple object to contain SPM designs. It allows us to
% deal with different design formats by overloading functions in 
% child objects, here for harmonizing between SPM2 and SPM99 designs
% 
% Fields 
% des_struct - structure containing SPM design
% 
% Methods
% is_valid_design - returns 1 if des_struct contains a valid design
% has_images   - returns 1 if the design contains images
% has_filter   - returns 1 if the design contains a filter
% modality     - returns 'FMRI' for an FMRI design, else 'PET'
% verbose      - whether reporting is verbose or not
% design_type  - returns SPM version string corresponding to design type
% is_marsed    - returns 1 if design has been processed with MarsBaR
% is_spm_estimated - returns 1 if design has SPM estimation data
% is_mars_estimated - returns 1 if design has Mars estimation data
% 
% strip_spm_estimation - returns object without SPM estimation data
%
% $Id$
  
myclass = 'mardo';
defstruct = struct('des_struct', [],...
		   'flip_option', 0,...
		   'verbose', 1);

if nargin < 1
  params = [];
end
if nargin < 2
  passf = 1;
end
if isa(params, myclass)
  o = params;
  return
end

% check inputs
if isstruct(params)
  if ~isfield(params, 'des_struct')
    % Appears to be an SPM design
    params.des_struct = params;
  end
end

% fill with defaults, parse into fields for this object, children
[pparams, others] = mars_struct('ffillsplit', defstruct, params);

% set the mardo object
o  = class(pparams, myclass);

% If requested, pass to child objects to request ownership
if passf
  o = mardo_99(o, others);
  o = mardo_2(o, others);
end

% sort out design image flipping
dt = design_type(o);
sv = spm('ver');
if ~is_marsed(o) 
  if has_images(o) & ~strcmp(dt,sv)
    flippo = flip_option(o);
    switch flippo
     case 1
      o = flip_images(o);
      add_str = '';
     case 0
      add_str = 'not ';
     otherwise
      error(['Do not recognize flip option ' flippo]);
    end
    if verbose(o)
      fprintf([...
	'This a design from %s, but you are currently using %s\n',...
	'Data may be extracted from different sides in X (L/R)\n',...
	'when using this design with %s compared to %s.\n',...
	'NB MarsBaR has %sflipped the images for this design\n'],...
		  dt, sv, dt, sv, add_str);
    end
  end % has_images, design/running SPM version differ
  % Add Mars tag 
  o = mars_tag(o, struct(...
      'ver', marsbar('ver'),...
      'flipped', flip_option(o)));
end

% resolve confusing field name in marsbar <= 0.23
% ResMS was in fact the Root Mean Square
D = o.des_struct;
d_chgf = 0;
if isfield(D, 'ResMS')
  if verbose(o)
    disp(['Squaring root mean square in ResMS field' ...
	 ' and moving to ResidualMS']);
  end
  D.ResidualMS = D.ResMS .^ 2;
  D = rmfield(D, 'ResMS');
  d_chgf = 1;
end

% Nasty little hack to make spm_conman compatible between SPM 99 and 2
if isfield(D, 'xX') % allow empty structure
  if isfield(D.xX, 'name')
    D.xX.Xnames = D.xX.name;
    d_chgf = 1;
  elseif isfield(D.xX, 'Xnamea')
    D.xX.name = D.xX.Xnames;
    d_chgf = 1;
  end
end

if d_chgf
  o.des_struct = D;
end

return