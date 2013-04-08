function varargout = spm_get(Action, varargin)
% compatibility function to allow spm_get calls with SPM5
%
% SPM5 uses a function called spm_select to do file selection instead of
% the spm_get of versions 96-2.  This breaks a lot of old code; here we
% wrap the most common calls to spm_get so that we can use
% spm_select. I've only wrapped the spm_get calls used in marsbar.  
%
% Usually, file / directory selection call is of format:
% FORMAT P = spm_get(N, ext, prompt, newwdir)
% Input
% N        - matrix specifying what (file or dir) to select, and how
%            many to select.
% ext      - the filter for files to select
% prompt   - the prompt to display for the selection window
% newwdir  - new working directory
%
% Output
% P        - a string matrix of file names
%
% First argument can also be action string:
% FORMAT cpath = spm_get('CPath',path,cwd)
% (returns canonical version of file path 'path')
% FORMAT [files,dirs]=spm_select('files',direc,filt)
% (Returns files matching the filter (filt) and directories within dir)
%
% See spm_select from the spm5 distribution, and spm_get from spm2
% distribution

nout = max(nargout,1);

if nargin < 1
  Action=Inf;
end

% If the first argument is a string, this is an action
if ischar(Action)
  switch(lower(Action))
   case 'cpath'
    varargout = {spm_select('cpath', varargin{:})};
   case 'files'
    if nargin < 2
      Dir = pwd;
    else
      Dir = varargin{1};
    end
    if nargin < 3
      Filt = '.*';
    else
      Filt = sf_get_to_select_filt(varargin{2});
    end
    varargout = {spm_select('list', Dir, Filt)};
    % The old spm_get returned full file paths
    Files = varargout{1};
    varargout{1} = [repmat([Dir filesep], size(Files, 1), 1) Files];
   otherwise
    error([Action ': I''m sorry, but I can''t do that']);
  end
  if strcmp(Action, 'files'), Action='List'; end

  return
end

% Otherwise, must be file / directory selection
if nargin < 2
  Filt = 'any';
else
  Filt = varargin{1};
  varargin(1) = [];
  Filt = sf_get_to_select_filt(Filt);
end
if any(Action < 0)
  % Directory select
  Action = abs(Action);
  Filt = 'dir';
end
if nargin<3
  Prompt='Select files...';
else
  Prompt = varargin{1};
  varargin(1) = [];
end
if nargin<4
    wd = pwd;
else
    wd = varargin{1};
    varargin(1) = []; % pop processed argument
end
if length(varargin) ~= 0
    error('Sorry, we do not handle this call to spm_select');
end
varargout = {spm_select(Action, Filt, Prompt, {''}, wd)};
if isempty(varargout), return, end
% Cell array prompt should return cell array of arguments
if iscellstr(Prompt)
  if isempty(varargout{1})
    varargout{1} = {};
  else
    varargout{1} = cellstr(varargout{1});
  end
end
return


% Subfunctions
function F = sf_get_to_select_filt(F)
% Converts filter for old spm_get routine to something for spm_select
if strcmpi(F, 'image'), F = lower(F); return, end
F = sf_shexp_regexp(F);
return

function new_str = sf_shexp_regexp(old_str)
% Does basic conversion from shell expression to regexp
% Have ignored some quoting issues here:
% http://www.unix.org.ua/orelly/perl/cookbook/ch06_10.htm
% sub glob2pat {
%    my $globstr = shift;
%    my %patmap = (
%        '*' => '.*',
%        '?' => '.',
%        '[' => '[',
%        ']' => ']',
%    );
%    $globstr =~ s{(.)} { $patmap{$1} || "\Q$1" }ge;
%    return '^' . $globstr . '$';
%}

new_str = '^';
for c = old_str
  switch c
   case '*'
    nc = '.*';
   case '?'
    nc = '.';
   case {'.', '^', '$', '+'}
    nc = ['\' c]; 
   otherwise
    nc = c;
  end
  new_str = [new_str nc];
end
new_str = [new_str '$'];
return
  
