function o = loadobj(o)
% loadobj method - reloads matrix from img file
%
% $Id$

% Note that the image needs full processing before
% setting into the matrix.  After this, the processed
% natrix data becomes an image snapshot for the memory
% lifetime of the object
  
[img errstr] = my_vol_func(o);
if isempty(img)
  if strcmp(errstr, 'Cant open image file.')
    errstr = sprintf('%s\nHas ROI image %s been moved?\n%s\n', ...
		     errstr, o.vol.fname,...
		     'Try to reattach with marsbar(''attach_image'')');
  end
  error(errstr);
end

% set using maroi_matrix object to avoid object conversion 
o.maroi_matrix = matrixdata(o.maroi_matrix,img); 
