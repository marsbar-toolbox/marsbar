function params = paramfields(o)
% returns struct with fields from maroi object useful for copying objects
%
% $Id$

params = struct('des_struct', o.des_struct,...
		'flip_option', o.flip_option,...
		'verbose', o.verbose);