function res = region_name(o, r_nos, new_data, default_prefix)
% method gets or sets data for region name
% FORMAT res = region_name(o, r_nos) (get) OR
% FORMAT res = region_name(o, r_nos, [], default_prefix) (get) OR  
% FORMAT res = region_name(o, r_nos, new_data) (set)
% 
% Inputs
% o              - marsy object
% r_nos          - region number 
%                  or array of region numbers
%                  or empty - giving all regions
% new_data       - cell array, containing new names to set
% default_prefix - default prefix to make default name for 
%                  regions with undefined names
%                  if empty, undefined region names are empty
%                  if not empty, undefined region names returned
%                  as prefix followed by region number
%                  defaults to 'region_', giving region names
%                  'region_1', 'region_2' etc
% 
% Returns
% (get call)
% res             - cell array of region names OR
% (set call)
% res             - object with new field names set
% 
% $Id$

if nargin < 2
  r_nos = [];
end
if nargin < 3
  new_data = [];
end
if nargin < 4
  default_prefix = 'region_';
end

if ~isempty(new_data)  % set call
  res = region(o, r_nos, new_data, 'name');
else                    % get call
  [rs r_nos] = region(o, r_nos);
  if isempty(rs), res = rs; return, end
  for i = 1:length(rs)
    if mars_struct('isthere', rs{i}, 'name') 
      res{i} = rs{i}.name;
    elseif ~isempty(default_prefix)
      res{i} = sprintf('%s%d', default_prefix, r_nos(i));
    else
      res{i} = '';    
    end
  end
end


  