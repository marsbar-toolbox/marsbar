function obj2 = maroi_matrix(obj, space)
% maroi_matrix method - converts roi to maroi matrix type
%
% Without space arg, returns object in native space
%
% $Id$

params = paramfields(obj);
params.dat = obj.voxblock.dat;
params.mat = obj.voxblock.mat;

% put into maroi_matrix object
obj2 = maroi_matrix(params);

% rebase using maroi_matrix method if space argument passed
if nargin > 1
  obj2 = maroi_matrix(obj2, space);
end