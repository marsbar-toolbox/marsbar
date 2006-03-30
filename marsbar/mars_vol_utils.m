function varargout=mars_vol_utils(varargin)
% collection of useful utility functions for vol structs
% 
% tf = mars_vol_utils('is_vol', V)
%    Returns 1 if V may be a vol struct (right fields)
%
% [t,le,sw] = mars_vol_utils('type', V)
%    Returns type number for vol struct - see spm_type, spm_vol
%    Second output t = 1 if vol seems to be little-endian
%    Third output sw = 1 if vol swapped relative to this platform
%
% tf = mars_vol_utils('is_swapped', V)
%    Returns 1 if V contains data that has opposite endianness from
%    current platform (as given by spm_platform('bigendian')
%
% ver = mars_vol_utils('ver', V)
%    Returns version string for vol struct
%    '99' if appears to be spm99 format, '5' for spm5
%
% ver = mars_vol_utils('current_ver')
%    Returns '99' if current spm_vols returns 99 vol type, else '5'
%
% tf = mars_vol_utils('is_swapped_wrong', V)
%    Returns 1 if the vol struct V has the different swapping
%    information from a fresh mapping from the same file, and thus might
%    have to be remapped. 
%
% V = mars_vol_utils('byte_swap', V)
%    Returns new vols for opposite byte ordering to current spec
%
% V = mars_vol_utils('convert', V, ver)
%    Return vol struct(s) V converted to type specified in ver
%    If ver not specified, convert to current ver type
% 
% V = mars_vol_utils('def_vol', ver)
%    Return default structure for type ver
%    If ver not specified, use current ver type
%
% $Id: mars_vol_utils.m 581 2005-06-21 15:40:17Z matthewbrett $

nout = max(nargout,1);
varargout = cell(1, nout);
if nargin < 1
  error('Need action');
end
Action = lower(varargin{1});
if nargin > 1
  V = varargin{2};
end

switch(Action)

%=======================================================================
case 'is_vol'             % Returns 1 if this appears to be a vol struct
%=======================================================================
if nargin < 2
  error('Need vol struct to check');
end
varargout = {sf_is_vol(V)};
  
%=======================================================================
case 'type'                                    % Returns vol type number
%=======================================================================
if nargin < 2
  error('Need vol struct to give type');
end
sf_die_no_vol(V);
varargout{:} = sf_type(V);

%=======================================================================
case 'is_swapped' % Returns 1 if vol swapped relative to this platform
%=======================================================================
if nargin < 2
  error('Need vol struct to check swapping');
end
sf_die_no_vol(V);
[t le sw] = sf_type(V);
varargout = {sw};

%=======================================================================
case 'ver'                                    % Returns vol type version
%=======================================================================
if nargin < 2
  error('Need vol struct to give version');
end
sf_die_no_vol(V);
varargout = {sf_ver(V)};

%=======================================================================
case 'current_ver'               % Returns vol type from spm_vol on path 
%=======================================================================
varargout = {sf_current_ver};

%=======================================================================
case 'is_swapped_wrong'    % Returns 1 for if vol is incorrectly swapped
%=======================================================================
if nargin < 2
  error('Need vol struct to test');
end
sf_die_no_vol(V);
V2 = spm_vol(V.fname);
[t le] = sf_type(V);
[t le2] = sf_type(V2);
varargout = {le ~= le2};

%=======================================================================
case 'byte_swap'      % return vols with opposite recorded byte ordering
%=======================================================================
if nargin < 2
  error('Need vol struct to swap');
end
sf_die_no_vol(V);
switch sf_ver(V)
 case '99'
  for i = 1:numel(V)
    if V(i).dim(4) < 256, scf = 256; else scf = 1/256; end
    V(i).dim(4) = V(i).dim(4) * scf;
  end
 case '5'
  for i = 1:numel(V)
    V(i).dt(2) = 1-V(i).dt(2);
  end
 otherwise
  error(['Don''t often see those ' sf_ver(V)]);
end
varargout = {V};

%=======================================================================
case 'convert'              % Returns vols converted to alternative type
%=======================================================================
if nargin < 2
  error('Need vol struct to convert');
end
if ~sf_is_vol(V), varargout={V}; return, end
if nargin < 3
  ver = sf_current_ver;
else
  ver = varargin{3};
  if sf_is_vol(ver), ver = sf_ver(ver); end
end
if sf_same_ver(V, ver)
  varargout = {V};
  return
end
switch sf_ver(V)
 case '99'
  varargout = {sf_99_to_5(V)};
 case '5'
  varargout = {sf_5_to_99(V)};
 otherwise
  error([sf_ver(V) ' is just nuts']);
end
return

%=======================================================================
case 'def_vol'                % Returns default vol struct of given type
%=======================================================================
if nargin < 2
  ver = sf_current_ver;
else
  ver = varargin{2};
  if sf_is_vol(ver), ver = sf_ver(ver); end
end
switch ver
 case '99'
  varargout = {sf_def_vol_99};
 case '5'
  varargout = {sf_def_vol_5};
 otherwise
  error([ver ' is unacceptable']);
end
return 
 
otherwise
  error([Action 'is beyond my range']);
end
return

% Subfunctions

function tf = sf_is_vol(V)
% returns 1 if this may be a vol struct
tf = 0;
if ~isstruct(V), return, end
if ~isfield(V, 'dim'), return, end
tf = 1;
return

function sf_die_no_vol(V)
if ~sf_is_vol(V)
  error('I really wanted a vol struct here');
end
return

function [t, le, sw] = sf_type(V)
% returns type number, little-endian flag, swapped flag
plat_le = not(spm_platform('bigend'));
V = V(1);
if sf_same_ver(V, '5') % spm5 vol type
  t = V.dt(1); 
  le = V.dt(2);
  sw = xor(le, plat_le);
elseif length(V.dim) > 3 % spm99 style type specifier
  t = V.dim(4);
  sw = (t > 256);
  if sw, t = t/256; end
  le = xor(plat_le, sw);
else
  error('Could not get vol type');
end
return

function ver = sf_ver(V)
% returns version string ('99' or '5')
if isfield(V, 'dt')
  ver = '5';
else
  ver = '99';
end
return

function ver = sf_current_ver;
% returns version for spm_vol on path
% spm2,99 spm_vol do not accept no args
try
  V = spm_vol;
  ver = sf_ver(V);
catch
  ver = '99';
end
return

function V = sf_def_vol_99;
V = struct(...
    'fname', '',...
    'dim', [], ...
    'pinfo', [], ...
    'mat', [], ...
    'n', [], ...
    'descrip', '');
return

function V = sf_def_vol_5;
V = struct('fname', '',...
	   'dim',   [],...
	   'dt',    [],...
	   'pinfo', [],...
	   'mat',   [],...
	   'n',     [],...
	   'descrip', '',...
	   'private',[]);
return

function Vo = sf_99_to_5(Vi)
% converts spm99 vols to spm5 vols
d = sf_def_vol_5;
Vo = d; % in case Vi is empty
is_n = isfield(Vi, 'n');
for i = 1:numel(Vi)
  OV = Vi(i);
  NV = d;
  [t le] = sf_type(OV);
  NV.fname = OV.fname;
  NV.dim = OV.dim(1:3);
  NV.dt = [t le];
  NV.mat = OV.mat;
  NV.pinfo = OV.pinfo;
  NV.descrip = OV.descrip;
  if is_n, NV.n = [OV.n 1]; end
  Vo(i) = NV;
end
Vo = reshape(Vo, size(Vi));
return

function Vo = sf_5_to_99(Vi)
% converts spm5 vols to spm99 vols
d = sf_def_vol_99;
Vo = d; % in case Vi is empty
for i = 1:numel(Vi)
  OV = Vi(i);
  NV = d;
  [t le sw] = sf_type(OV);
  if sw, t = t * 256; end
  NV.fname = OV.fname;
  NV.dim = [OV.dim(1:3) t];
  NV.mat = OV.mat;
  NV.pinfo = OV.pinfo;
  NV.descrip = OV.descrip;
  NV.n = OV.n(1);
  Vo(i) = NV;
end
Vo = reshape(Vo, size(Vi));
return

function tf = sf_same_ver(V, ver)
tf = strcmp(sf_ver(V), ver);
return