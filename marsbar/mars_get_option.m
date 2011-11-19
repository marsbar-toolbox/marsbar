function optval = mars_get_option(varargin)
% Get option subfield as named by ``varargin``.
%
% FORMAT optval = mars_get_option(varargin)
%
% Tries to get base default if option is not set.  Returns empty matrix if
% there is no information for this option (for example, if the option fields
% were mis-spelled).
mars = mars_struct('getifthere', spm('getglobal','MARS'), 'OPTIONS');
if isempty(mars)
  mars = mars_options('basedefaults');
end
optval = mars_struct('getifthere', mars, varargin{:});
