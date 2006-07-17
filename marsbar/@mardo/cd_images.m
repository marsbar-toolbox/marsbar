function D = cd_images(D, newpath, byteswap)
% method for changing path to image files in design
% FORMAT D = cd_images(D, newpath [, byteswap])
%
% Synopsis
% D = cd_images(D); % get new path from GUI
% D = cd_images(D, '/new/root/path'); 
% D = cd_images(D, '/new/root/path', 1); % force byteswap
% D = cd_images(D, '/new/root/path', 1); % prevent byteswap  
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
newpath = spm_get('cpath', newpath);
if filesep == '\', other_filesep='/';else other_filesep='\';end
n = length(VY);
strout = strvcat(VY(:).fname);
msk    = diff(strout+0)~=0; % common path
d1     = min(find(sum(msk,1))); 
d1     = max([find(strout(1,1:d1) == other_filesep | strout(1,1:d1) == filesep) 0]);
ffnames = strout(:,d1+1:end); % common path removed
tmp = ffnames == other_filesep; % filesep exchanged for this platform
ffnames(tmp) = filesep;
nfnames = cellstr(...
    strcat(repmat(newpath,n,1),filesep,ffnames));
[VY(:).fname] = deal(nfnames{:});

% do the files exist here then?
if ~exist(nfnames{1}, 'file')
  error(['Cannot find first file here: ' nfnames{1}]);
end
if isempty(byteswap) 
  byteswap = mars_vol_utils('is_swapped_wrong', VY(1));
end

% do byteswap as necessary
if byteswap
  VY = mars_vol_utils('byte_swap', VY);
  if verbose(D)
    disp('Images vols byteswapped');
  end
end    

D = set_images(D, VY);
