function res = region_weights(varargin)
% method gets or sets weights for region(s) as cell array
% FORMAT res = region_weights(o, r_nos) (get) OR 
% FORMAT res = region_weights(o, r_nos, new_data) (set)
% 
% See region_field for details
%  
% $Id$

res = region_field('weights', varargin{:});
  
  