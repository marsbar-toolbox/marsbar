function [o, others] = maroi_image(params)
% maroi_image - class constructor
% inputs [defaults]
%  params  - filename ending in .img, defining ROI
%            or spm vol struct (see spm_vol)
%
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
pparams = maroi('fillmerge', defstruct, params);

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
[pparams, others] = maroi('split', pparams, defstruct);

o = class(pparams, myclass, uo);
return