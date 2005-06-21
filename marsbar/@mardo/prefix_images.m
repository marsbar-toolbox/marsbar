function D = prefix_images(D, action, prefix, flags)
% method for adding or removing prefix from file names in design
% FORMAT D = prefix_images(D, action, prefix)
%
% D          - mardo design
% action     - one of 'add' or 'remove'
% prefix     - prefix to remove
% flags      - optional struct containing none or more of fields
%              'check_exist' - one of 'warn', 'error', 'none'
%                      If not 'none' checks images exist with new
%                      filenames
%              'check_all'   - if not 0, checks all images, instead of
%                              the first image in the image list
%              'check_swap'  - if not 0, checks if images with new
%                      filenames need byte swapping, and swaps if so
%             
% $Id$
  
def_flags = struct('check_exist', 'none', ...
		   'check_all',   1, ...
		   'check_swap',  0);
  
if nargin < 2
  action = 'remove';
end
if nargin < 3
  prefix = 's';
end
if nargin < 4
  flags = [];
end
flags = mars_struct('ffillsplit', def_flags, flags);
if flags.check_swap, flags.check_exist = 'error'; end

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

% Do checks if necessary
c_e = lower(flags.check_exist);
switch c_e
 case 'none'
 case {'error', 'warn'}
  if ~flags.check_all, cV = VY(1); else cV = VY; end
  e_f = 1;
  n_chk = prod(size(cV));
  for v = 1:n_chk
    if ~exist(newfns{v}, 'file'), e_f = 0; break; end
  end
  if ~e_f
    str = sprintf('Image %s does not exist', newfns{v});
    if strcmp(c_e, 'error'), error(str); else warn(str); end
  end
 otherwise
  error(sprintf('Who asked for %s?', c_e));
end
if flags.check_swap
  for v = 1:nf
    if flags.check_all | v == 1
      if mars_utils('is_swapped_wrong', VY(v))
	if VY(v).dim(4) < 256, scf = 256; else scf = 1/256; end
      else 
	scf = 1; 
      end
    end
    VY(v).dim(4) = VY(v).dim(4) * scf;
  end
end

D = set_images(D, VY);

