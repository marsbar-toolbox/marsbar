function [o, others] = maroi_matrix(params, space)
% maroi_matrix - class constructor
% There are two usual forms of the call:
% 1) Constructor call: obj = maroi_matrix(params);
% where input is [defaults]
%  params  - a structure containing any fields for a maroi parent and
%            .dat - a matrix
%            .mat - mapping of matrix indices to mm
%
% 2) Rebase call: obj = maroi_matrix(obj, space)
% where input is [defaults]
%  obj - a maroi_matrix object
%  space - mars_space object defining space to reslice to
%
% This maroi_matrix object is used for conversion between
% different types of rois, and for combining rois
% Much of the work is in the converter routines for other roi objects, to
% return objects of this type
%
% $Id$

myclass = 'maroi_matrix';
defstruct = struct('dat', [],'mat', eye(4));

if nargin < 1
  params = [];
end
if isa(params, myclass)
  o = params;
  if nargin < 2 % simple object return call
    return
  end 
  % Rebase call
  if isempty(space)
    space = native_space(o);
    if isempty(space)
      error('Cannot define default space for object');
    end
  else
    space = mars_space(space);
  end
  
  % check if this in fact the same as object native space
  if space == native_space(o), return, end
  % if not, then rebase 
  params = paramfields(o);
  params.label = [params.label '_rebased']; 
  params.descrip = [params.descrip ': rebased']; 
  params.dat = rebase(o,space,'i');
  params.mat = space.mat;
  o = maroi_matrix(params);
  return
end

% Constructor call

% fill with defaults
pparams = mars_struct('ffillmerge', defstruct, params);

% umbrella object, parse out fields for (this object and children)
[uo, pparams] = maroi(pparams);

% reparse parameters into those for this object, children
[pparams, others] = mars_struct('split', pparams, defstruct);

% bless into object
o = class(pparams, myclass, uo);

% apply implied thresholding
o = matrixdata(o, o.dat);

return