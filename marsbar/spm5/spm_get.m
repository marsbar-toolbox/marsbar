function varargout = spm_get(Action, varargin)
% compatibility function to allow spm_get calls with SPM5
%
% SPM5 uses a function called spm_select to do file selection instead of
% the spm_get of versions 96-2.  This breaks a lot of old code; here we
% wrap the most common calls to spm_get so that we can use
% spm_select. I've only wrapped the spm_get calls used in marsbar.  
%
% Usually, file / directory selection call is of format:
% FORMAT P = spm_get(N, ext, prompt)
% Input
% N        - matrix specifying what (file or dir) to select, and how
%            many to select.
% ext      - the filter for files to select
% prompt   - the prompt to display for the selection window
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
%
% $Id$

allowed_actions = {'cpath', 'files'};

if nargin < 1
  Action=Inf;
end

% If the first argument is a string, this is an action
if ischar(Action)
  Action = lower(Action);
  if ~ismember(Action, allowed_actions)
    error([Action ': I''m sorry, but I can''t do that']);
  end
  if strcmp(Action, 'files'), Action='List'; end
  varargout{:} = spm_select(Action, varargin{:});
  return
end

% Otherwise, must be file / directory selection
if nargin < 2
  filter = 'any';
else
  Filter = varargin{1};
  varargin(1) = [];
  Filter = sf_shexp_regexp(Filter);
end
if any(Action < 0)
  % Directory select
  Action = abs(Action);
  Filter = 'dir';
end
Filter
varargout{:} = spm_select(Action, Filter, varargin{:});
return


% Subfunctions
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
  
