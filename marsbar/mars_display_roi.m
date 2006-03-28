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
  action_str = '';
end
if isempty(action_str), action_str = 'display'; end

switch lower(action_str), case 'display'             %-Display ROIs
if nargin < 2
  roi_obj = spm_get([0 Inf],'*roi.mat','Select ROI(s) to view');
else 
  roi_obj = varargin{1};
end
if isempty(roi_obj), return, end

if nargin < 3
  mb = spm('getglobal', 'MARS');
  if ~isempty(mb)
    structv = mb.OPTIONS.structural.fname;
  else
    structv = fullfile(spm('dir'), 'canonical', ...
		       ['avg152T1' mars_veropts('template_ext')]);
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

% Process filenames to roi objects
roi_obj = maroi('load_cell', roi_obj);

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
roi_ctr = 1;
for i = 1:olen
  roi = roi_obj{i};
  
  % check ROI contains something
  if isempty(roi) 
    warning(sprintf('ROI %d is missing', i));
  elseif is_empty_roi(roi)
    warning(sprintf('ROI %d:%s is empty', i, label(roi)));
  else
    % Define space for ROI
    nsp = native_space(roi);
    if isempty(nsp)
      nsp = sp;
    end
    
    % convert ROI to matrix
    mo = maroi_matrix(roi, nsp);
    dat = matrixdata(mo);
    if isempty(dat) | ~any(dat(:))
      warning(sprintf('ROI %d: %s  - contains no points to show',...
		      i, label(roi)));
    else
      dat(dat == 0) = NaN;
      % add to image to display
      mars_orthviews('AddColouredMatrix', 1, dat, nsp.mat, cmap(col_inds(i),:));
  
      % Information for display
      XYZ = realpts(roi,nsp);
      mx = max(XYZ, [], 2); mn = min(XYZ, [], 2);
      lbl = label(roi);
      if isempty(lbl), lbl = '[No label]'; end
      roi_info(roi_ctr) = struct(...
	  'label', lbl,...
	  'num', i,...
	  'c_o_m', c_o_m(mo, nsp, 'real'),...
	  'volume', volume(mo),...
	  'maxx', [mn(1) mx(1)],...
	  'maxy', [mn(2) mx(2)],...
	  'maxz', [mn(3) mx(3)] ...
	  );
      roi_ctr = roi_ctr + 1;
    end
  end
end
if roi_ctr == 1
  return
end

% ROI information panel
%-----------------------------------------------------------------------
WS = spm('WinScale');
fg = spm_figure('GetWin','Graphics');
% Frame for ROI info
uicontrol(fg,'Style','Frame','Position',[305 360 280 240].*WS);

