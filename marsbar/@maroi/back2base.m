function o = back2base(o)
% back2base method - check for spacebase, transform thereto
%
% $Id$

spb = my_classdata('spacebase');
if isempty(spb)
  error('Cannot do arithmetic without defined base space');
end
o = maroi_matrix(o, spb);