function o = mars_build_roi
% builds ROIs via the SPM GUI
%
% $Id$

o = [];  
[Finter,Fgraph,CmdLine] = spm('FnUIsetup','Build ROI');

% get ROI type
optfields = {'blob','image','sphere','box'};
optlabs =  {'Activation cluster','Image','Sphere', 'Box'};

roitype = char(...
    spm_input('Type of ROI', '+1', 'm',{optlabs{:} 'Quit'},...
	      {optfields{:} 'quit'},length(optfields)+1));

d = [];
switch roitype
 case 'image'
  imgname = spm_get(1, 'img', 'Image defining ROI');
  [p f e] = fileparts(imgname);
  binf = spm_input('Maintain as binary image', '+1','b',...
				      ['Yes|No'], [1 0],1);
  func = '';
  if spm_input('Apply function to image', '+1','b',...
				      ['Yes|No'], [1 0],1);
    spm_input('img < 30',1,'d','Example function:','batch')
    func = spm_input('Function to apply to image', '+1', 's', 'img');
  end
  d = f; l = f;
  if ~isempty(func)
    d = [d ' func: ' func];
    l = [l '_f_' func];
  end
  if binf
    d = [d ' - binarized'];
    l = [l '_bin'];
  end
  o = maroi_image(struct('vol', spm_vol(imgname), 'binarize',binf,...
			 'func', func));
 case 'blob'
  [XYZ tmp mat pt str] = mars_get_cluster;
  if isempty(XYZ), return, end
  d = sprintf('%s cluster at [%0.1f %0.1f %0.1f]', str, pt);
  l = sprintf('%s_%0.0f_%0.0f_%0.0f', str, pt);
  o = maroi_pointlist(struct('XYZ',XYZ, 'mat', mat));
 case 'sphere'
  c = spm_input('Centre of sphere (mm)', '+1', 'e', [], 3); 
  r = spm_input('Sphere radius (mm)', '+1', 'r', 10, 1);
  d = sprintf('%0.1fmm radius sphere at [%0.1f %0.1f %0.1f]',r,c);
  l = sprintf('sphere_%0.0f-%0.0f_%0.0f_%0.0f',r,c);
  o = maroi_sphere(struct('centre',c,'radius',r));
 case 'box'
  c = spm_input('Centre of box (mm)', '+1', 'e', [], 3); 
  w = spm_input('Widths in XYZ (mm)', '+1', 'e', [], 3);
  d = sprintf('[%0.1f %0.1f %0.1f] box at [%0.1f %0.1f %0.1f]',w,c);
  l = sprintf('box_w-%0.0f_%0.0f_%0.0f-%0.0f_%0.0f_%0.0f',w,c);
  o = maroi_box(struct('centre',c,'widths',w));
 case 'quit'
  o = [];
  return
end

d = spm_input('Description of ROI', '+1', 's', d);
o = descrip(o,d);
l = spm_input('Label for ROI', '+1', 's', l);
o = label(o,l);