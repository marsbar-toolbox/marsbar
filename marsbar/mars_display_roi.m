function varargout=mars_display_roi(action_str, varargin)
% utility routines for display of ROIs in graphic window
% FORMAT varargout=mars_display_roi(action_str, varargin)
%
% Usual call displays one or more ROIs on structural image:
% FORMAT mars_display_roi('display', roi_obj, structv, cmap)
% 
% roi_obj   - single ROI object, or cell array of objects, or strings
% structv   - structural image or spm_vol struct for image
%             [marsbar default structural if not passed]
% cmap      - colormap to use for display
%
% V0.2 - use of jet/specified colormap for display of many ROIs
% V0.3 - string input allowed, actionstrs as first arg, service callback
%
% $Id$
  
global st; % global variable from spm_orthviews

if nargin < 1
  action_str = 'display';
end
switch lower(action_str), case 'display'             %-Display ROIs
if nargin < 2
  roi_obj = spm_get([0 Inf],'roi.mat','Select ROI(s) to view');
else 
  roi_obj = varargin{1};
end
if isempty(roi_obj), return, end

if nargin < 3
  mb = spm('getglobal', 'MARSBAR');
  if ~isempty(mb)
    structv = mb.structural.fname;
  else
    structv = fullfile(spm('dir'), 'canonical', 'avg152t1.img');
  end
else
  structv = varargin{2};
end
if ischar(structv)
  structv = spm_vol(structv);
end
if nargin < 4
  cmap = jet;
else
  cmap = varargin{3};
end

if ischar(roi_obj), roi_obj = cellstr(roi_obj); end
if ~iscell(roi_obj), roi_obj = {roi_obj};end

olen = prod(size(roi_obj));
if olen > 1
  col_inds = round((0:(olen-1))*(size(cmap, 1)-1)/(olen-1))+1;
else
  col_inds = 1;
end

% display with spm orthoviews
spm_image('init', structv.fname);

% space for object for which this is not defined
sp = mars_space(structv);

mo = [];
for i = 1:olen
  roi = maroi('load', roi_obj{i});
  % check ROI contains something
  if isempty(roi) 
    warning(sprintf('ROI %d is missing', i));
  elseif is_empty_roi(roi)
    warning(sprintf('ROI %d:%s is empty', i, label(roi)));
  else
    % convert ROI to matrix
    nsp = native_space(roi);
    if isempty(nsp)
      nsp = sp;
    end
    mo = maroi_matrix(roi, nsp);
    dat = matrixdata(mo);
    if isempty(dat) | ~any(dat(:))
      warning(sprintf('ROI %d: %s  - contains no points to show',...
		      i, label(roi)));
      mo = [];
    else
      dat(dat == 0) = NaN;
      % add to image to display
      spm_orthviews('AddColouredMatrix', 1, dat, nsp.mat, cmap(col_inds(i),:));
    end
  end
end
if ~isempty(mo)
  spm_orthviews('Reposition', c_o_m(mo, sp, 'real'));
end

% ROI information panel
%-----------------------------------------------------------------------
WS = spm('WinScale');
fg = spm_figure('GetWin','Graphics');

uicontrol(fg,'Style','Text', 'Position',[75 295 35 020].*WS,'String','mm:');
uicontrol(fg,'Style','Text', 'Position',[75 275 35 020].*WS,'String','vx:');
uicontrol(fg,'Style','Text', 'Position',[75 255 65 020].*WS,'String','Intensity:');

st.mars.mp = uicontrol(fg,'Style','edit', 'Position',[110 295 135 ...
		    020].*WS,'String','','Callback', ...
		       'spm_image(''setposmm'')','ToolTipString',...
		       'move crosshairs to mm coordinates');
st.mars.vp = uicontrol(fg,'Style','edit', 'Position',[110 275 135 ...
		    020].*WS,'String','','Callback', ...
		       'spm_image(''setposvx'')','ToolTipString',...
		       'move crosshairs to voxel coordinates');
st.mars.in = uicontrol(fg,'Style','Text', 'Position',[140 255  85 ...
		    020].*WS,'String','');

% set our own callback for crosshair move
st.callback = 'mars_display_roi(''orthcb'');';

case 'orthcb'           % callback service from spm_orthviews
  
% This copied from spm_orthviews 'shopos' function

% The position of the crosshairs has been moved.
%-----------------------------------------------------------------------
if isfield(st,'mp'),
  fg = spm_figure('Findwin','Graphics');
  if any(findobj(fg) == st.mp),
    set(st.mp,'String',sprintf('%.1f %.1f %.1f',spm_orthviews('pos')));
    pos = spm_orthviews('pos',1);
    set(st.vp,'String',sprintf('%.1f %.1f %.1f',pos));
    
    % Set intensity to ROI list
    in_str = '';
    roi_p = [];
    for r = 1:length(st.vols{1}.blobs)
      if ~isnan(spm_sample_vol(st.vols{1}.blobs{r}.vol,...
			pos(1),pos(2),pos(3), ...
			0))
	roi_p = [roi_p r];
	in_str = [in_str num2str(r) ' '];
      end
    end
    set(st.in,'String',in_str);
    
  else,
    st.Callback = ';';
    rmfield(st,{'mp','vp','in'});
  end;
else,
  st.Callback = ';';
end;

otherwise
  error(['Unknown action strig: ' action_str]);
end