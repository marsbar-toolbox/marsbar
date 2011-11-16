function optval = mars_get_option(varargin)
% FORMAT optval = mars_get_option(varargin)
% Get option subfield as named by ``varargin``.
% Gets base default if not option not set for some reason
mars = mars_struct('getifthere', spm('getglobal','MARS'), 'OPTIONS');
if isempty(mars)
  mars = mars_options('basedefaults');
end
optval = mars_struct('getifthere', mars, varargin{:});
