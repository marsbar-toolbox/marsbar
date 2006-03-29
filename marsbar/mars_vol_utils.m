function varargout=mars_vol_utils(varargin)
% collection of useful utility functions for vol structs
% 
% tf = mars_vol_utils('is_vol', V)
%    Returns 1 if V may be a vol struct (right fields)
%
% tf = mars_vol_utils('type', V)
%    Returns type number for vol struct - see spm_type, spm_vol
%    Does this correctly for SPM5 and SPM99 vol structs
%
% tf = mars_vol_utils('ver', V)
%    Returns version string for vol struct
%    '99' if appears to be spm99 format, '5' for spm5
%
% tf = mars_vol_utils('is_swapped_wrong', V)
%    Returns 1 if the vol struct V has the incorrect swapping
%    information, and therefore should be remapped.
%
% $Id: mars_vol_utils.m 581 2005-06-21 15:40:17Z matthewbrett $

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
varargout = {sf_type(V)};

%=======================================================================
case 'ver'                                    % Returns vol type version
%=======================================================================
if nargin < 2
  error('Need vol struct to give version');
end
sf_die_no_vol(V);
varargout = {sf_ver(V)};

%=======================================================================
case 'is_swapped_wrong'    % Returns 1 for if vol is incorrectly swapped
%=======================================================================
if nargin < 2
  error('Need vol struct to test');
end
sf_die_no_vol(V);
V2 = spm_vol(V.fname); % wait - what if this is another version?
varargout = {sf_type(V2) ~= sf_type(V)};

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

function T = sf_type(V)
% returns type number for vol
if sf_same_ver(V, '5') % spm5 vol type
  T = V.dt; 
elseif length(V.dim) > 3 % spm99 style type specifier
  T = V.dim(4);
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

function tf = sf_same_ver(V, ver)
tf = strcmp(sf_ver(V), ver);
return