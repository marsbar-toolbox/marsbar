function X = x(D)
% method returns design matrix from design
% 
% $Id$

SPM = des_struct(D);
X   = mars_struct('getifthere', SPM, 'xX', 'X');
