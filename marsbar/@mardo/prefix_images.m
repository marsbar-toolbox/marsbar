function D = prefix_images(D, action, prefix)
% method for adding or removing prefix from file names in design
% FORMAT D = prefix_images(D, action, prefix)
%
% D          - mardo design
% action     - one of 'add' or 'remove'
% prefix     - prefix to remove
%             
% $Id$
  
if nargin < 2
  action = 'remove';
end
if nargin < 3
  prefix = 's';
end

% get images
if ~has_images(D)
  warning('Design does not contain images');
  return
end
VY = get_images(D);

% remove prefix 
files  = strvcat(VY(:).fname);
fpaths = spm_str_manip(files, 'h');
fns    = spm_str_manip(files, 't');
nf     = size(files, 1);

switch lower(action)
  case 'remove'
   s_is = strmatch(prefix, fns);
   if length(s_is) == nf
     fns(:, 1:length(prefix)) = [];
   else
     warning(['Not all analysis files prefixed with ''' prefix ...
	      ''', design has not been changed'])
     return
   end
 case 'add'
  fns = [repmat(prefix, nf, 1) fns];
 otherwise
  error(['Warped action ' action]);
end

newfns = cellstr(strcat(fpaths, filesep, fns));
[VY(:).fname] = deal(newfns{:});
D = set_images(D, VY);

