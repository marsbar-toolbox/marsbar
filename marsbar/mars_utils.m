function varargout=mars_utils(varargin)
% collection of useful utility functions for MarsBaR etc
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
% absf = mars_utils('isabspath', path);
%    Takes path name, and returns flag, 1 if path is absolute on this
%    system, 0 if relative or empty
% 
% mars_utils('graphic_text', strs, [title_str, [, figure_str]])
%    Displays cell array of text (strs) in SPM graphics window 
%    with optional title (char) title_string.  Can also set to display to
%    other figure window (string or figure handle).
%
% mars_utils('spm_version', [check_global])
%    Gets SPM version string.  Robust version to allow there to be
%    versions of the spm.m file to not have Contents.m files in the same
%    directory.  If optional flag check_global is zero, does _not_ check
%    global SPM_VER variable for version, and tries to get directly from
%    spm.m / Contents.m pairs.
% 
% tf = mars_utils('is_swapped_wrong', V)
%    Deprecated - see version in mars_vol_utils
%
% tf = mars_utils('version_less_than', v1, v2)
%    Returns 1 if version v1 is lower than version v2.
%    Versions can be numbers.  If strings, versions can contain more than
%    one '.' character. For example, '0.38.1' is less than '0.39', or
%    '0.38.2'
%
% $Id$

if nargin < 1
  error('Need action');
end
Action = lower(varargin{1});

switch(Action)
  
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
out_ext = mars_veropts('pref_img_out_ext');
fname = fullfile(fdir, [fn out_ext]);
fname = spm_get('cpath', fname);

if any(flags == 'k') && exist(fname, 'file')
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

%=======================================================================
case 'isabspath' % Returns 1 for absolute path, 0 if relative (or empty)
%=======================================================================
if nargin < 2
  error('Need path to test');
end
pn = varargin{2};
switch (spm_platform('filesys'))
 case 'unx'
  if (~isempty(pn) && pn(1)=='/'), absf=1; else, absf=0; end
 case 'win'
  if (length(pn)>1 && pn(2)==':'), absf=1; else, absf=0; end
 otherwise
  error('isabspath not coded for this filesystem');
end
varargout = {absf};

%=======================================================================
case 'graphic_text'                 % Displays text in SPM figure window
%=======================================================================
if nargin < 2, error('Need text to show'); else S = varargin{2}; end
if ischar(S), S = cellstr(S); end
if nargin < 3, TTitle = ''; else TTitle = varargin{3}; end
if nargin < 4, F = []; else, F=varargin{4}; end
if isempty(F), F='Graphics'; end
if ischar(F), F = spm_figure('GetWin', F); end
if isempty(F), F = spm_figure('GetWin', 'Graphics'); end

FS = spm('FontSizes');
PF = spm_platform('fonts');

spm_figure('clear', F);
figure(F);
hAxes = axes('Position',[0.028,0.05,0.85,0.85],...
		'DefaultTextInterpreter','none',...
		'Units','Points','Visible','off');
AxPos = get(hAxes,'Position'); set(hAxes,'YLim',[0,AxPos(4)])

dy = FS(10)*1.2; y0 = floor(AxPos(4)) -dy; y  = y0;

text(-0.03,y0,TTitle,'FontSize',FS(14),'FontWeight','bold');
y     = y0 - FS(14);

%-Loop over lines of text
%------------------------
for i = 1:prod(size(S))
  d = S{i};
  
  %-For some reason, '|' characters cause a CR.
  d = strrep(d,'|','I');
  h = text(0,y,d,'FontName',PF.courier,'FontSize',FS(10));
  y = y - dy;
end
 
%=======================================================================
case 'spm_version'                   % Robust get for SPM version string
%=======================================================================
% The problem we are trying to solve here is how to take account of the
% unusual situation of the spm.m file _not_ being in the same directory
% as the Contents.m file.  SPM8 raises an error, SPM5 and probably
% previous just returns 'SPM'.  We raise an error always.

try
    ver = spm('ver');
catch
    err = lasterr;
    if strcmp('Undefined', err(1:length('Undefined')))
        error('Marsbar needs SPM on the matlab path')
    end
    error(lasterr)
end
% If version find failed, for SPM5, routine returns 'SPM'
str = ['Can''t obtain SPM Revision information. Is spm.m in the same' ...
       ' directory as Contents.m?'];
if strcmp(ver, 'SPM')
    error(str)
end
varargout = {ver};

%=======================================================================
case 'is_swapped_wrong'    % Returns 1 for if vol is incorrectly swapped
%=======================================================================
warning(...
    sprintf(['mars_utils version of ''is_swapped_wrong'' deprecated\n',...
	     'Please use same function in mars_vol_utils']));
varargout = {mars_vol_utils(varargin{:})};

%=======================================================================
case 'version_less_than' % Returns 1 for if first version less than last
%=======================================================================

if nargin < 3
  error('Need two version strings to compare');
end
varargout{1} = sf_ver_lt(varargin{2:3});

otherwise
  error([Action ' is too strange']);
end
return

% Subfunctions

function tf = sf_ver_lt(v1, v2)
% Returns 1 if version string v1 is lower than v2
vs = {v1, v2};
for v = 1:2
  ns = vs{v};
  if ~ischar(ns), ns = num2str(ns); end
  ns = sf_str_to_nums(ns); 
  cmp_mat(v, 1:length(ns)) = ns;
end
dp = diff(cmp_mat) * -1;
for i = 1:length(dp)
  if dp(i)<0, tf = 1; return, end
  if dp(i)>0, tf = 0; return, end 
end
tf = 0;
return

function ns = sf_str_to_nums(str)
str = str(ismember(str, '0123456789.'));
str = ['.' str '.'];
ps = find(str == '.');
ns = [];
for p = 2:length(ps)
  s = str(ps(p-1)+1:ps(p)-1);
  ns = [ns str2num(s)];
end
return
