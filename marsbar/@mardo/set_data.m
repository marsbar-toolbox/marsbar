function D = set_data(D, d)
% method to set data for design object
% 
% $Id$
  
SPM = des_struct(D);
SPM.marsY = d;
D = des_struct(D, SPM);