function e = error_df(D)
% method returns error df from design
% 
% $Id$

SPM = des_struct(D);
e   = mars_struct('getifthere', SPM, 'xX', 'erdf');
