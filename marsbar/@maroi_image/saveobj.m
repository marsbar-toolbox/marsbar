function o = saveobj(o)
% saveobj method - removes matrix information from parent to save space
%
% $Id$

% set using maroi_matrix object to avoid object conversion 
o.maroi_matrix = matrixdata(o.maroi_matrix, []);
