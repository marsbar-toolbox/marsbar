function ri = region_info(o, r_nos)
% gets region info fields as cell array
% FORMAT ri = region_info(o, r_nos)
% 
% Inputs
% o              - marsy object
% r_nos          - region number 
%                  or array of region numbers
%                  or empty - giving all regions
% 
% Returns
% ri             - cell array of region info structures
% 
% $Id$

if nargin < 2
  r_nos = [];
end
rs = region(o, r_nos);
rs = [rs{:}];
[ri{1:length(rs)}] = deal(rs.info);

