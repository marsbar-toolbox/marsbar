function [Y, multv, vXYZ, mat] = getdata(roiobj, data_imgs, flags)
% getdata method - fetches time series data for ROI from images 
% FORMAT [Y multv vXYZ mat] = getdata(roiobj, data_imgs, flags)
%
% roiobj    - an object of type maroi
% data_imgs - images to fetch data from.  These can be in the form of
%             a character array, or an array of type spm_vol (see
%             spm_vol.m)
%
% flags can can be none or more of
%              z - use zero masking for images without NaN represenation
%              n - nearest neighbour resampling of images
%              s - sinc resampling of images (why?)
%              (trilinear resampling is the default)
%              m - remap images
%              l - Leave in columns with missing data
%
% If the resampling is not set with the flags input, then we use the resampling
% value from the ROI ``spm_hold`` value.
%
% default flags is empty
%
% Returns
% Y        - no of images x no of voxels in ROI data matrix
% multv    - weighting values from ROI (which have not been applied)
% vXYZ     - voxel coordinates of ROI from first image in series
% mat      - voxels -> mm mat file, again from first in series
%
% Matthew Brett 8/11/99, 2/8/01 (JBCP)
%
% $Id$
  
if nargin < 2
  error('Need ROI and data images');
end
if nargin < 3
  flags = '';
end
if isempty(flags)
  flags = ' ';
end

if ischar(data_imgs)
  data_imgs = spm_vol(data_imgs);
elseif ~isstruct(data_imgs)
  error('Input data files must be strings or structs')
elseif any(flags == 'm')
  for i = 1:length(data_imgs)
    data_imgs(i) = spm_vol(data_imgs(i).fname);
  end
end

% resampling = set by ROI hold value by default
if any(flags == 's')
  holdval = -11;
elseif any(flags == 'n')
  holdval = 0;
else % Not specified, use ROI default resampling value
  holdval = spm_hold(roiobj);
end

% NaN replacement
if any(flags == 'z')
  zmask = 1;
else
  zmask = 0;
end

% get real points corresponding to first image in series
[XYZ multv] = realpts(roiobj, mars_space(data_imgs(1)));
dlen = length(multv);
if dlen == 0 % no points in space
  Y = [];
  return
end
XYZ = [XYZ; ones(size(multv))];

% check for same dims etc - which could save a bag of time
% Code a bit tricksy here to allow comparison of vector and 4x4 matrices
% without doing loops
%---------------------------------------------------------
nimgs = length(data_imgs);
dims = cat(3,data_imgs(:).dim);
dims = dims(:, 1:3, :); % to allow for SPM2/SPM99 4 element dims
chgflgs = any(diff(dims,1,3)) | any(any(diff(cat(3,data_imgs(:).mat),1,3)));
chgflgs = [1; chgflgs(:)];

% create return matrix
Y = zeros(nimgs, dlen);

for i = 1:nimgs
  % nan replacement
  i_type = mars_vol_utils('type', data_imgs(i));
  nanrep =  spm_type(i_type, 'nanrep');

  if chgflgs(i)  % images not the same, (re)get resample points
    ixyz = data_imgs(i).mat \ XYZ;
  end
  if i == 1; % record voxel XYZ for return 
    vXYZ = ixyz(1:3,:);
    mat  = data_imgs(1).mat;
  end
  % resample data at voxel centres of ROI
  data = spm_sample_vol(data_imgs(i), ixyz(1,:),ixyz(2,:),ixyz(3,:),holdval);
  % clear out missing values
  if ~nanrep & zmask
    data(data == 0) = NaN;
  end
  % return all the values
  Y(i, :) = data;
end

% strip missing data
if ~any(flags == 'l')
  % Mask out columns with NaNs
  msk = ~any(isnan(Y),1);
  if ~all(msk)
    Y = Y(:, msk);
    multv = multv(msk);
  end
end
return
