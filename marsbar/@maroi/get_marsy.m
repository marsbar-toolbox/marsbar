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
% marsY      - MarsBaR data structure
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
[marsY.Y marsY.Yvar] = deal(zeros(length(VY), rlen));
rno = 0;
for r = 1:rlen
  if vf
    fprintf('%s%30s',sprintf('\b')*ones(1,30),sprintf('%4d/%-4d',r,rlen))
  end
  o = roi_array{r};
  [y vals]  = getdata(o, VY);
  [ny nvals] = size(y);
  if isempty(y)
    if vf, fprintf('\n');end
    warning(sprintf('No valid data for roi %d (%s)', r, label(o)));
    if vf & r < rlen, fprintf('%-40s: %30s','Fetching data',' '); end
  else
    rno = rno + 1;
    [marsY.Y(:,rno) marsY.Yvar(:,rno)] = mars_sum_func(y, sumfunc, vals);
    
    % get data for columns
    marsY.cols{rno} = struct(...
	'y', y, ...
	'name', label(o),...
	'file', source(o),...
	'descrip', descrip(o));
  end
end
marsY.Y = marsY.Y(:,1:rno);
if vf, fprintf('...done\n'); end

marsY.sumfunc = sumfunc;