function hC = mars_blob_menu
% puts up ROI menu to add to SPM results interface
% FORMAT hC = mars_blob_menu
% 
% Returns 
% hC              - handle of menu
% 
% $Id$
  
% Tag
tg = 'blob_menu';

%-Get Interactive window and delete any previous DesRepUI menu
%-----------------------------------------------------------------------
Finter = spm_figure('GetWin','Interactive');
delete(findobj(get(Finter,'Children'),'flat','Tag',tg))

hC      = uimenu(Finter,'Label','Write ROI(s)',...
		'Separator','on',...
		'Tag',tg,...
		'UserData','',...
		'HandleVisibility','on');

%-Write one blob
%-----------------------------------------------------------------------
hWo = uimenu(hC,'Label','Write one cluster','Accelerator','O',...
		'CallBack','mars_blob_ui(''save_one'')',...
		'UserData',hC,...
		'HandleVisibility','off');

%-Write all blobs
%-----------------------------------------------------------------------
hWo = uimenu(hC,'Label','Write all clusters','Accelerator','A',...
		'CallBack','mars_blob_ui(''save_many'')',...
		'UserData',hC,...
		'HandleVisibility','off');

%-Rerun results ui
%-----------------------------------------------------------------------
hWo = uimenu(hC,'Label','Rerun results UI','Accelerator','R',...
		'CallBack','mars_blob_ui(''reinit'')',...
		'UserData',hC,...
		'HandleVisibility','off');
%-Clear
%-----------------------------------------------------------------------
uimenu(hC,'Label','Clear','Accelerator','L','Separator','on',...
	'CallBack','spm_results_ui(''Clear'')',...
	'HandleVisibility','off');

%-Pop open 'Interactive' window
%-----------------------------------------------------------------------
figure(Finter)

%-Return handle of menu
%-----------------------------------------------------------------------
varargout = {hC};
