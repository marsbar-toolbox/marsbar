function res = region_info(varargin)
% method gets or sets info for region(s) as cell array
% FORMAT res = region_info(o, r_nos) (get) OR 
% FORMAT res = region_info(o, r_nos, new_data) (set)
% 
% See region_field for details
%  
% $Id$

res = region_field('info', varargin{:});
  
  