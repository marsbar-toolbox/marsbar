function varargout=marsbar(varargin) 
% Startup, callback and utility routine for Marsbar
%
% MarsBaR: Marseille Boite a Regions d'interet 
%          Marseille Region of Interest Toolbox 
%
% MarsBaR (the collection of files listed by Contents.m) is copyright under
% the GNU general public license.  Please see mars_licence.man for details.
% 
% Marsbar written by 
% Jean-Luc Anton, Matthew Brett, Jean-Baptiste Poline, Romain Valabregue 
%
% Portions of the code rely heavily on (or are copied from) SPM99
% (http://www.fil.ion.ucl.ac.uk/spm99), which is also released under the GNU
% public licence.  Many thanks the SPM authors: (John Ashburner, Karl
% Friston, Andrew Holmes et al, and of course our own Jean-Baptiste).
%
% This software is MarsBaRWare. It is written in the hope that it is
% helpful; if you find it so, please let us know by sending a Mars bar to:
% The Jean-Luc confectionery collection, Centre IRMf, CHU La Timone, 264,
% Rue Saint Pierre 13385 Marseille Cedex 05, France
% 
% If you find that it actively hinders your work, do send an
% elderly sardine to the same address.
%
% Please visit our friends at The Visible Mars Bar project:
% http://totl.net/VisibleMars
%
% $Id$

% Marsbar version
MBver = '0.24';  % SPM2 development release 

% Various working variables in global variable structure
global MARS;

%-Format arguments
%-----------------------------------------------------------------------
if nargin == 0, Action='Startup'; else, Action = varargin{1}; end

%=======================================================================
switch lower(Action), case 'startup'             %-Start marsbar
%=======================================================================

%-Turn on warning messages for debugging
warning backtrace

% splash screen once per session
splashf = isempty(MARS);

% promote spm directory to top of path, read defaults
marsbar('on');

%-Open startup window, set window defaults
%-----------------------------------------------------------------------
S = get(0,'ScreenSize');
if all(S==1), error('Can''t open any graphics windows...'), end
PF = spm_platform('fonts');

% Splash screen
%------------------------------------------
if splashf
  marsbar('splash');
end

%-Draw marsbar window
%-----------------------------------------------------------------------
Fmenu = marsbar('CreateMenuWin','off');

% SPM buttons that need disabling
marsbar('SPMdesconts','off');

%-Reveal windows
%-----------------------------------------------------------------------
set([Fmenu],'Visible','on')

%=======================================================================
case 'on'                              %-Initialise marsbar
%=======================================================================

% check paths 

% promote spm replacement directory, affichevol directories
mbpath = fileparts(which('marsbar.m'));
spmV = spm('ver');
MARS.ADDPATHS = {fullfile(mbpath, ['spm' spmV(4:end)]),...
		 fullfile(mbpath, 'spm_common'),...
		 fullfile(mbpath, 'fonct'),...
		 fullfile(mbpath, 'init')};
addpath(MARS.ADDPATHS{:}, '-begin');
fprintf('MarsBaR analysis functions prepended to path\n');

% set up the ARMOIRE stuff
% see mars_armoire help for details
design_filter_spec = {...
    'SPMcfg.mat','99 with imgs: SPMcfg.mat';...
    '*_mdes.mat','MarsBaR: *_mdes.mat';...
    'SPM.mat','SPM.mat; 2(all)/99 (estimated: SPM.mat)';...
    'SPM_fMRIDesMtx.mat','99,FMRI,no imgs: SPM*fMRI*'}; 
mars_armoire('add_if_absent','def_design', ...
	     struct('default_file_name', 'untitled_mdes.mat',...	  
		    'filter_spec', {design_filter_spec},...
		    'title', 'default design',...
		    'set_action', 'mars_arm_call(''set_design'',I);'));
mars_armoire('add_if_absent','roi_data',...
	     struct('default_file_name', 'untitled_mdata.mat',...
		    'filter_spec',...
		    {{'*_mdata.mat','MarsBaR data file','(*_mdes.mat'}},...
		    'title', 'ROI data'));
mars_armoire('add_if_absent','est_design',...
	     struct('default_file_name', 'untitled_mres.mat',...
		    'filter_spec',{{'*_mres.mat'}},...
		    'title', 'MarsBaR estimated design',...
		    'set_action', 'mars_arm_call(''set_results'',data);'));

% and workspace
if ~isfield(MARS, 'WORKSPACE'), MARS.WORKSPACE = []; end

% read any necessary defaults
if ~is_there(MARS, 'OPTIONS')
  loadf = 1;
  MARS.OPTIONS = [];
else
  loadf = 0;
end
[mbdefs sourcestr] = mars_options('Defaults');
MARS.OPTIONS = mars_options('fill',MARS.OPTIONS, mbdefs);
mars_options('put');
if loadf
  fprintf('Loaded MarsBaR defaults from %s\n',sourcestr);
end

%=======================================================================
case 'off'                             %-Unload marsbar 
%=======================================================================
% marsbar('Off')
%-----------------------------------------------------------------------
% save outstanding information
mars_armoire('save_ui', 'all');

% remove marsbar added directories
rmpath(MARS.ADDPATHS{:});
fprintf('MarsBaR analysis functions removed from path\n');

%=======================================================================
case 'cfgfile'                             %-file with marsbar cfg
%=======================================================================
% cfgfn  = marsbar('cfgfile')
cfgfile = 'marsbarcfg.mat';
varargout = {which(cfgfile), cfgfile}; 

%=======================================================================
case 'createmenuwin'                              %-Draw marsbar menu window
%=======================================================================
% Fmenu = marsbar('CreateMenuWin',Vis)
if nargin<2, Vis='on'; else, Vis=varargin{2}; end

%-Close any existing 'MarsBaR' 'Tag'ged windows
delete(spm_figure('FindWin','MarsBaR'))

% Version etc info
[MBver,MBc] = marsbar('Ver');

%-Get size and scalings and create Menu window
%-----------------------------------------------------------------------
WS   = spm('WinScale');				%-Window scaling factors
FS   = spm('FontSizes');			%-Scaled font sizes
PF   = spm_platform('fonts');			%-Font names (for this platform)
Rect = [50 600 300 275];           	%-Raw size menu window rectangle
bno = 6; bgno = bno+1;
bgapr = 0.25;
bh = Rect(4) / (bno + bgno*bgapr);      % Button height
gh = bh * bgapr;                        % Button gap
by = fliplr(cumsum([0 ones(1, bno-1)*(bh+gh)])+gh);
bx = Rect(3)*0.1;
bw = Rect(3)*0.8;
Fmenu = figure('IntegerHandle','off',...
	'Name',sprintf('%s',MBc),...
	'NumberTitle','off',...
	'Tag','MarsBaR',...
	'Position',Rect.*WS,...
	'Resize','off',...
	'Color',[1 1 1]*.8,...
	'UserData',struct('MBver',MBver,'MBc',MBc),...
	'MenuBar','none',...
	'DefaultTextFontName',PF.helvetica,...
	'DefaultTextFontSize',FS(12),...
	'DefaultUicontrolFontName',PF.helvetica,...
	'DefaultUicontrolFontSize',FS(12),...
	'DefaultUicontrolInterruptible','on',...
	'Renderer','zbuffer',...
	'Visible','off');

%-Objects with Callbacks - main MarsBaR routines
%=======================================================================

funcs = {'mars_display_roi(''display'');',...
	 'affichevol',...
	 'mars_blob_ui;',...
	 'marsbar(''buildroi'');',...
	 'marsbar(''transform'');',...
	 'marsbar(''import'');',...
	 'marsbar(''export'');',...
	 'evalin(''base'', ''Y = mars_extract_data(''''pet'''')'');',...
	 'evalin(''base'', ''Y = mars_extract_data(''''fmri'''')'');',...
	};

uicontrol(Fmenu,'Style','PopUp',...
	  'String',['ROI definition',...
		    '|View...'...
		    '|Draw...'...
		    '|Get SPM cluster(s)...'...
		    '|Build...',...
		    '|Transform...',...
		    '|Import...',...
		    '|Export...',...
		    '|Extract data (PET)',...
		    '|Extract data (FMRI)'],...
	  'Position',[bx by(1) bw bh].*WS,...
	  'ToolTipString','Draw / build / combine ROIs...',...
	  'CallBack','spm(''PopUpCB'',gcbo)',...
	  'UserData',funcs);

% Design menu
funcs = {'marsbar(''ana_cd'')',...
	 'marsbar(''ana_desmooth'')',...
	 'spm_spm_ui(''cfg'',spm_spm_ui(''DesDefs_PET''));',...
	 '[X,Sess] = spm_fmri_spm_ui;',...		    
	 'spm_spm_ui(''cfg'',spm_spm_ui(''DesDefs_Stats''));',...
	 'spm pointer watch, spm_DesRep; spm pointer arrow',...
	 'marsbar(''add_images'')',...
	 'marsbar(''edit_filter'')',...
	 'mars_armoire(''set_ui'', ''def_design'');',...
	 'mars_armoire(''save_ui'', ''def_design'', ''fw'');'};

uicontrol(Fmenu,'Style','PopUp',...
	  'String',['Design...'...
		    '|Change design path to images',...
		    '|Convert to unsmoothed|PET models',...
		    '|FMRI models|Basic models|Explore',...
		    '|Add filter+images to FMRI design',...
		    '|Add/edit filter for FMRI design',...	
		    '|Set design from file',...
		    '|Save design to file'],...
	  'Position',[bx by(2) bw bh].*WS,...
	  'ToolTipString','Set/specify design...',...
	  'CallBack','spm(''PopUpCB'',gcbo)',...
	  'UserData',funcs);

% Data menu
funcs = {'marsbar(''extract_data'', ''default'');',...
	 'marsbar(''extract_data'', ''full'');',...
	 'disp(''Import'');',...
	 'disp(''Export'');',...
	 'mars_armoire(''set_ui'', ''roi_data'');',...
	 'mars_armoire(''save_ui'', ''roi_data'', ''fw'');'};

uicontrol(Fmenu,'Style','PopUp',...
	  'String',['Data...'...
		    '|Extract ROI (default)',...
		    '|Extract ROIs (full options)',...
		    '|Import data',...
		    '|Export data',...
		    '|Set data from file',...
		    '|Save data to file'],...
	  'Position',[bx by(3) bw bh].*WS,...
	  'ToolTipString','Extract/set/save data...',...
	  'CallBack','spm(''PopUpCB'',gcbo)',...
	  'UserData',funcs);

% results menu
funcs = {...
    'marsbar(''estimate'');',...
    'marsbar(''merge_xcon'');',...
    'marsbar(''set_defregion'');',...
    ['evalin(''base'', ',...
     '''[Y y beta SE cbeta] = marsbar(''''spm_graph'''');'');'],...
    ['evalin(''base'', ',...
     '''marsS = marsbar(''''stat_table'''');'');'],...
    'marsbar(''set_results'');',...
    'mars_armoire(''save_ui'', ''est_design'', ''fw'');'};

uicontrol(Fmenu,'Style','PopUp',...
	  'String',['Results...'...
		    '|Estimate results',...
		    '|Import contrasts',...
		    '|Set default region',...
		    '|MarsBaR SPM graph',...
		    '|Statistic table',...
		    '|Set results from file',...
		    '|Save results to file'],...
	  'Position',[bx by(4) bw bh].*WS,...
	  'ToolTipString','Write/display contrasts...',...
	  'CallBack','spm(''PopUpCB'',gcbo)',...
	  'UserData',funcs);

% options menu
funcs = {['global MARS; '...
	 ['global MARS; '...
	 'MARS.OPTIONS=mars_options(''edit'');mars_options(''put'');'],...
	 ['global MARS; '...
	  '[MARS.OPTIONS str]=mars_options(''defaults'');' ...
	  'mars_options(''put''); '...
	  'fprintf(''Defaults loaded from %s\n'', str)'],...
	 ['global MARS; '...
	  '[MARS.OPTIONS str]=mars_options(''basedefaults'');' ...
	  'mars_options(''put''); '...
	  'fprintf(''Defaults loaded from %s\n'', str)'],...
	 'MARS.OPTIONS=mars_options(''load'');mars_options(''put'');'],...
	 'mars_options(''save'');'...
	};
	 
uicontrol(Fmenu,'Style','PopUp',...
	  'String',['Options...'...
		    '|Edit options'...
		    '|Restore defaults'...
		    '|Base defaults',...
		    '|Set options from file'...
		    '|Save options to file'],...
	  'Position',[bx by(5) bw bh].*WS,...
	  'ToolTipString','Load/save/edit MarsBaR options',...
	  'CallBack','spm(''PopUpCB'',gcbo)',...
	  'UserData',funcs);

% quit button
uicontrol(Fmenu,'String','Quit',...
	  'Position',[bx by(6) bw bh].*WS,...
	  'ToolTipString','exit MarsBaR',...
	  'ForeGroundColor','r',...
	  'Interruptible','off',...
	  'CallBack','marsbar(''Quit'')');

% Set quit action if MarsBaR window is closed
%-----------------------------------------------------------------------
set(Fmenu,'CloseRequestFcn','marsbar(''Quit'')')
set(Fmenu,'Visible',Vis)

varargout = {Fmenu};

%=======================================================================
case 'ver'                                      %-Return MarsBaR version
%=======================================================================
% [v [,banner]] = marsbar('Ver')
%-----------------------------------------------------------------------
varargout = {MBver, 'MarsBaR - Marseille ROI toolbox'};

%=======================================================================
case 'estimate'                                 %-Estimate callback
%=======================================================================
% marsbar('estimate')
%-----------------------------------------------------------------------
marsD = mars_armoire('get', 'def_design');
if isempty(marsD), return, end
marsY = mars_armoire('get', 'roi_data');
if isempty(marsY), return, end
marsRes = mars_stat(marsD, marsY);
mars_armoire('set', 'est_results', marsRes);

%=======================================================================
case 'quit'                                      %-Quit MarsBaR window
%=======================================================================
% marsbar('Quit')
%-----------------------------------------------------------------------

% reenable SPM controls
marsbar('SPMdesconts','on');

% do path stuff, save any pending changes
marsbar('off');

%-Close any existing 'MarsBaR' 'Tag'ged windows
delete(spm_figure('FindWin','MarsBaR'))
fprintf('Au revoir...\n\n')

%=======================================================================
case 'spmdesconts'                  %-Enable/disable SPM design controls
%=======================================================================
% dH = marsbar('SPMdesconts', 'off'|'on')
%-----------------------------------------------------------------------
Fmenu = spm_figure('FindWin','Menu');
if isempty(Fmenu)
  return
end

% Check if the required function is still on the path
if isempty(which('mars_veropts')), return,end % a path problem

% Find statistic buttons in this version of SPM
DStrs = mars_veropts('stat_buttons');
dH = [];
for i = 1:length(DStrs)
  tmp = findobj(Fmenu,'String', DStrs{i});
  if ~isempty(tmp), dH = [dH tmp]; end
end
if nargin > 1
  set(dH, 'Enable', varargin{2});
end

%=======================================================================
case 'buildroi'                                  %-build and save roi
%=======================================================================
% o = marsbar('buildroi')
%-----------------------------------------------------------------------
% build and save object
varargout = {[]};
o = mars_build_roi;
if ~isempty(o)
  varargout = {marsbar('saveroi', o)};
end

%=======================================================================
case 'transform'                                  %-transform rois
%=======================================================================
% marsbar('transform')
%-----------------------------------------------------------------------
marsbar('mars_menu', 'Transform ROI', 'Transform:', ...
	{{'combinerois'},{'flip_lr'}},...
	{'Combine ROIs','Flip L/R'});

%=======================================================================
case 'import'                                     %-import rois
%=======================================================================
% marsbar('import')
%-----------------------------------------------------------------------

marsbar('mars_menu', 'Import ROIs', 'Import ROIs from:',...
	{{'img2rois','c'},...
	 {'img2rois','i'}},...
	{'cluster image',...
	 'number labelled ROI image'});

%=======================================================================
case 'export'                                     %-export rois
%=======================================================================
% marsbar('export')
%-----------------------------------------------------------------------

marsbar('mars_menu', 'Export ROI(s)', 'Export ROI(s) to:',...
	{{'roi_as_image'},...
	 {'rois2img', 'c'},...
	 {'rois2img', 'i'}},...
	{'image', 'cluster image',...
	'number labelled ROI image'});

%=======================================================================
case 'img2rois'                                        %-import ROI image
%=======================================================================
%  marsbar('img2rois', roi_type)
%-----------------------------------------------------------------------

if nargin < 2
  roi_type = 'c'; % default is cluster image
else
  roi_type = varargin{2};
end
mars_img2rois('','','',roi_type);

%=======================================================================
case 'rois2img'                                       %-export ROI image
%=======================================================================
%  marsbar('roi2img', roi_type)
%-----------------------------------------------------------------------

if nargin < 2
  roi_type = 'c'; % default is cluster image
else
  roi_type = varargin{2};
end
mars_rois2img('','','',roi_type);

%=======================================================================
case 'saveroi'                                  %-save roi
%=======================================================================
% o = marsbar('saveroi', obj, flags)
%-----------------------------------------------------------------------
% flags will usually be empty, or one or more characters from
% 'n'   do not ask for label or description
% 'l'   use label to make filename, rather than source field

if nargin < 2 | isempty(varargin{2})
  return
end
if nargin < 3
  flags = '';
end
if isempty(flags), flags = ' '; end
o = varargin{2};
varargout = {[]};

% Label, description
if ~any(flags=='n')
  d = spm_input('Description of ROI', '+1', 's', descrip(o));
  o = descrip(o,d);
  l = spm_input('Label for ROI', '+1', 's', label(o));
  o = label(o,l);
end

fn = source(o);
if isempty(fn) | any(flags=='l')
  fn = maroi('filename', marsbar('str2fname', label(o)));
end

[f p] = uiputfile(fn, 'File name for ROI');
if any(f~=0)
  roi_fname = maroi('filename', fullfile(p, f));
  try
    varargout = {saveroi(o, roi_fname)};
  catch
    warning([lasterr ' Error saving ROI to file ' roi_fname])
  end
end

%=======================================================================
case 'combinerois'                                  %-combine rois
%=======================================================================
% marsbar('combinerois')
%-----------------------------------------------------------------------
roilist = spm_get(Inf,'_roi.mat','Select ROI(s) to combine');
if isempty(roilist)
  return
end
[Finter,Fgraph,CmdLine] = spm('FnUIsetup','Combine ROIs');
spm_input('(r1 & r2) & ~r3',1,'d','Example function:','batch')
func = spm_input('Function to combine ROIs', '+1', 's', '');
if isempty(func), retnrn, end
rlen = size(roilist,1);
for i = 1:rlen
  o = maroi('load', deblank(roilist(i,:))); 
  eval(['r' num2str(i) '=o;']);
end
try
  eval(['o=' func ';']);
catch
  warning(['Hmm, probem with function ' func ': ' lasterr]);
  return
end
if isempty(o)
  warning('Empty object resulted');
  return
end
if is_empty_roi(o)
  warning('No volume resulted for ROI');
  return
end

% save ROI
if isa(o, 'maroi')
  o = label(o, func);
  o = marsbar('saveroi', o); 
  fprintf('\nSaved ROI as %s\n', source(o));
else
  warning(sprintf('\nNo ROI resulted from function %s...\n', func));
end

%=======================================================================
case 'flip_lr'                                  %-flip roi L<->R
%=======================================================================
% marsbar('flip_lr')
%-----------------------------------------------------------------------
roilist = spm_get([0 1],'_roi.mat','Select ROI to flip L/R');
if isempty(roilist)
  return
end
[Finter,Fgraph,CmdLine] = spm('FnUIsetup','Flip ROI L<->R');
o = maroi('load', deblank(roilist)); 
o = flip_lr(o);

% save ROI
o = marsbar('saveroi', o, 'l'); 
fprintf('\nSaved ROI as %s\n', source(o));

%=======================================================================
case 'extract_data'                       % gets data maybe using design
%=======================================================================
% marsD = marsbar('extract_data'[, roi_list [, 'full'|'default']]);
if nargin < 2
  roi_list = '';
else
  roi_list = varargin{2};
end
if nargin < 3
  etype = 'default';
else
  etype = varargin{3};
end
if isempty(roi_list)
  roi_list = spm_get(Inf,'roi.mat','Select ROI(s) to extract data for');
end

varargout = {[]};
if isempty(roi_list), return, end

if strcmp(etype, 'default')
  marsD = marsbar('get_design');
  if isempty(marsD), return, end;
  if ~is_there(marsD, 'VY')
    msgbox('Design does not contain images', ...
	   'Cannot use design', ...
	   'warn');
    return
  end
  VY = marsD.VY;
else  % full options extraction
  % question for design
  marsD = [];
  if spm_input('Use SPM design?', '+1', 'b', 'Yes|No', [1 0], 1)
    marsD = marsbar('get_design');
  end
  VY = mars_image_scaling(marsD);
end

% Do data extraction
marsY = mars_roidata(roi_list, VY, ...
		     MARS.OPTIONS.statistics.sumfunc, 'v');
if isempty(marsY.Y)
  msgbox('No data returned','Data extraction', 'warn');
  return
end
varargout = {marsY};

%=======================================================================
case 'set_results'                                  %-set results
%=======================================================================
% donef = marsbar('set_results')
%-----------------------------------------------------------------------
varargout = {0};
marsRes = mars_armoire('set_ui', 'est_design');
if isempty(marsRes), return, end
MARS.WORKSPACE.default_contrast = [];
MARS.WORKSPACE.default_region = [];
varargout = {1};
return

%=======================================================================
case 'add_images'                 %-add filter and images to FMRI design
%=======================================================================
% marsbar('add_images')
%-----------------------------------------------------------------------
marsD = marsbar('get_design');
if isempty(marsD), return, end
if isfield(marsD, 'VY')
  msgbox('Design already contains images', 'Add images', 'warn');
  return
end
marsD = mars_fill_design(marsD, 'fi');
mars_armoire('set', 'def_design', marsD);

%=======================================================================
case 'edit_filter'                   %-add / edit filter for FMRI design
%=======================================================================
% marsbar('edit_filter')
%-----------------------------------------------------------------------
marsD = marsbar('get_design');
if isempty(marsD), return, end
marsD = mars_fill_design(marsD, 'f');
mars_armoire('update', 'def_design', marsD);
mars_armoire('file_name', 'def_design', '');

%=======================================================================
case 'set_defcon'                                  %-set default contrast
%=======================================================================
% donef = marsbar('set_defcon')
%-----------------------------------------------------------------------
varargout = {0};
marsRes = mars_armoire('get', 'est_design');
if isempty(marsRes), return, end
[defcon xCon changef] = mars_conman(marsRes.xX,...
			   marsRes.xCon,'T|F',1,...
			 'Select default contrast','',1);
if changef, mars_armoire('update', 'est_design', marsRes); end
MARS.WORKSPACE.default_contrast = defcon;
varargout = {1};

%=======================================================================
case 'set_defregion'                                  %-set default region
%=======================================================================
% donef = marsbar('set_defregion')
%-----------------------------------------------------------------------
varargout = {0};
marsRes = mars_armoire('get', 'est_design');
if isempty(marsRes), return, end
marsY = mars_armoire('get', 'roi_data');
if isempty(marsY), return, end

MARS.WORKSPACE.default_region = mars_get_region(marsY.cols);
varargout = {1};

%=======================================================================
case 'spm_graph'                                  %-run spm_graph
%=======================================================================
% [Y,y,beta,SE,cbeta] =  marsbar('spm_graph')
%-----------------------------------------------------------------------
varargout = {};
if ~is_there(MARS.WORKSPACE, 'default_region')
  if ~marsbar('set_defregion'), return, end
end
marsRes = mars_armoire('get', 'est_design');
if isempty(marsRes), return, end
[Y,y,beta,SE,cbeta] = mars_spm_graph(...
    marsRes, ...
    marsRes.xCon, ...
    MARS.WORKSPACE.default_region);
varargout = {Y, y, beta, SE, cbeta};

%=======================================================================
case 'stat_table'                                  %-run stat_table
%=======================================================================
% marsS =  marsbar('stat_table')
%-----------------------------------------------------------------------
varargout = {};
marsRes = mars_armoire('get', 'est_design');
if isempty(marsRes), return, end
[varargout{1} marsRes.xCon changef] = ... 
    mars_stat_table(marsRes, marsRes.xCon);
if changef, mars_armoire('update', 'est_design', marsRes); end

%=======================================================================
case 'merge_xcon'                                  %-import contrasts
%=======================================================================
% marsbar('merge_xcon')
%-----------------------------------------------------------------------
marsRes = mars_armuire('get', 'est_design');
if isempty(marsRes), return, end
marsRes.xCon = mars_merge_xcon(...
    marsRes.xX, marsRes.xCon);

%=======================================================================
case 'splash'                           %-show splash screen
%=======================================================================
% marsbar('splash')
%-----------------------------------------------------------------------
 % Shows splash screen  
 WS   = spm('WinScale');		%-Window scaling factors
 [X,map] = imread('marsbar.jpg');
 aspct = size(X,1) / size(X,2);
 ww = 400;
 srect = [200 300 ww ww*aspct] .* WS;   %-Scaled size splash rectangle
 h = figure('visible','off',...
	    'menubar','none',...
	    'numbertitle','off',...
	    'name','Welcome to MarsBaR',...
	    'pos',srect);
 im = image(X);
 colormap(map);
 ax = get(im, 'Parent');
 axis off;
 axis image;
 axis tight;
 set(ax,'plotboxaspectratiomode','manual',...
	'unit','pixels',...
	'pos',[0 0 srect(3:4)]);
 set(h,'visible','on');
 pause(3);
 close(h);
 
%=======================================================================
case 'str2fname'                        %-string to file name
%=======================================================================
% fname = marsbar('str2fname', str)
%-----------------------------------------------------------------------
% accepts string, attempts return of string for valid filename
% The passed string should be without path or extension
if nargin < 2
  error('Need to specify string');
end
str = varargin{2};
% forbidden chars in file name
badchars = unique([filesep '/\ :;.''"~*?<>|&']);

tmp = find(ismember(str, badchars));   
if ~isempty(tmp)
  str(tmp) = '_';
  dt = diff(tmp);
  if ~isempty(dt)
    str(tmp(dt==1))=[];
  end
end
varargout={str};
 
%=======================================================================
case 'is_valid_varname'           %- tests string is valid variable name
%=======================================================================
% tf = marsbar('is_valid_varname', str)
%-----------------------------------------------------------------------
% accepts string, tests if it is a valid variable name
if nargin < 2
  error('Need to specify string');
end
str = varargin{2};
try 
  eval([str '= [];']);
  varargout={1};
catch
  varargout = {0};
end
 
%=======================================================================
case 'get_spmmat'                 %- gets SPM*.mat design structure
%=======================================================================
% S = marsbar('get_spmmat', [spmfilename])
%-----------------------------------------------------------------------
% accepts or fetches name of SPM.mat file, returns SPM.mat structure
 if nargin < 2
   spmmat = [];
 else
   spmmat = varargin{2};
 end
 swd = [];
 if isempty(spmmat)
  spmmat = spm_get(1, 'SPM.mat', 'Select analysis');
  if isempty(spmmat),return,end
 end
 if ischar(spmmat) % assume is SPM.mat file name
   [swd sfn sext] = fileparts(spmmat);
   sfn = [sfn sext];
   spmmat = load(spmmat);
   spmmat.swd = swd;
   spmmat.sfn = sfn;
 elseif isstruct(spmmat)
   if isfield(spmmat,'swd')
     swd = spmmat.swd;
   end
   if isfield(spmmat,'sfn')
     swd = spmmat.sfn;
   end
 else
   error('Requires string or struct as input');
 end

 % check the structure
 if ~isfield(spmmat,'SPMid')
   %-SPM.mat pre SPM99
   error('Incompatible SPM.mat - old SPM results format!?')
 end

 % remove large and unused field
 if isfield(spmmat, 'XYZ')
   rmfield(spmmat, 'XYZ');
 end
 
 varargout = {spmmat, swd, sfn};

%=======================================================================
case 'ana_cd'                      %-changes path to files in SPM design
%=======================================================================
% marsbar('ana_cd')
%-----------------------------------------------------------------------
% fetches name of SPM.mat file, saves as new SPM.mat structure
anamat = spm_get([0 1], 'SPM*.mat', 'Analysis to change paths');
if isempty(anamat), return, end
anamat = marsbar('get_spmmat', anamat);

% save over previous analysis
newspmpath = anamat.swd;

% root path shown in output window
root_names = spm_str_manip(strvcat(anamat.VY(:).fname), 'H');
spm_input(deblank(root_names(1,:)),1,'d','Common path is:');

% new root
newpath = spm_get(-1, '', 'New directory root for files');

% do
mars_ana_cd(anamat, newpath, newspmpath);

%=======================================================================
case 'ana_desmooth'           %-makes new SPM design for unsmoothed data
%=======================================================================
% marsbar('ana_desmooth')
%-----------------------------------------------------------------------
% fetches name of SPM.mat file, saves as new SPM.mat structure
anamat = spm_get([0 1], 'SPM*.mat', 'Analysis -> unsmoothed');
if ~isempty(anamat)
  newdir = spm_get(-1, '', 'Directory to save analysis');
  [pn fname ext] = fileparts(anamat); 
  newname = fullfile(newdir, [fname '_unsmoothed' ext]);
  marsbar('ana_deprefix', anamat, newname, 's');
end
  
%=======================================================================
case 'ana_deprefix' %-makes new SPM design with removed image file prefix
%=======================================================================
% marsbar('ana_deprefix', [oldSPMmat, [newname [prefix]]])
%-----------------------------------------------------------------------
% gets, uses SPM structure, saves as new SPM.mat structure
if nargin < 2
  anamat = spm_get(1, 'SPM*.mat', 'Analysis to deprefix');
else
  anamat = varargin{2};
end
if nargin < 3
  newdir = spm_get(-1, '', 'Directory to save analysis');
  [pn fname ext] = fileparts(anamat); 
  newname = fullfile(newdir, [fname '_depref_' prefix ext]);
else
  newname = varargin{3};
end
if nargin < 4
  prefix = 's';
else
  prefix = varargin{4};
end
 
ana = load(anamat);
if ~isfield(ana, 'VY')
  error('No VY vols in this mat file')
end
if ~isfield(ana.VY, 'fname')
  error('VY does not contain fname field')
end
files = strvcat(ana.VY(:).fname);
fpaths = spm_str_manip(files, 'h');
fns = spm_str_manip(files, 't');
if all(fns(:,1) == prefix)
  fns(:,1) = [];
  newfns = cellstr(strcat(fpaths, filesep, fns));
  [ana.VY(:).fname] = deal(newfns{:});
  if exist(newname, 'file')
    spm_unlink(newname);
  end
  savestruct(newname,ana);
  fprintf('Done...\n');
else
  warning(['Analysis files not all prefixed with ''' prefix ''', no new' ...
		    ' file saved'])
end

%=======================================================================
case 'show_volume'           %- shows ROI volume in mm 
%=======================================================================
% marsbar('show_volume')
%-----------------------------------------------------------------------
roi = spm_get([0 Inf], 'roi.mat', 'Select ROIs tp get volume');
if isempty(roi),return,end
for i = 1:size(roi, 1)
  n = deblank(roi(i,:));
  r = maroi('load', n);
  fprintf('Volume of %s: %6.2f\n', n, volume(r));
end
return

%=======================================================================
case 'roi_as_image'           %- writes roi as image 
%=======================================================================
% marsbar('roi_as_image')
%-----------------------------------------------------------------------
[Finter,Fgraph,CmdLine] = spm('FnUIsetup','Write ROI to image');
roi = spm_get([0 1], 'roi.mat', 'Select ROI to write');
if isempty(roi),return,end
[pn fn ext] = fileparts(roi);
roi = maroi('load', roi);

% space of object
spopts = {'spacebase','image'};
splabs =  {'Base space for ROIs','From image'};
if has_space(roi)
  spopts = {spopts{:} 'native'};
  splabs = {splabs{:} 'ROI native space'};
end
spo = spm_input('Space for ROI image', '+1', 'm',splabs,...
		spopts, 1);
switch char(spo)
 case 'spacebase'
   sp = maroi('classdata', 'spacebase');
 case 'image'
  img = spm_get([0 1], 'img', 'Image defining space');
  if isempty(img),return,end
  sp = mars_space(img);
 case 'native'
  sp = [];
end

% remove ROI file ending
gend = maroi('classdata', 'fileend');
lg = length(gend);
f2 = [fn ext];
if length(f2)>=lg & strcmp(gend, [f2(end - lg +1 : end)])
  f2 = f2(1:end-lg);
else
  f2 = fn;
end

fname = marsbar('get_img_name', f2);
if isempty(fname), return, end
save_as_image(roi, fname, sp);
fprintf('Saved ROI as %s\n',fname);

%=======================================================================
 case 'attach_image'                          %- attaches image to ROI(s)
%=======================================================================
% marsbar('attach_image' [,img [,roilist]])
%-----------------------------------------------------------------------
if nargin < 2
  V = spm_get([0 1], 'img', 'Image to attach');
  if isempty(V), return, end
else
  V = varargin{1};
end
if nargin < 3
  rois = spm_get([0 Inf], '_roi.mat', 'Select ROIs to image to');
  if isempty(rois), return, end
else
  rois = varargin{2};
end
if ischar(V), V = spm_vol(V); end
for i = 1:size(rois, 1)
  n = deblank(rois(i,:));
  try 
    r = maroi('load', n);
  catch
    if ~strmatch(lasterr, 'Cant map image file.')
      error(lasterr);
    end
  end
  if isempty(r)
    continue
  end
  if ~isa(r, 'maroi_image')
    fprintf('ROI %s is not an image ROI - ignored\n', n);
    continue
  end

  r = vol(r, V);
  saveroi(r, n);
  fprintf('Saved ROI %s, attached to image %s\n',...
	  n, V.fname)
end
return

%=======================================================================
 case 'get_img_name'          %-gets name of image, checks for overwrite
%=======================================================================
% P = marsbar('get_img_name', fname, flags);
%-----------------------------------------------------------------------
if nargin < 2
  fname = '';
else
  fname = varargin{2};
end
if nargin < 3
  flags = '';
else 
  flags = varargin{3};
end
if isempty(flags)
  flags = 'k';
end

varargout = {};

fdir = spm_get(-1, '', 'Directory to save image');
fname = spm_input('Image filename', '+1', 's', fname);

if isempty(fname), return, end

% set img extension and make absolute path
[pn fn ext] = fileparts(fname);
fname = fullfile(fdir, [fn '.img']);
fname = spm_get('cpath', fname);

if any(flags == 'k') & exist(fname, 'file')
  if ~spm_input(['Overwrite ' fn], '+1', ...
		'b','Yes|No',[1 0], 1)
    return
  end
end
varargout = {fname};

%=======================================================================
 case 'mars_menu'                    %-menu selection of marsbar actions 
%=======================================================================
% marsbar('mars_menu',tstr,pstr,tasks_str,tasks)
%-----------------------------------------------------------------------

[tstr pstr optfields optlabs] = deal(varargin{2:5}); 
if nargin < 6
  optargs = cell(1, length(optfields));
else
  optargs = varargin{6};
end

[Finter,Fgraph,CmdLine] = spm('FnUIsetup',tstr);
of_end = length(optfields)+1;
my_task = spm_input(pstr, '+1', 'm',...
	      {optlabs{:} 'Quit'},...
	      [1:of_end],of_end);
if my_task == of_end, return, end
marsbar(optfields{my_task}{:});

%=======================================================================
otherwise                                        %-Unknown action string
%=======================================================================
error('Unknown action string')

%=======================================================================
end
return