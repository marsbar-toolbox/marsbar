function marsY = get_marsy(varargin)
% gets data in ROIs from images
% FORMAT marsY = get_marsy(roi1 [, roi2 [, roi3...]], VY, sumfunc, flags)
%   
% roi1, roi2... - ROI objects
%                   This rather arcane call is needed because matlab
%                   does not allow different object types in an array
% VY            - array of SPM vol structs, or image names, or SPM design
% sumfunc       - one of 'mean', 'median', 'eigen1', 'wtmean'  to summarize
%                   data in the ROIs
% flags         - none or more of 
%                   'v' - selects verbose output to matlab console
%
% Returns 
% marsY      - MarsBaR data object
%
% $Id$

for r = 1:nargin
  if ~isa(varargin{r}, 'maroi')
    break
  end
end
rlen = r - 1;
roi_array = varargin(1:rlen);

narg_left = nargin - rlen;
if narg_left < 1
  VY = [];
else
  VY = varargin{r};
end
if isempty(VY), error('Need images to extract from'); end
if narg_left < 2
  sumfunc = '';
else
  sumfunc = varargin{r+1};
end
if isempty(sumfunc), error('Need summary function'); end
if narg_left < 3
  flags = '';
else
  flags = varargin{r+2};
end
if isempty(flags), flags = ' '; end
if any(flags == 'v')
  vf = 1; 
  fprintf('\n\n');
else 
  vf = 0; 
end

% images can come from a design
if isa(VY, 'mardo')
  if ~has_images(VY)
    error('This design does not contain images');
  end
  VY = get_images(VY);
end

% or be filenames
if ischar(VY)
  if vf, fprintf('\n%-40s: %30s','Mapping files',' ');end
  VY = spm_vol(VY);
  if vf, fprintf('%s%30s\n',sprintf('\b')*ones(1,30),'...done');end
end

if vf, fprintf('Fetching data...'); end
rlen = length(roi_array);
rno = 0;
for r = 1:rlen
  if vf
    fprintf('%s%30s',sprintf('\b')*ones(1,30),sprintf('%4d/%-4d',r,rlen))
  end
  o = roi_array{r};
  [y vals vXYZ mat]  = getdata(o, VY);
  [ny nvals] = size(y);
  if isempty(y)
    if vf, fprintf('\n');end
    warning(sprintf('No valid data for roi %d (%s)', r, label(o)));
    if vf & r < rlen, fprintf('%-40s: %30s','Fetching data',' '); end
  else
    rno = rno + 1;
    
    % get data for regions
    if all(vals == 1)
      vals = [];
    end
    r_data{rno} = y;
    r_info{rno} = struct(...
	'name', label(o),...
	'descrip', descrip(o),...
	'weights', vals,...
	'info', struct('file', source(o)),...
	'vXYZ', vXYZ,...
	'mat', mat);
  end
end
marsY = marsy(r_data, r_info, struct(...
    'sumfunc', sumfunc, ...
    'descrip', ['Data extracted from ' label(o)],...
    'info', struct('VY', VY)));

if vf, fprintf('...done\n'); end

