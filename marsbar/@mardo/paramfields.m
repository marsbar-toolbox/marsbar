function params = paramfields(o)
% returns struct with fields from maroi object useful for copying objects
%
% $Id$

params = struct('des_struct', o.des_struct,...
		'flip_opiton', o.flip_option);