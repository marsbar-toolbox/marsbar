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
% This constructor first checks for strings; it treats strings as filenames
% containing SPM designs, and loads the file.  By now it should have an SPM
% design structure (passed or loaded). It then labels itself as a mardo
% design, and passes itself to candidate mardo design classes (99 and 2 type
% designs) for these classes to further claim the object.  If the (99 or 2)
% classes claim the object, they return an object of class (99 or 2), which
% inherits the mardo class just created in this call to the object.
% 
% Note the "passf" input flag; this is a trick to allow the other mardo
% classes (99 and 2) to create a mardo object for them to inherit, without
% this constructor passing the mardo object back to the other classes,
% creating an infinite loop.  So, the flag is by default set to 1, and the
% newly created mardo object is passed to the other mardo classes for them
% to claim ownership.  The other mardo classes can call this constructor
% with passf set to 0 in order for the constructor merely to make a mardo
% object, without passing back to the other classes.
% 
% Fields 
% des_struct - structure containing SPM design
% 
% Methods
% is_valid     - returns 1 if des_struct contains a valid design
% is_fmri      - returns 1 if design is modality 'fmri'
% is_marsed    - returns 1 if design has been processed with MarsBaR
% is_mars_estimated - returns 1 if design has Mars estimation data
% is_spm_estimated - returns 1 if design has SPM estimation data  
% modality     - returns one of 'fmri','pet','unknown'
% verbose      - whether reporting is verbose or not (1 or 0)
% type         - returns design version string 'SPM2' or 'SPM99'
% block_rows   - returns cell array, one cell per subject or session,
%                containing indices of design rows for that
%                subject/session
% block_means  - returns means for each block in the design
% n_time_points - number of rows (time points) in design
% n_effects    - number of columns (effects) in design
% ui_report    - display design report and query menu in UI
% ui_report_fmri - design report + inspection tools for FMRI
% 
% savestruct   - saves design structure to file, with fields as variables
% des_struct   - sets or gets design structure
%  
% has_filter   - returns 1 if the design contains a filter, NaN if not known
% apply_filter - applies design filter to data
% ui_get_filter - gets filter and stocks in design
% fill          - fills design with filter, images, or default values
% 
% data          - get/set data in estimated design
% get_data      - get data
% set_data      - set_data
%
% contrasts     - get/set contrasts 
% has_contrasts - returns 1 if the design contains contrasts
% set_contrasts - set contrasts to design
% get_contrasts - returns contrasts if present
% add_contrasts - adds contrasts from a design, xCon struct or passed values
% ui_get_contrasts - runs spm_conman to choose contrasts, returns indices
% 
% has_images   - returns 1 if the design contains images, NaN if not known
% images       - gets / sets images in design
% get_images   - gets image vol structs if present
% set_images   - sets images 
% image_names  - gets image names as cell array 
% cd_images    - changes root directory to design images
% prefix_images - adds, removes prefix from images names (e.g. 's')
% 
% estimate     - estimates design, given data
% compute_contrasts - computes contrasts, returns statistics structure
% stat_table   - return statistic table report and structures for
%                contrasts
% mars_spm_graph - runs graph UI, displays in SPM windows
%
% event_signal - calculates % signal change for (maybe compound) event
% event_fitted - gets fitted time course for (maybe compound) event
% event_regressor - returns regressor for given event type and duration
% ui_get_event - runs UI to select an event
% event_cols   - returns column in design from given event
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
if ischar(params)  % maybe filename
  fname  = deblank(params);
  params = load(fname);
  params.swd = fileparts(fname);
else
  fname = '';
end
if isstruct(params)
  if ~isfield(params, 'des_struct')
    % Appears to be an SPM design
    params = struct('des_struct',params);
  end
end

% fill with defaults, parse into fields for this object, children
[pparams, others] = mars_struct('ffillsplit', defstruct, params);

% add cvs tag
pparams.cvs_version = mars_cvs_version(myclass);

% set the mardo object
o  = class(pparams, myclass);

% If requested, pass to child objects to request ownership
if passf
  o = mardo_99(o, others);
  if strcmp(class(o), myclass)
    o = mardo_2(o, others);
  end
end

% convert data field to object
if isfield(o.des_struct, 'marsY')
  o.des_struct.marsY = marsy(o.des_struct.marsY);
end

% if the design was loaded from a file, and is 99 type
% then it may need contrasts.
% If it wass estimated in MarsBaR, try loading mars_xCon.mat
% in the same directory.
% If it wass estimated in SPM, try loading xCon.mat
% in the same directory.
if ~isempty(fname) & ...
      strcmp(type(o), 'SPM99') & ...
      ~has_contrasts(o)
  [pn fn ext] = fileparts(fname);
  if is_mars_estimated(o)        
    xcon_name = fullfile(pn, 'mars_xCon.mat')
  elseif is_spm_estimated(o) 
    xcon_name = fullfile(pn, 'xCon.mat');
  else
    xcon_name = '';
  end
  if ~isempty(xcon_name)
    if exist(xcon_name, 'file')
      xc = load(xcon_name);
      if isfield(xc, 'xCon')
	o = set_contrasts(o, xc.xCon);
	if verbose(o)
	  disp(['Set contrasts from ' xcon_name]);
	end
      end
    elseif verbose(o)
      disp('Failed to load contrasts');
    end
  end
end

% sort out design image flipping
dt = type(o);
sv = spm('ver');
if ~is_marsed(o) 
  if sf_tf(has_images(o)) & ~strcmp(dt,sv)
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
      'flipped', flip_option(o)));
end

% resolve confusing field name in marsbar <= 0.23
% ResMS was in fact the _Root_ Mean Square
% The statistics routines treated the field correctly
D = o.des_struct;
if isfield(D, 'ResMS')
  if verbose(o)
    msg = {'Compatibility trivia: processed ResMS to ResidualMS'};
    fprintf('\n%s',sprintf('%s\n',msg{:})); 
  end
  D.ResidualMS = D.ResMS .^ 2;
  D = rmfield(D, 'ResMS');
  o.des_struct = D;
end

return

function r = sf_tf(d)
if isnan(d), r = 0;
else
  r = (d~=0);
end
return