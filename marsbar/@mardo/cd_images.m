function D = cd_images(D, newpath, byteswap)
% method for changing path to image files in design
% FORMAT D = cd_imgs(D, newpath [, byteswap])
%
% D          - mardo design
% newpath    - path to replace common path of files in analysis [GUI]
% byteswap   - whether to indicate byte swapping in vol structs 
%              [determined from images by default]
%             
% $Id$
  
if nargin < 2
  newpath = spm_get(-1, '', 'New directory root for files');
end
if nargin < 3
  byteswap=[];
end

% get images
if ~has_images(D)
  warning('Design does not contain images');
  return
end
VY = get_images(D);

% now change directory
if filesep == '\',sepchar='/';else sepchar='\';end
n = length(VY);
strout = strvcat(VY(:).fname);
msk    = diff(strout+0)~=0; % common path
d1     = min(find(sum(msk,1))); 
d1     = max([find(strout(1,1:d1) == sepchar | strout(1,1:d1) == filesep) 0]);
ffnames = strout(:,d1+1:end); % common path removed
tmp = ffnames == sepchar; % sepchar exchanged for this platform
ffnames(ffnames == sepchar) = filesep;
nfnames = cellstr(...
    strcat(repmat(newpath,n,1),filesep,ffnames));
[VY(:).fname] = deal(nfnames{:});

% do the files exist here then?
if ~exist(nfnames{1}, 'file')
  error(['Cannot find first file here: ' nfnames{1}]);
end
if isempty(byteswap) 
  V2 = spm_vol(nfnames{1});
  byteswap = V2.dim(4) ~= VY(1).dim(4);
end

% do byteswap as necessary
if byteswap
  if VY(1).dim(4) < 256, scf = 256; else scf = 1/256; end
  for i = 1:n
    VY(i).dim(4) = VY(i).dim(4) * scf;
  end
  if verbose(D)
    disp('Images vols byteswapped');
  end
end    

D = set_images(D, VY);
