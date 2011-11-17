function [o, others] = mardo_5(params, others, varargin)
% class constructor for SPM5 MarsBaR design object
% FORMAT [o, others] = mardo_5(params, others, varargin)
% Inputs
% params  - structure,containing fields, or SPM/MarsBaR design
% others  - structure, containing other fields to define
%
% Outputs
% o       - mardo_5 object (unless disowned)
% others  - any unrecognized fields from params, for processing by
%           children
%
% This object is called from the mardo object contructor
% with a mardo object as input.  mardo_5 checks to see
% if the contained design is an SPM5 design, returns
% the object unchanged if not.  If it is an SPM5
% design, it claims ownership of the passed object.
%
% The constructor can also be called to give class functions, where the
% name of the class function is a character string which is one of:
%    'spm_filter' - applies spm_filter routine to passed args
% 
% $Id: mardo_5.m 607 2006-03-30 20:54:55Z matthewbrett $

myclass = 'mardo_5';
cvs_v   = marsbar('ver'); % was CVS version; now marsbar version

% Default object structure
defstruct = [];

if nargin < 1
  defstruct.cvs_version = cvs_v;
  o = class(defstruct, myclass, mardo_2);
  others = [];
  return
end
if nargin < 2
  others = [];
end

% parse out string action calls (class functions)
if ischar(params)
  switch params
   case 'spm_filter'
    if nargin < 2
      error('Need filter');
    elseif nargin < 3
      o = pr_spm_filter(others);
    else
      o = pr_spm_filter(others, varargin{1});
    end
    return
  otherwise
    error(sprintf('Is "%s" a filename? Use ``mardo`` to load from files',...
            params));
  end
end
    
% Deal with passed objects of this (or child) class
if isa(params, myclass)
  o = params;
  % Check for simple form of call
  if isempty(others), return, end

  % Otherwise, we are being asked to set fields of object
  % (Moot at the moment, as there are no fields specific for this object)
  [p others] = mars_struct('split', others, defstruct);
  return
end

% normal call is via mardo constructor
if isa(params, 'mardo')
  % Check to see if this is a suitable design, return if not
  des = des_struct(params);
  if ~my_design(des), o = params; return, end
  % own, by making mardo_2 object for design
  [uo others] = mardo_2(params, others, 1);
  params = [];
else
  uo = [];
end

if ~isa(uo, 'mardo') % mardo object not passed
  % umbrella object, parse out fields for (this object and children)
  % third argument of 0 prevents recursive call back to here
  [uo, params] = mardo_2(params, others, 0);
else
  % fill params with other parameters
  params = mars_struct('ffillmerge', params, others);
end  

% parse parameters into those for this object, children
[params, others] = mars_struct('ffillsplit', defstruct, params);

% add cvs tag
params.cvs_version = cvs_v;

% set the mardo object
o  = class(params, myclass, uo);

% convert vols to current format
o = convert_vols(o);

return
