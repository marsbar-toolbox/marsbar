function mars_rois2img(roi_list, img_name, roi_space, flags)
% creates cluster or number labelled ROI image from ROIs
% FORMAT mars_rois2img(roi_list, img_name, roi_space, flags)
%
% roi_list  - strings with ROI filenames
% img_name  - name of image to write out
% roi_space - space for image
% flags    - none or more of: [default = 'i']
%             'i' - id image, voxel values identify ROIs
%             'c' - cluster image, clusters identified by location
%
% $Id %
  
if nargin < 1
  roi_list = '';
end
if nargin < 2
  img_name = '';
end
if nargin < 3
  roi_space = [];
end
if nargin < 4
  flags = '';
end

% Process input arguments
if isempty(roi_list)
  roi_list = spm_get([0 Inf], '_roi.mat', 'Select ROIs to write to image');
  if isempty(roi_list), return, end
end
if isempty(img_name)
  img_name = marsbar('get_img_name');
  if isempty(img_name), return, end
end
if isempty(roi_space)
   roi_space = maroi('classdata', 'spacebase');
end
if isempty(flags)
  flags = 'i';  % id image is default
end

if ischar(roi_list), roi_list = cellstr(roi_list); end
if ~iscell(roi_list), roi_list = {roi_list};end
roi_len = prod(size(roi_list));

img_data = zeros(roi_space.dim);
roi_ctr = 1;
for i = 1:roi_len
  fprintf('Loading %s\n', roi_list{i});
  roi = maroi('load', roi_list{i});
  % check ROI contains something
  if isempty(roi) 
    warning(sprintf('ROI %d is missing', i));
  elseif is_empty_roi(roi)
    warning(sprintf('ROI %d:%s is empty', i, label(roi)));
  else    
    % convert ROI to matrix
    mo = maroi_matrix(roi, roi_space);
    dat = matrixdata(mo);
    if isempty(dat) | ~any(dat(:))
      warning(sprintf('ROI %d: %s  - contains no points in this space',...
		      i, label(roi)));
    else
      % add matrix to image
      if any(flags == 'i')
	img_data(dat ~= 0) = roi_ctr;
	roi_info(roi_ctr) = struct('label', label(roi),...
				   'number', roi_ctr);
      else
	img_data = img_data + dat;
      end
      roi_ctr = roi_ctr + 1;
    end
  end
end
if roi_ctr == 1
  warning('Found no useful ROIs, no image saved');
  return
end

% output image type
img_type = 'float'; % to avoid rounding errors

% save ROI info
if any(flags == 'i')
  [p f e] = fileparts(img_name);
  iname = fullfile(p, [f '_labels.mat']);
  save(iname, 'roi_info');
end

% Prepare and write image
V = struct('fname', img_name,...
	   'mat',   roi_space.mat,...
	   'pinfo', [1 0 0]',...
	   'dim',   [roi_space.dim spm_type(img_type)]);
V = spm_create_image(V);
V = spm_write_vol(V, img_data);

fprintf('Wrote image %s\nDone...\n', img_name);