function marsY = mars_roidata(roilist, VY, sumfunc, flags)
% gets data in ROIs from images
% FORMAT marsY = mars_roidata(roilist, VY, sumfunc, flags)
%   
% roilist    - list of ROI file names, or cell array of ROI objects
% VY         - array of SPM vol structs, or image names
% sumfunc    - one of 'ask', mean', 'median', 'eigen1', 'wtmean'  to summarize
%              data in the ROIs
% flags      - none or more of 
%                'v' - selects verbose output to matlab console
%
% $Id$
 
roiext = maroi('classdata', 'fileend');
if nargin < 1
  roilist = spm_get(Inf, roiext, 'Select ROIs to get data from');
end
if nargin < 2
  VY = spm_get(Inf, 'img', 'Select images to get data from');
end
if nargin < 3
  sumfunc = '';
end
if nargin < 4
  flags = '';
end

if isempty(sumfunc), sumfunc = 'ask';end
if strcmp(sumfunc, 'ask')
  sumfunc = char(spm_input('Summary function', '+1','m',...
			   'Mean|Weighted mean|Median|1st eigenvector',...
			   {'mean','wtmean','median','eigen1'}, 1));
end

if isempty(flags), flags = ' '; end
if any(flags == 'v'), vf = 1; else vf = 0;end

if ischar(roilist)
  for i = 1:size(roilist, 1)
    o{i} = maroi('load', deblank(roilist(i,:)));
  end
  roilist = o;
end

if ischar(VY)
  if vf, fprintf('%-40s: %30s','Mapping files',' ');end
  VY = spm_vol(VY);
  if vf, fprintf('%s%30s\n',sprintf('\b')*ones(1,30),'...done');end
end

if vf, fprintf('Fetching data...'); end
rlen = length(roilist);
[marsY.Y marsY.Yvar] = deal(zeros(length(VY), rlen));
rno = 0;
for r = 1:rlen
  if vf
    fprintf('%s%30s',sprintf('\b')*ones(1,30),sprintf('%4d/%-4d',r,rlen))
  end
  o = roilist{r};
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