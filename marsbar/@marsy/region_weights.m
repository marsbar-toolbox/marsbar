function rw = region_weights(o, r_nos)
% method returns weights for region(s) as cell array
% FORMAT rw = region_weights(o, r_nos)
% 
% Inputs
% o              - marsy object
% r_nos          - region number 
%                  or array of region numbers
%                  or empty - giving all regions
% 
% Returns
% rd             - cell array of region weight vectors
%  
% $Id$

if nargin < 2
  r_nos = [];
end
rs = region(o, r_nos);
rs = [rs{:}];
[rw{1:length(rs)}] = deal(rs.weights);
  
  
  