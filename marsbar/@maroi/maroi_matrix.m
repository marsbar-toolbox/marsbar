function obj2 = maroi_matrix(obj, sp)
% maroi_matrix method - converts roi to maroi matrix type
% In this case, the function only checks why it has been inappropriately
% called (if useful, it should have been overridden)
%
% $Id$

error('Unexpected call to maroi_matrix on object with no method');