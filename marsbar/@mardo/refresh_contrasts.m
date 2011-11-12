function o = refresh_contrasts(o)
% method to refresh contrasts to match design
o = set_contrasts(o, get_contrasts(o));
