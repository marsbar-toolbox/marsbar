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

%-Reveal windows
%-----------------------------------------------------------------------
set([Fmenu],'Visible','on')

%=======================================================================
case 'on'                              %-Initialise marsbar
%=======================================================================

% promote spm replacement directory, affichevol directories
mbpath = fileparts(which('marsbar.m'));
spmV = spm('ver');
MARS.ADDPATHS = {fullfile(mbpath, ['spm' spmV(4:end)]),...
		 fullfile(mbpath, 'spm_common'),...
		 fullfile(mbpath, 'fonct'),...
		 fullfile(mbpath, 'init')};
addpath(MARS.ADDPATHS{:}, '-begin');
fprintf('MarsBaR analysis functions prepended to path\n');

% check SPM defaults are loaded
mars_veropts('defaults');

% set up the ARMOIRE stuff
% see mars_armoire help for details
design_filter_spec = mars_veropts('design_filter_spec');
mars_armoire('add_if_absent','def_design', ...
	     struct('default_file_name', 'untitled_mdes.mat',...	  
		    'filter_spec', {design_filter_spec},...
		    'title', 'default design',...
		    'set_action', 'mars_arm_call(''set_design'',I);'));
mars_armoire('add_if_absent','roi_data',...
	     struct('default_file_name', 'untitled_mdata.mat',...
		    'filter_spec',...
		    {{'*_mdata.mat','MarsBaR data file (*_mdes.mat)'}},...
		    'title', 'ROI data',...
		    'set_action', 'mars_arm_call(''set_data'',I);'));
mars_armoire('add_if_absent','est_design',...
	     struct('default_file_name', 'untitled_mres.mat',...
		    'filter_spec',{{'*_mres.mat'}},...
		    'title', 'MarsBaR estimated design',...
		    'set_action', 'mars_arm_call(''set_results'',data);'));

% and workspace
if ~isfield(MARS, 'WORKSPACE'), MARS.WORKSPACE = []; end

% read any necessary defaults
if ~mars_struct('isthere', MARS, 'OPTIONS')
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
mars_armoire('save_ui', 'all', 'y');

% leave if no signs of marsbar
if isempty(MARS)
  return
end

% remove marsbar added directories
rmpath(MARS.ADDPATHS{:});
fprintf('MarsBaR analysis functions removed from path\n');

%=======================================================================
case 'quit'                                      %-Quit MarsBaR window
%=======================================================================
% marsbar('Quit')
%-----------------------------------------------------------------------

% do path stuff, save any pending changes
marsbar('off');

% leave if no signs of MARSBAR
if isempty(MARS)
  return
end

%-Close any existing 'MarsBaR' 'Tag'ged windows
delete(spm_figure('FindWin','MarsBaR'))
fprintf('Au revoir...\n\n')

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
	 'marsbar(''import_rois'');',...
	 'marsbar(''export_rois'');'};

uicontrol(Fmenu,'Style','PopUp',...
	  'String',['ROI definition',...
		    '|View...'...
		    '|Draw...'...
		    '|Get SPM cluster(s)...'...
		    '|Build...',...
		    '|Transform...',...
		    '|Import...',...
		    '|Export...'],...
	  'Position',[bx by(1) bw bh].*WS,...
	  'ToolTipString','Draw / build / combine ROIs...',...
	  'CallBack','spm(''PopUpCB'',gcbo)',...
	  'UserData',funcs);

% Design menu
funcs = {...
    'marsbar(''list_images'')',...
    'marsbar(''ana_cd'')',...
    'marsbar(''ana_desmooth'')',...
    'marsbar(''make_design'', ''pet'');',...
    'marsbar(''make_design'', ''fmri'');',...
    'marsbar(''make_design'', ''basic'');',...
    'marsbar(''design_report'')',...
    'marsbar(''add_images'')',...
    'marsbar(''edit_filter'')',...
    'mars_armoire(''set_ui'', ''def_design'');',...
    'mars_armoire(''save_ui'', ''def_design'', ''fw'');'};