% ROI selection menu
rl = length(roi_info); 
labs = [num2str([1:rl]') repmat(': ', rl, 1) strvcat(roi_info(:).label)];
uicontrol(fg,'Style','popupmenu' ,'Position',[320 570 250 20].*WS,...
	  'String', cellstr(labs),...
	  'Callback','mars_display_roi(''roi_menu'')', ...
	  'ToolTipString','ROIs', 'Userdata', roi_info);

uicontrol(fg,'Style','Text', 'Position',[310 520 50 020].*WS,...
	  'String','Label:','HorizontalAlignment','left');
uicontrol(fg,'Style','Text', 'Position',[310 490 110 020].*WS,...
	  'String','Centre of mass:','HorizontalAlignment','left');
uicontrol(fg,'Style','Text', 'Position',[310 460 110 020].*WS,...
	  'String','Volume (mm):','HorizontalAlignment','left');
uicontrol(fg,'Style','Text', 'Position',[310 430 110 020].*WS,...
	  'String','Max/min X(mm):','HorizontalAlignment','left');
uicontrol(fg,'Style','Text', 'Position',[310 400 110 020].*WS,...
	  'String','Max/min Y(mm):','HorizontalAlignment','left');
uicontrol(fg,'Style','Text', 'Position',[310 370 110 020].*WS,...
	  'String','Max/min Z(mm):','HorizontalAlignment','left');

% Text information
st.mars.txt.label = uicontrol(fg,'Style','Text', ...
			      'Position',[360 520 220 020].*WS,...
			      'String','',...
			      'HorizontalAlignment','left',...
			      'FontWeight','bold');
st.mars.txt.c_o_m = uicontrol(fg,'Style','Text', ...
			      'Position',[425 490 155 020].*WS,...
			      'String','',...
			      'HorizontalAlignment','left',...
			      'FontWeight','bold');
st.mars.txt.volume = uicontrol(fg,'Style','Text', ...
			       'Position',[425 460 155 020].*WS,...
			       'String','',...
			       'HorizontalAlignment','left',...
			       'FontWeight','bold');
st.mars.txt.maxx = uicontrol(fg,'Style','Text', ...
			     'Position',[425 430 155 020].*WS,...
			     'String','',...
			     'HorizontalAlignment','left',...
			     'FontWeight','bold');
st.mars.txt.maxy = uicontrol(fg,'Style','Text', ...
			     'Position',[425 400 155 020].*WS,...
			     'String','',...
			     'HorizontalAlignment','left',...
			     'FontWeight','bold');
st.mars.txt.maxz = uicontrol(fg,'Style','Text', ...
			     'Position',[425 370 155 020].*WS,...
			     'String','',...
			     'HorizontalAlignment','left',...
			     'FontWeight','bold');

% store ROI information is orthviews global structure
st.mars.roi_info = roi_info;

% set our own callback for crosshair move
st.callback = 'mars_display_roi(''orthcb'');';

% Move to centre of mass of last ROI in list
mars_orthviews('Reposition', roi_info(end).c_o_m);
mars_display_roi('show_info', length(roi_info));

case 'roi_menu'         % callback service from ROI menu
if isfield(st, 'mars')
  v = get(gco, 'Value');
  mars_orthviews('Reposition', st.mars.roi_info(v).c_o_m);
  mars_display_roi('show_info', v);
end
 
case 'show_info'    % show info for ROI, from ROI info structure
v = varargin{1};  
if isfield(st, 'mars')
  if ~isempty(v)
    set(st.mars.txt.label, 'String', ...
		      st.mars.roi_info(v).label);
    set(st.mars.txt.c_o_m, 'String', ...
		      sprintf('%.3g  %.3g %.3g', ...
			      st.mars.roi_info(v).c_o_m));
    set(st.mars.txt.volume, 'String', ...
		      sprintf('%8.2f', st.mars.roi_info(v).volume));
    set(st.mars.txt.maxx, 'String', ...
		      sprintf('%.3g %.3g', st.mars.roi_info(v).maxx));
    set(st.mars.txt.maxy, 'String', ...
		      sprintf('%.3g %.3g', st.mars.roi_info(v).maxy));
    set(st.mars.txt.maxz, 'String', ...
		      sprintf('%.3g %.3g', st.mars.roi_info(v).maxz));
  else
    set(st.mars.txt.label, 'String','');
    set(st.mars.txt.c_o_m, 'String','');
    set(st.mars.txt.volume, 'String','');
    set(st.mars.txt.maxx, 'String','');
    set(st.mars.txt.maxy, 'String','');
    set(st.mars.txt.maxz, 'String','');
  end 
end

case 'orthcb'           % callback service from mars_orthviews
  
% This copied from mars_orthviews 'shopos' function

% The position of the crosshairs has been moved.
%-----------------------------------------------------------------------
if isfield(st,'mp'),
  fg = spm_figure('Findwin','Graphics');
  if any(findobj(fg) == st.mp),
    set(st.mp,'String',sprintf('%.1f %.1f %.1f',mars_orthviews('pos')));
    pos = mars_orthviews('pos',1);
    set(st.vp,'String',sprintf('%.1f %.1f %.1f',pos));
    
    % Set intensity to ROI list
    in_str = '';
    roi_p = [];
    V1 = st.vols{1};
    for r = 1:length(V1.blobs)
      p2 = V1.blobs{r}.mat \ V1.mat * [pos; 1];
      rval = spm_sample_vol(V1.blobs{r}.vol,...
			p2(1),p2(2),p2(3), ...
			0);
      if ~isnan(rval) & rval ~= 0
	roi_p = [roi_p r];
	in_str = [in_str num2str(r) ' '];
      end
    end
    set(st.in,'String',in_str);
    
    % find, and show info for ROI
    if ~isempty(roi_p)
      v = find(roi_p(end) == [st.mars.roi_info(:).num]);
      mars_display_roi('show_info', v);
    else
      mars_display_roi('show_info', []);
    end      
    
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
