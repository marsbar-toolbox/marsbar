function [o, others] = maroi_pointlist(params, type)
% maroi_pointlist - class constructor
% FORMAT [o, others] = maroi_pointlist(params, type)
% Inputs [defaults]
%  params  - one of
%            structure containing fields XYZ, mat
%
%  type    - one of 'vox', 'real' or 'mm' ['real']
%            ('mm' is the same as 'real')
%            specifies if XYZ matrix is in real (mm) or voxel space
%
% $Id$
  
myclass = 'maroi_pointlist';
defstruct = struct('XYZ', [],...
		   'mat', eye(4),...
         'vals',[],...
         'voxblock',[]);

if nargin < 1
  params = [];
end
if nargin < 2
  type = 'real';  
end
if isa(params, myclass)
  o = params;
  return
end

% fill with defaults
pparams = mars_struct('ffillmerge', defstruct, params);

% umbrella object, parse out fields for (this object and children)
[uo, pparams] = maroi(pparams);

% reparse parameters into those for this object, children
[pparams, others] = mars_struct('split', pparams, defstruct);

% return if no points passed
if isempty(pparams.XYZ)
  o = class(pparams, myclass, uo);
  return
end

% reset points vector if wrong size
if size(pparams.XYZ, 1) == 1
  pparams.XYZ = pparams.XYZ';
end

if strcmp(type, 'real') | strcmp(type, 'mm') 
  % point list is in real space -> convert
  pparams.XYZ = inv(pparams.mat) * ...
      [pparams.XYZ; ones(1, size(pparams.XYZ,2))];
  pparams.XYZ = pparams.XYZ(1:3,:);
end

% check that the points are in a sensible voxel space
tiny = 0.001; % tolerance for non-integer voxel values
if any(any((abs(pparams.XYZ - round(pparams.XYZ))) > tiny))
  error(['Non integer points in voxel space - ' ...
	 'are points really of type ''' type '''?']);
end
pparams.XYZ = round(pparams.XYZ);

% make temporary voxel block for further resampling etc
pparams.voxblock = my_voxblock(pparams.XYZ, pparams.mat, pparams.vals);

% apply implied thresholding
if ~isempty(pparams.vals)
  tmp = find(~isnan(pparams.vals) & ...
	     abs(pparams.vals) >= roithresh(uo));
  pparams.XYZ = pparams.XYZ(:, tmp);
  if binarize(uo)
    pparams.vals = [];
  else
    pparams.vals = pparams.vals(tmp);
  end
end

% make object
o = class(pparams, myclass, uo);
return