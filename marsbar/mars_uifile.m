function [fn,pn,fi] = mars_uifile(action, filter_spec, prompt, filename, varargin)
% wrapper for matlab uiputfile/getfile; to resolve version differences
% FORMAT [fn,pn,fi] = mars_uifile(action, filter_spec, prompt, filename, varargin)
%
% uigetfile and uiputfile in matlab 5.3 does not support the use of multiple
% filters, nor the passing of a seperate filename default as third argument.
% mars_uifile acts as a wrapper for calls to uiputfile and uigetfile, so
% that 6.5 format calls will be translated to something useful to 5.3 if 5.3
% is running.
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
if mlv < 6
  if ~isempty(filename)
    filter_spec = filename;
  else
    if iscell(filter_spec)
      filter_spec = filter_spec{1};
    end
    semic = find(filter_spec == ';');
    if ~isempty(semic)
      filter_spec(semic(1):end) = [];
    end
  end
  arglist = {filter_spec, prompt, varargin{:}};
else
  arglist = {filter_spec, prompt, filename, varargin{:}};
end  

switch lower(action)
 case 'get'
  [fn pn fi] = uigetfile(arglist{:});
 case 'put'
  [fn pn fi] = uiputfile(arglist{:});
 otherwise 
   error(['Strange desire for ' action]);
end