function res = region_descrip(varargin)
% method gets or sets descrip for region(s) as cell array
% FORMAT res = region_descrip(o, r_nos) (get) OR 
% FORMAT res = region_descrip(o, r_nos, new_data) (set)
% 
% See region_field for details
%  
% $Id$

res = region_field('descrip', varargin{:});
  
  