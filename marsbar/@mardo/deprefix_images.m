function D = deprefix_images(D, prefix)
% method for removing prefix from file names in design
% FORMAT D = deprefix_images(D, prefix)
%
% D          - mardo design
% prefix     - prefix to remove
%             
% $Id$
  
if nargin < 2
  prefix = 's';
end

% get images
if ~has_images(D)
  warning('Design does not contain images');
  return
end
VY = get_images(D);

% remove prefix 
files = strvcat(VY(:).fname);
fpaths = spm_str_manip(files, 'h');
fns = spm_str_manip(files, 't');
if all(fns(:,1) == prefix)
  fns(:,1) = [];
  newfns = cellstr(strcat(fpaths, filesep, fns));
  [VY(:).fname] = deal(newfns{:});
  D = set_images(D, VY);
else
  warning(['Analysis files not all prefixed with ''' prefix ...
	   ''', design has not been changed'])
end


