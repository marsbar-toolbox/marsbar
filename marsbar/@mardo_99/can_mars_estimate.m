function tf = can_mars_estimate(D)
% method returns 1 if design can be estimated in MarsBaR
% 
% $Id$

tf = ~isfmri(D) | (has_filter(D) & has_autocorr(D));

  