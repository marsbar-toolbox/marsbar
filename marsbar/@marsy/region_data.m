function res = region_data(varargin)
% method gets or sets data for region(s) as cell array
% FORMAT res = region_data(o, r_nos) (get) OR 
% FORMAT res = region_data(o, r_nos, new_data) (set)
% 
% See region_field for details
%  
% $Id$

res = region_field('Y', varargin{:});
  
  