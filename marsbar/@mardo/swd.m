function res = swd(D, dir)
% method to get/set design directory
% FORMAT dir = swd(D);      % get
% FORMAT D   = swd(D, dir); % set
% 
% $Id$

SPM = des_struct(D);
if nargin < 2
  res = mars_struct('getifthere', SPM, 'swd');
else
  SPM.swd = dir;
  res = des_struct(D, SPM);
end