uicontrol(Fmenu,'Style','PopUp',...
	  'String',['Design...'...
		    '|List image names to console',...
		    '|Change design path to images',...
		    '|Convert to unsmoothed',...
		    '|PET models',...
		    '|FMRI models',...
		    '|Basic models',...
		    '|Explore',...
		    '|Add images to FMRI design',...
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
	 'marsbar(''set_defregion'');',...
	 'marsbar(''plot_data'');',...
	 'marsbar(''import_data'');',...
	 'marsbar(''export_data'');',...
	 'marsbar(''split_data'');',...
	 'marsbar(''join_data'');',...
	 'mars_armoire(''set_ui'', ''roi_data'');',...
	 'mars_armoire(''save_ui'', ''roi_data'', ''fw'');'};

uicontrol(Fmenu,'Style','PopUp',...
	  'String',['Data...'...
		    '|Extract ROI (default)',...
		    '|Extract ROIs (full options)',...
		    '|Set default region',...
		    '|Plot data',...
		    '|Import data',...
		    '|Export data',...
		    '|Split regions into files',...
		    '|Merge data files',...
		    '|Set data from file',...
		    '|Save data to file'],...
	  'Position',[bx by(3) bw bh].*WS,...
	  'ToolTipString','Extract/set/save data...',...
	  'CallBack','spm(''PopUpCB'',gcbo)',...
	  'UserData',funcs);

% results menu
funcs = {...
    'marsbar(''estimate'');',...
    'marsbar(''merge_contrasts'');',...
    'marsbar(''add_trial_f'');',...
    'marsbar(''spm_graph'');',...
    'marsbar(''stat_table'');',...
    'marsbar(''set_results'');',...
    'mars_armoire(''save_ui'', ''est_design'', ''fw'');'};

uicontrol(Fmenu,'Style','PopUp',...
	  'String',['Results...'...
		    '|Estimate results',...
		    '|Import contrasts',...
		    '|Add trial-specific F',...
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
	 'MARS.OPTIONS=mars_options(''edit'');mars_options(''put'');'],...
	 ['global MARS; '...
	  '[MARS.OPTIONS str]=mars_options(''defaults'');' ...
	  'mars_options(''put''); '...
	  'fprintf(''Defaults loaded from %s\n'', str)'],...
	 ['global MARS; '...
	  '[MARS.OPTIONS str]=mars_options(''basedefaults'');' ...
	  'mars_options(''put''); '...
	  'fprintf(''Defaults loaded from %s\n'', str)'],...
	 ['global MARS; '...
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
if is_fmri(marsD) & ~has_filter(marsD)
  marsD = fill(marsD, 'filter');
  mars_armoire('update', 'def_design', marsD);
end
marsRes = estimate(marsD, marsY,{'redo_covar','redo_whitening'});
mars_armoire('set', 'est_design', marsRes);

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
case 'import_rois'                                  %- er... import rois
%=======================================================================
% marsbar('import_rois')
%-----------------------------------------------------------------------

marsbar('mars_menu', 'Import ROIs', 'Import ROIs from:',...
	{{'img2rois','c'},...
	 {'img2rois','i'}},...
	{'cluster image',...
	 'number labelled ROI image'});

%=======================================================================
case 'export_rois'                                         %-export rois
%=======================================================================
% marsbar('export_rois')
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
spm_input('(r1 & r2) & ~r3',1,'d','Example function:');
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
% marsY = marsbar('extract_data'[, roi_list [, 'full'|'default']]);
if nargin < 2
  etype = 'default';
else
  etype = varargin{2};
end
if nargin < 3
  roi_list = '';
else
  roi_list = varargin{3};
end
if isempty(roi_list)
  roi_list = spm_get(Inf,'roi.mat','Select ROI(s) to extract data for');
end

varargout = {[]};
if isempty(roi_list), return, end

if strcmp(etype, 'default')
  marsD = mars_armoire('get','def_design');
  if isempty(marsD), return, end;
  if ~has_images(marsD),
    marsD = fill(marsD, 'images');
    mars_armoire('update', 'def_design', marsD);
  end
  VY = get_images(marsD);
else  % full options extraction
  % question for design
  marsD = [];
  if spm_input('Use SPM design?', '+1', 'b', 'Yes|No', [1 0], 1)
    marsD = mars_armoire('get','def_design');
    if ~has_images(marsD),
      marsD = fill(marsD, 'images');
      mars_armoire('update', 'def_design', marsD);
    end
  end
  VY = mars_image_scaling(marsD);
end

% Summary function
sumfunc = sf_get_sumfunc(MARS.OPTIONS.statistics.sumfunc);

% ROI names to objects
for i = 1:size(roi_list, 1)
  o{i} = maroi('load', deblank(roi_list(i,:)));
end

% Do data extraction
marsY = get_marsy(o{:}, VY, sumfunc, 'v');
if ~n_regions(marsY)
  msgbox('No data returned','Data extraction', 'warn');
  return
end

% set into armoire
mars_armoire('set', 'roi_data', marsY);

varargout = {marsY};

%=======================================================================
case 'plot_data'                                   %- guess what it does
%=======================================================================
% marsbar('plot_data', p_type)
%-----------------------------------------------------------------------
% p_type     - plot type: currently only 'basic' is implemented

if nargin < 2
  p_type = [];
else
  p_type = varargin{2};
end
if isempty(p_type)
  p_type = 'basic';
end

marsY = mars_armoire('get','roi_data');
if isempty(marsY), return, end

ui_plot(marsY, p_type);

%=======================================================================
case 'import_data'                                    %- it imports data
%=======================================================================
% marsbar('import_data')
%-----------------------------------------------------------------------

r_f = spm_input('Import what?', '+1', 'm', ...
		['Sample time courses for one region'...
		 '|Summary time course(s) for region(s)'],...
		[1 0], 2);
src = spm_input('Import fron?', '+1', 'm', ...
		['Matlab workspace' ...
		 '|Text file',...
		 '|Lotus spreadsheet',...
		 '|Excel spreadsheet'], ...
		{'matlab','txt','wk1','xls'}, 1);

switch src{1}
 case 'matlab'
  Y = spm_input('Matlab expression', '+1', 'e');
  fn = 'Matlab input';
  pn_fn = lower(fn);
 case 'txt'
  [fn, pn] = uigetfile( ...
      {'*.txt;*.dat;*.csv', 'Text files (*.txt, *.dat, *.csv)'; ...
       '*.*',                   'All Files (*.*)'}, ...
      'Select a text file');
  if isequal(fn,0), return, end
  pn_fn = fullfile(pn, fn);
  Y = spm_load(pn_fn);
 case 'wk1'
  [fn, pn] = uigetfile( ...
      {'*.wk1', 'Lotus spreadsheet files (*.wk1)'; ...
       '*.*',                   'All Files (*.*)'}, ...
      'Select a Lotus file');
  if isequal(fn,0), return, end
  pn_fn = fullfile(pn, fn);
  Y = wk1read(pn_fn);
 case 'xls'
  [fn, pn] = uigetfile( ...
      {'*.xls', 'Excel spreadsheet files (*.xls)'; ...
       '*.*',                   'All Files (*.*)'}, ...
      'Select an Excel file');
  if isequal(fn,0), return, end
  pn_fn = fullfile(pn, fn);
  Y = xlsread(pn_fn);
 otherwise
  error('Strange source');
end
if r_f
  s_f = sf_get_sumfunc(MARS.OPTIONS.statistics.sumfunc);
  r_st = struct('name', fn,...
		'descrip', 'Region data Loaded from ' fn;
  marsY = marsy({Y},str, s_f);
else
  marsY = marsy(Y);
  r_des = [' data oaded from ' fn];
end

% Names and descriptions
stop_f = 0;
ns = region_name(marsY);
for r = 1:length(ns)
  ns{r} = spm_input(...
      sprintf('Name for region %d', r),...
      '+1', 's', ns{r});
  if isempty(ns{r}), stop_f = 1; break, end
end
if ~stop_f
  marsY = region_name(marsY, ns{r});
end

mars_armoire('set', 'roi_data', marsY);
  
%=======================================================================
case 'export_data'                                             %- exports
%=======================================================================
% marsbar('export_data')
%-----------------------------------------------------------------------
marsY = mars_armoire('get','roi_data');
if isempty(marsY), return, end

r_f = spm_input('Export what?', '+1', 'm', ...
		['Sample time courses for one region'...
		 '|Summary time course(s) for region(s)'],...
		[1 0], 2);
src = spm_input('Export to?', '+1', 'm', ...
		['Matlab workspace' ...
		 '|Text file',...
		 '|Lotus spreadsheet'], ...
		{'matlab','txt','wk1'}, 1);

if r_f
  rno = marsbar('get_region', region_name(marsY));
  Y = region_data(marsY, rno);
  Y = Y{1};
else
  Y = summary_data(marsY);
end

switch src{1}
 case 'matlab'
  str = '';
  while ~marsbar('is_valid_varname', str)
    str = spm_input('Matlab variable name', '+1', 's');
    if isempty(str), return, end
  end
  assignin('base', str, Y);
 case 'txt'
  [fn, pn] = uiputfile( ...
      {'*.txt;*.dat;*.csv', 'Text files (*.txt, *.dat, *.csv)'; ...
       '*.*',                   'All Files (*.*)'}, ...
      'Text file name');
  if isequal(fn,0), return, end
  save(fullfile(pn,fn), 'Y', '-ascii');
 case 'wk1'
  [fn, pn] = uiputfile( ...
      {'*.wk1', 'Lotus spreadsheet files (*.wk1)'; ...
       '*.*',                   'All Files (*.*)'}, ...
      'Lotus spreadsheet file');
  if isequal(fn,0), return, end
  wk1write(fullfile(pn,fn), Y);
 otherwise
  error('Strange source');
end

%=======================================================================
case 'split_data'                %- splits data into one file per region 
%=======================================================================
% marsbar('split_data')
%-----------------------------------------------------------------------
marsY = mars_armoire('get','roi_data');
if isempty(marsY), return, end
if n_regions(marsY) == 1
  disp('Only one region in ROI data');
  return
end

d = spm_get([-1 0], '', 'New directory root for files');
if isempty(d), return, end

def_f = summary_descrip(marsY);
if ~isempty(def_f)
  def_f = marsbar('str2fname', def_f);
end
f = spm_input('Root filename for regions', '+1', 's', def_f);
f = marsbar('str2fname', f);
mYarr = split(marsY);
for i = 1:length(mYarr)
  fname = fullfile(d, sprintf('%s_region_%d_mdata.mat', f, i));
  savestruct(mYarr(i), fname);
  fprintf('Saved region %d as %s\n', i, fname);
end

%=======================================================================
case 'join_data'                %- joins many data files into one object 
%=======================================================================
% marsbar('join_data')
%-----------------------------------------------------------------------
P = spm_get([0 Inf], '*_mdata.mat', 'Select data files to join');
if isempty(P), return, end
for i = 1:size(P,1)
  d_o{i} = marsy(deblank(P(i,:)));
end
marsY = join(d_o{:});
mars_armoire('set', 'roi_data', marsY);
disp(P)
disp('Files merged and set as current data')

%=======================================================================
case 'set_results'                                  %-set results
%=======================================================================
% donef = marsbar('set_results')
%-----------------------------------------------------------------------
varargout = {0};
marsRes = mars_armoire('set_ui', 'est_design');
if isempty(marsRes), return, end
mars_armoire('save_ui', 'roi_data', 'y');
mars_armoire('set', 'roi_data', get_data(marsRes));
mars_armoire('has_changed', 'roi_data', 0);
fprintf('Set ROI data from estimated design...\n');

MARS.WORKSPACE.default_contrast = [];
varargout = {1};
return

%=======================================================================
case 'add_images'                            %-add images to FMRI design
%=======================================================================
% marsbar('add_images')
%-----------------------------------------------------------------------
marsD = mars_armoire('get','def_design');
if isempty(marsD), return, end
marsD = fill(marsD, {'images'});
mars_armoire('set', 'def_design', marsD);

%=======================================================================
case 'edit_filter'                   %-add / edit filter for FMRI design
%=======================================================================
% marsbar('edit_filter')
%-----------------------------------------------------------------------
marsD = mars_armoire('get','def_design');
if isempty(marsD), return, end
marsD = fill(marsD, 'filter');
mars_armoire('update', 'def_design', marsD);
mars_armoire('file_name', 'def_design', '');

%=======================================================================
case 'set_defcon'                                 %-set default contrast
%=======================================================================
% donef = marsbar('set_defcon')
%-----------------------------------------------------------------------
varargout = {0};
marsRes = mars_armoire('get', 'est_design');
if isempty(marsRes), return, end
[defcon marsRes changef] = ui_get_contrast(marsRes, 'T|F',1,...
			 'Select default contrast','',1);
if changef, mars_armoire('update', 'est_design', marsRes); end
MARS.WORKSPACE.default_contrast = defcon;
varargout = {1};

%=======================================================================
case 'set_defregion'                                %-set default region
%=======================================================================
% donef = marsbar('set_defregion')
%-----------------------------------------------------------------------
varargout = {0};
marsY = mars_armoire('get', 'roi_data');
if isempty(marsY), return, end
ns = region_name(marsY);
if length(ns) == 1
  disp('Only one region in data');
  rno = 1;
else
  rno = marsbar('get_region', ns);
end
MARS.WORKSPACE.default_region = rno;
disp(['Default region set to: ' ns{rno}]); 
varargout = {1};

%=======================================================================
case 'get_region'                                  %-ui to select region
%=======================================================================
% select region from list box / input
% rno = marsbar('get_region', names, prompt)
% names is cell array of strings identifying regions
% prompt is prompt string
%-----------------------------------------------------------------------

if nargin < 2
  error('Need region names to select from');
else
  names = varargin{2};
end
if nargin < 3
  prompt = 'Select region';
else
  prompt = varargin{3};
end
% maximum no of items in list box
maxlist = 200;
if length(names) > maxlist
  % text input, maybe
  error('Too many regions');
end
% listbox
rno = spm_input(prompt, '+1', 'm', names);  
varargout = {rno};

%=======================================================================
case 'spm_graph'                                         %-run spm_graph
%=======================================================================
% marsbar('spm_graph')
%-----------------------------------------------------------------------
if ~mars_struct('isthere', MARS.WORKSPACE, 'default_region')
  if ~marsbar('set_defregion'), return, end
end
marsRes = mars_armoire('get', 'est_design');
if isempty(marsRes), return, end

% Variables returned in field names to allow differences
% in return variables between versions of spm_graph
r_st = mars_spm_graph(...
    marsRes, ...
    MARS.WORKSPACE.default_region);

% Dump field names to global workspace as variables
fns = fieldnames(r_st);
for f = 1:length(fns)
  assignin('base', fns{f}, getfield(r_st, fns{f}));
end

%=======================================================================
case 'stat_table'                                       %-run stat_table
%=======================================================================
% marsbar('stat_table')
%-----------------------------------------------------------------------
marsRes = mars_armoire('get', 'est_design');
if isempty(marsRes), return, end
[strs marsS marsRes changef] = ... 
    stat_table(marsRes);
disp(char(strs));
assignin('base', 'marsS', marsS);
if changef, mars_armoire('update', 'est_design', marsRes); end

%=======================================================================
case 'merge_contrasts'                                %-import contrasts
%=======================================================================
% marsbar('merge_contrasts')
%-----------------------------------------------------------------------
D = mars_armoire('get', 'est_design');
if isempty(D), return, end
filter_spec = {...
    'SPM.mat','SPM: SPM.mat';...
    '*_mres.mat','MarsBaR: *_mres.mat';...
    '*x?on.mat','xCon.mat file'};
[fn pn] = uigetfile(...
    filter_spec, ...
    'Source design/contrast file...');
if isequal(fn,0) | isequal(pn,0), return, end
fname = fullfile(pn, fn);
D2 = mardo(load(fname));

% has this got contrasts?
if ~has_contrasts(D2)
  error(['Cannot find contrasts in design/contrast file ' fname]);
end
  
% now try to trap case of contrast only file
if ~is_valid(D2)
  D2 = get_contrasts(D2);
end

[D changef] = merge_contrasts(D, D2);
if changef
  mars_armoire('update', 'est_design', D);
end

%=======================================================================
case 'add_trial_f'            %-add trial-specific F contrasts to design
%=======================================================================
% marsbar('add_trial_f')
%-----------------------------------------------------------------------
D = mars_armoire('get', 'est_design');
if isempty(D), return, end
if ~is_fmri(D)
  disp('Can only add F contrasts for FMRI designs');
  return
end
[D changef] = add_trial_f(D);
if changef
  mars_armoire('update', 'est_design', D);
end

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
case 'make_design'                                               %-er...
%=======================================================================
% marsbar('make_design', des_type)
%-----------------------------------------------------------------------
if nargin < 2
  des_type = 'basic';
else
  des_type = varargin{2};
end

switch lower(des_type)
 case 'pet'
  SPM = mars_spm_ui('cfg',spm_spm_ui('DesDefs_PET'));
 case 'basic'
  SPM = mars_spm_ui('cfg',spm_spm_ui('DesDefs_PET'));
 case 'fmri'
  SPM = mars_fmri_design;
end
mars_armoire('set','def_design', SPM);

%=======================================================================
case 'list_images'                     %-lists image files in SPM design
%=======================================================================
% marsbar('list_images')
%-----------------------------------------------------------------------
marsD = mars_armoire('get','def_design');
if isempty(marsD), return, end;
if has_images(marsD)
  P = get_image_names(marsD);
  strvcat(P{:})
else
  disp('Design does not contain images');
end

%=======================================================================
case 'ana_cd'                      %-changes path to files in SPM design
%=======================================================================
% marsbar('ana_cd')
%-----------------------------------------------------------------------
marsD = mars_armoire('get','def_design');
if isempty(marsD), return, end;

% root path shown in output window
P = get_image_names(marsD);
P = strvcat(P{:});
root_names = spm_str_manip(P, 'H');
spm_input(deblank(root_names(1,:)),1,'d','Common path is:');

% new root
newpath = spm_get([-1 0], '', 'New directory root for files');
if isempty(newpath), return, end

% do
marsD = cd_images(marsD, newpath);
mars_armoire('set', 'def_design', marsD);

%=======================================================================
case 'ana_desmooth'           %-makes new SPM design for unsmoothed data
%=======================================================================
% marsbar('ana_desmooth')
%-----------------------------------------------------------------------
marsD = mars_armoire('get','def_design');
if isempty(marsD), return, end;

% do
marsD = deprefix_images(marsD, 's');
mars_armoire('set', 'def_design', marsD);
  
%=======================================================================
case 'design_report'                %-does explore design thing
%=======================================================================
% marsbar('design_report')
%-----------------------------------------------------------------------
marsD = mars_armoire('get','def_design');
if isempty(marsD), return, end;
ui_report(marsD);

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
case 'get_cvs_version'             %- get cvs version string from mfile
%=======================================================================
% str = marsbar('get_cvs_version',filename)
%-----------------------------------------------------------------------

if nargin < 2
  error('Need filename to parse');
end
filename = [varargin{2} '.m'];

% returned value is string
varargout = {''};

fid=fopen(filename,'rt');
if fid == -1, error(['Cannot open file ' filename]);end 
aLine = '';
while(isempty(aLine))
  aLine = fgetl(fid);
end
if  ~strcmp(aLine(1:8),'function'), return, end
aLine = fgetl(fid);
while ~isempty(findstr(aLine,'%')) & feof(fid)==0; 
  [cvsno count] = sscanf(aLine, '%%%*[ ]$Id:%*[ _a-zA-Z.,] %f');
  if count
    varargout = {num2str(cvsno)};
    break
  end
  aLine = fgetl(fid);
end % while
fclose(fid);

%=======================================================================
otherwise                                        %-Unknown action string
%=======================================================================
error('Unknown action string')

%=======================================================================
end
return

% subfunctions
function sum_func = sf_get_sumfunc(sum_func)
if strcmp(sum_func, 'ask')
  sum_func = char(spm_input('Summary function', '+1','m',...
			   'Mean|Weighted mean|Median|1st eigenvector',...
			   {'mean','wtmean','median','eigen1'}, 1));
end
return

