function cdata = my_classdata(fieldname, value)
% my_classdata method - sets/gets class data
% maroi class data is implemented with a persistent variable
% CLASSDATA  This is a structure containing fields
%
% spacebase  - space in which to do ROI combination 
% fileend    - filename end with extension for ROI files
% def_binthresh - default roithresh for binarize ROIs
% def_wtthresh  - default roithresh for non-binarize ROIs
%
% Field values can be returned with the call
%    maroi('classdata') - which returns the whole structure
% or maroi('classdata', fieldname) - which returns field data
%
% Field values can be set with the call
% maroi('classdata', fieldname, value) OR
% maroi('classdata', struct) where struct contains fields matching those
% in CLASSDATA
%
% The same functionality results from 
% classdata(maroi_obj, fieldname) etc.
%
% Matthew Brett 1/8/01 (MRD+)
%
% $Id$

persistent CLASSDATA
if isempty(CLASSDATA)
  % default space is that of the SPM templates
  t1mat = [2     0     0   -92; ...
	   0     2     0  -128; ... 
	   0     0     2   -74; ...
	   0     0     0     1];
  CLASSDATA = struct(...
      'spacebase', mars_space([91 109 91],  t1mat), ...
      'fileend','_roi.mat',...
      'def_hold', 1,...
      'def_binthresh', 0.5,...
      'def_wtthresh', eps);

end

if nargin < 1 % simple classdata call
  cdata = CLASSDATA;
  return
end
if nargin < 2 && ~isstruct(fieldname) % fieldname get call
  if isfield(CLASSDATA, fieldname) 
    cdata = getfield(CLASSDATA,fieldname);
  else 
    cdata = []; 
  end
  return
end

% some sort of set call
if ~isstruct(fieldname) 
  fieldname = struct(struct(fieldname, value));
end
for field = fieldnames(fieldname)
  if isfield(CLASSDATA, field{1})
    CLASSDATA = setfield(CLASSDATA, field{1},...
				    getfield(fieldname, field{1}));
  end
end
cdata = CLASSDATA;
