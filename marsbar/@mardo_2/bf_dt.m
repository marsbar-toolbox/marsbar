function d = bf_dt(D)
% method returns length of time bin for basis functions
% 
% $Id$

SPM = des_struct(D);
d   = mars_struct('getifthere', SPM, 'xBF', 'dt');
