function [o, others] = mars_space(params, params2)
% mars_space - class constructor for space defining object
% FORMAT [o, others] = mars_space(params, params2)
% Inputs [defaults]
% params  - either 
%           a structure, containing fields to construct the object
%           an spm vol struct (see spm_vol)
%           a string, giving and image name (see spm_vol)
%           a matrix (for which, only the dimensions are used)
%           a 3x1 or 1x3 dimension vector
% params2   in the latter 2 cases, might contain a 4x4 transformation matrix
%           [eye(4)]
%
% $Id$
  
myclass = 'mars_space';
defstruct = struct('dim', [1 1 1],...
		   'mat', eye(4));

if nargin < 1
  params = [];
end
if nargin < 2
  params2 = [];
end
if isa(params, myclass)
  o = params;
  return
end

% check inputs
if ~isstruct(params)
  % Matlab 7 does not like assigment of struct to non empty var
  inp1 = params;
  clear params;
  if ischar(inp1) % maybe it is an image filename
    params = spm_vol(inp1);
    params.dim = params.dim(1:3);
  elseif prod(size(inp1)) == 3 
    % could be the dimensions of a space
    params.dim = inp1(:)';
    if ~isempty(params2), params.mat = params2; end
  else						       
    % lets hope it's a useful matrix, but with a mat parameter, quoi
    if isempty(params2)
      error(['Need to pass a ''mat'' definition with a'...
	     ' matrix'])
    end
    params.mat = params2;
    m = inp1;
    sz = size(m);
    params.dim = [1 1 1];
    params.dim(1:length(sz)) = sz;
  end
end

% fill with defaults, parse into fields for this object, children
[pparams, others] = mars_struct('ffillsplit', defstruct, params);

o  = class(pparams, myclass);
return