function res = region_field(fieldname, o, r_nos, new_data)
% method gets or sets data for region field
% FORMAT res = region_field(fieldname, o, r_nos) (get) OR
% FORMAT res = region_field(fieldname, o, r_nos, new_data) (set)
% 
% Inputs
% fieldname      - name of field to get / set
% o              - marsy object
% r_nos          - region number 
%                  or array of region numbers
%                  or empty - giving all regions
% new_data       - cell array, containing new data to set
% 
% Returns
% (get call)
% res             - cell array of region field values OR
% (set call)
% res             - object with new field data set
%  
% $Id$

if nargin < 2
  error('Need fieldname');
end
if nargin < 3
  r_nos = [];
end
if nargin < 4 % get call
  [rs r_nos] = region(o, r_nos);
  for i = 1:length(r_nos)
    res{i} = getfield(rs{i}, fieldname);
  end
else          % set call
  res = region(o, r_nos, new_data, fieldname);
end
   
  
  