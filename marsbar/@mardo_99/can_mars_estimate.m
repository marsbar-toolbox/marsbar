function tf = can_mars_estimate(D)
% method returns 1 if design can be estimated in MarsBaR
% 
% $Id$

tf = ~is_fmri(D) | has_filter(D);

  