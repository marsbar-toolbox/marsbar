function [o, others] = maroi_image(params)
% maroi_image - class constructor
% inputs [defaults]
%  params  - filename, for image defining ROI
%            or spm vol struct (see spm_vol)
%
% This ROI type is a child of the maroi_matrix type.  maroi_image ROIs are
% static, in that they are defined by a particular image, and optionally, a
% function to apply to the image.  If the image changes, so will the ROI.
% However, the ROI will not change the image, so, if any changes are made to
% the ROI, such as flips, setting of the data directly using the matrixdata
% function of maroi_matrix, etc, then the ROI automatically become a
% maroi_matrix type, and is detached from the image.
%
% Note that the image is referenced by an absolute path, so if the path
% to the image changes, loading the ROI will fail.  Reassociate the image
% with an ROI using the vol method.
%
% $Id$
  
myclass = 'maroi_image';
defstruct = struct('vol', [],'func', '');

if nargin < 1
  params = [];
end
if isa(params, myclass)
  o = params;
  return
end

% check for filename;
if ischar(params) 
  params.vol = spm_vol(params);
end
% check for vol struct
if isfield(params, 'fname') 
  params.vol = params;
end

% fill with defaults
pparams = mars_struct('ffillmerge', defstruct, params);

if ~isempty(pparams.vol) % check for attempt at create empty object

  % check and process vol and func
  [img errstr] = my_vol_func(pparams.vol, pparams.func);
  if isempty(img), error(errstr); end
  
  % prepare for maroi_matrix creation
  pparams.dat = img;
  pparams.mat = pparams.vol.mat;

  % fill source information if empty
  if ~isfield(pparams, 'source') | isempty(pparams.source)
    pparams.source = maroi('filename',pparams.vol.fname);
  end
end

% umbrella object, parse out fields for (this object and children)
[uo, pparams] = maroi_matrix(pparams);

% reparse parameters into those for this object, children
[pparams, others] = mars_struct('split', pparams, defstruct);

o = class(pparams, myclass, uo);
return