function xCon = get_contrasts(D)
% method to get contrasts from design object
% FORMAT xCon = get_contrasts(D)
% 
% Returns contrast structure from design
% See ui_get_contrasts for UI to get individual contrasts
%  
% $Id$
  
SPM = des_struct(D);
xCon = mars_struct('getifthere', SPM, 'xCon');
