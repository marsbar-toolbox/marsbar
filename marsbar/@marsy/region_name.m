function rn = region_name(o, r_nos, default_prefix)
% gets region names as cell array
% FORMAT rn = region_name(o, r_nos, default_prefix)
% 
% Inputs
% o              - marsy object
% r_nos          - region number 
%                  or array of region numbers
%                  or empty - giving all regions
% default_prefix - default prefix to make default name for 
%                  regions with undefined names
%                  if empty, undefined region names are empty
%                  if not empty, undefined region names returned
%                  as prefix followed by region number
%                  defaults to 'region_', giving region names
%                  'region_1', 'region_2' etc
% 
% Returns
% rn             - cell array of region names
% 
% $Id$

if nargin < 2
  r_nos = [];
end
if nargin < 3
  default_prefix = 'region_';
end
[rs r_nos] = region(o, r_nos);
for i = 1:length(rs)
  rn{i} = '';
  if mars_struct('isthere', rs{i}, 'name') 
    rn{i} = rs{i}.name;
  else
    if ~isempty(default_prefix)
      rn{i} = sprintf('%s%d', default_prefix, r_nos(i));
    end
  end
end
