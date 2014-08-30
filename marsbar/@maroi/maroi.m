function [o, others] = maroi(params, varargin)
% maroi - class constructor for umbrella ROI object
% Can be called as a simple contructor:
% inputs [defaults]
% params  - a structure, containing fields to construct the object
%  
% or to load objects of this (or child) type)
% o = maroi('load', fname);
% or
% o = maroi(fname);
% (where fname is a string)
% or
% o_cell_arr = maroi(name_cell_arr);
% (where 
% o_cell_arr is a cell array of ROI objects and
% name_cell_arr is a cell array of filenames)
% or 
% o_cell_arr = maroi('load_cell', fnames)
% to load strings/cell array of strings into cell array of objects
%
% or to access class data
% res = maroi('classdata', p1, p2); (see classdata method)
%
% or to process a filename to be suitable for saving an ROI
% new_fn = maroi('filename', old_fn);
%
% An ROI is a definition of a region in space. As currently implemented,
% an ROI can be of three types:
%
% a shape - a geometric shape defined independent of any image
%           e.g. sphere, box
% a point list - a list of points which are within the region, maybe with
%                associated values (see below)
% a volume - a 3D volume, containing values for the ROI at each point
%           e.g. matrix, image 
%
% Usually, the ROI will be binary; i.e. any point that is within the
% region will have a value of 1, and all points outside have a value of
% 0.  Because regions may be resampled into new image spaces, this
% binaryness needs to be enforced in the resampling; this is done if the
% 'binarize' flag is set for the object; the 'roithresh' field determines
% the value above which a point is considered within the region, after
% resampling.
%
% In addition to defining the region in space, the ROI may also define
% values for the points within the region.  If an ROI defines values then it
% is a 'weighting' ROI (such as 0->1 probability weighting); those ROIs can
% contain different values across the region.  Because of the problem of
% missing values when resampling an ROI (e.g sampling at the edge of a
% volume when using anything other than nearest neighbour resampling),
% weighting ROIs should be zero based, so that a value outside the
% region will be considered to have the value 0 in resampling.  Values of
% NaN and 0 will always be assumed to be outside the region after
% resampling
% 
% At the moment, each ROI is saved as a separate mat file, with filename
% <name>_roi.mat
%
% $Id$
  
% Programmers' notes
%
% maroi is the parent for all ROI objects. It can contain no useful ROI
% itself, but implements functions for all objects of maroi type.  Children
% will generally call this parent constructor with passed arguments.  This
% constructor routine then sets fields contained in the parent maroi object,
% and removes the relevant fields from the passed structure, then returns
% the stripped structure to the caller, so that it can use any extra
% arguments to set child properties, etc
%
% Fields are [defaults - which may well be overidden by children]: 
% source   - filename for roi object ['']
% label    - 16 character label for outputting
% descrip  - (maybe) prolix description of ROI ['']
% history  - string specifying processing done to ROI ['']
% spm_hold - defines resampling method when reslicing ROI into different
%            space (see spm_sample_vol.m) [1]
% binarize - flag to indicate this is a binary ROI.
%            if == 1, The object will always return binary values; this is
%            enforced at object initialization, and during during
%            resampling [1]
%
% roithresh - absolute threshold above which a point is considered within
%            the ROI. With binarize flad set, this value
%            will usually be 0.5 (see defaults set in classdata).  With
%            binarize flag unset, iw will usually be eps. These defaults
%            are set using the classdata variable
%
% Methods that must be defined for a maroi object are
% [pts vals] = voxpts(obj, space)
% [pts vals] = realpts(obj, space)
% timeseries = getdata(obj, images, [flags]);
% mobj = maroi_matrix(obj, [space])
%
% In constructor calls:
% params passed are fields for current object, and for any parents
% (thus there must be no overlap in field names between child and parent
% objects, which in can in any case be confusing).
%
% Matthew Brett 21/9/01 (AR)

myclass = 'maroi';
defstruct = struct(...
    'source','',...
    'label','',...
    'descrip', '',...
    'history','',...
    'spm_hold',  my_classdata('def_hold'),...
    'binarize',1,...
    'roithresh', my_classdata('def_binthresh'));

if nargin < 1
  params = [];
end
if isa(params, myclass)
  o = params;
  return
end

% parse out string action calls (class data, helper functions)
if ischar(params)
  switch params
   case 'classdata'
    o = my_classdata(varargin{:});
   case 'load'
    o = my_loadroi(varargin{1});
   case 'load_cell'
    params = varargin{1};
    if ischar(params), params = cellstr(params); 
    elseif ~iscell(params), params = {params}; end
    o = maroi(params);
   case 'filename'
    o = my_roifname(varargin{:});
   otherwise % single filename
    if size(params, 1) > 1
      error('Use cell form of call to load multiple objects');
    end
    o = my_loadroi(params);
  end
  return
end

% cell array - array of filenames, or objects, or something
if iscell(params)
  sz = size(params);
  o = cell(sz);
  for r = 1:prod(sz)
    o{r} = maroi(params{r});
  end
  return
end

% fill with defaults, parse into fields for this object, children
[pparams, others] = mars_struct('ffillsplit', defstruct, params);

% Check for default thresholds according to binarize flag
if isfield(params, 'binarize') && ~isempty(params.binarize) && ...
      params.binarize == 0 && ( ~isfield(params, 'roithresh') || ...
      isempty(params.roithresh))
  pparams.roithresh = my_classdata('def_wtthresh');
end
  
% add version tag (was CVS; now marsbar version)
pparams.cvs_version = marsbar('ver');

% Set as object
o  = class(pparams, myclass);

return
