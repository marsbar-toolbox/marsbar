function varargout=mars_utils(varargin)
% collection of useful utility functions for marsbar 
% 
% fname = mars_utils('str2fname', str)
%    accepts string, attempts return of string for valid filename
%    The passed string should be without path or extension
%
% tf = mars_utils('is_valid_varname', str)
%    accepts string, tests if it is a valid variable name
%    returns 1 for yes.
%
% P = mars_utils('get_img_name', fname, flags);
%    gets name of image, if image exists, checks for overwrite  
%    returns filename, or empty string if overwrite not wanted
%
% XYZ = mars_utils('e2xyz', els, dims);
%    takes element numbers in an image (e.g. find(img>5)) and the
%    dimensions of the image [X Y Z] and returns the 3xN voxel
%    coordinates corresponding to the N elements
%
% $Id$

if nargin < 1
  error('Need action');
end

switch(lower(varargin{1}))
  
%=======================================================================
case 'str2fname'                                   %-string to file name
%=======================================================================
if nargin < 2
  error('Need to specify string');
end
str = varargin{2};
% forbidden chars in file name
badchars = unique([filesep '/\ :;.''"~*?<>|&']);

tmp = find(ismember(str, badchars));   
if ~isempty(tmp)
  str(tmp) = '_';
  dt = diff(tmp);
  if ~isempty(dt)
    str(tmp(dt==1))=[];
  end
end
varargout={str};
 
%=======================================================================
case 'is_valid_varname'        %- tests if string is valid variable name
%=======================================================================
if nargin < 2
  error('Need to specify string');
end
str = varargin{2};
try 
  eval([str '= [];']);
  varargout={1};
catch
  varargout = {0};
end

%=======================================================================
case 'get_img_name'          %-gets name of image, checks for overwrite
%=======================================================================
if nargin < 2
  fname = '';
else
  fname = varargin{2};
end
if nargin < 3
  flags = '';
else 
  flags = varargin{3};
end
if isempty(flags)
  flags = 'k';
end

varargout = {''};
fdir = spm_get(-1, '', 'Directory to save image');
fname = spm_input('Image filename', '+1', 's', fname);
if isempty(fname), return, end

% set img extension and make absolute path
[pn fn ext] = fileparts(fname);
fname = fullfile(fdir, [fn '.img']);
fname = spm_get('cpath', fname);

if any(flags == 'k') & exist(fname, 'file')
  if ~spm_input(['Overwrite ' fn], '+1', ...
		'b','Yes|No',[1 0], 1)
    return
  end
end
varargout = {fname};

%=======================================================================
case 'e2xyz'         %-returns XYZ voxel coordinates for element numbers
%=======================================================================
if nargin < 2
  error('Need element numbers');
end
if nargin < 3
  error('Need image dimensions');
end
els = varargin{2};
dim = varargin{3};
if size(els, 2) == 1, els = els'; end
nz = els-1;
pl_sz = dim(1)*dim(2);
Z = floor(nz / pl_sz);
nz = nz - Z*pl_sz;
Y = floor(nz / dim(1));
X = nz - Y*dim(1);
XYZ = [X; Y; Z] +1;
varargout = {XYZ};
return

otherwise
  error('Beyond my range');
end