function [fn,pn,fi] = mars_uifile(action, filter_spec, prompt, filename, varargin)
% wrapper for matlab uiputfile/getfile; to resolve version differences
% FORMAT [fn,pn,fi] = mars_uifile(action, filter_spec, prompt, filename, varargin)
%
% uigetfile and uiputfile in matlab 5.3 does not support the use of multiple
% filters, in the filter_spec array.
% Matlab < 6.5 does not allow the passing of a seperate filename default
% as a third argument. 
% Matlab < 6.5 does not return a third argument (file index)
%
% mars_uifile acts as a wrapper for calls to uiputfile and uigetfile, so
% that 6.5 format calls will be translated to something useful to 5.3,
% 6.1 if 5.3 or 6.1 is running.
%
% $Id$
  
if nargin < 1
  error('Need action');
end
if nargin < 2
  filter_spec = '';
end
if nargin < 3
  prompt = '';
end
if nargin < 4
  filename = '';
end
if isnumeric(filename)
  varargin = [{filename} varargin];
  filename = '';
end
  
mlv = version; mlv = str2num(mlv(1:3));
if mlv < 6.5 
  % If we have a default filename, we cannot use it with the filterspec,
  % so use filename instead of filterspec
  if ~isempty(filename) 
    filter_spec = filename;
  elseif mlv < 6 % only allowed string filterspec
    if iscell(filter_spec)
      filter_spec = filter_spec{1};
    end
    semic = find(filter_spec == ';');
    if ~isempty(semic)
      filter_spec(semic(1):end) = [];
    end
  end
  arglist = {filter_spec, prompt, varargin{:}};
else % (so matlab >= 6.5)
  % It seems that, in the following setup:
  % matlab 7; Java interface; linux; cell array filterspec
  % - all uigetfile filters need to be of form '*.<ext>', where <ext> is
  % the file extension.  This is not so for the one version of matlab 7
  % on windows that I tested (matlab 7.1.0.253 or something).  I'm
  % guessing that other Unices may have the same problem though. 
  if mlv >= 7 & usejava('jvm') & isunix
    for fsn = 1:size(filter_spec, 1)
      [pn fn ext] = fileparts(filter_spec{fsn, 1});
      filter_spec{fsn, 1} = ['*' ext];
    end
  end
    
  if isempty(filename) % matlab 7 does not tolerate empty filenames
    arglist = {filter_spec, prompt, varargin{:}};
  else
    arglist = {filter_spec, prompt, filename, varargin{:}};
  end
end  

fi = [];
switch lower(action)
 case 'get'
  if mlv < 6.5
    [fn pn] = uigetfile(arglist{:});
  else
    [fn pn fi] = uigetfile(arglist{:});
  end
 case 'put'
  if mlv < 6.5
    [fn pn] = uiputfile(arglist{:});
  else
    [fn pn fi] = uiputfile(arglist{:});
  end
 otherwise 
   error(['Strange desire for ' action]);
end