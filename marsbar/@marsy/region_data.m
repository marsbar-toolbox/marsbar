function rd = region_data(o, r_nos)
% method returns data for region(s) as cell array
% FORMAT rd = region_data(o, r_nos)
% 
% Inputs
% o              - marsy object
% r_nos          - region number 
%                  or array of region numbers
%                  or empty - giving all regions
% 
% Returns
% rd             - cell array of region data matrices
%  
% $Id$

if nargin < 2
  r_nos = [];
end
rs = region(o, r_nos);
rs = [rs{:}];
[rd{1:length(rs)}] = deal(rs.Y);
  
  
  