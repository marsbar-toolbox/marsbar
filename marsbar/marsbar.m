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
% The logo was made by Brian Cox
%
% Please visit our friends at The Visible Mars Bar project:
% http://totl.net/VisibleMars
%
% V0.2: 28/1/03
% Show volume in GUI (need volume method for ROIs)
% Fixed SPM/matlab 6 bug for estimate (from SPM99 updates)
% Cluster / maximum need to be aligned (Alex Andrade spotted this one)
% Remove restriction on no of ROIs to display
%
% V0.21: 25/2/03 AP
% Added flip LR to menu
%
% $Id$

% Marsbar version
MBver = '0.22';  % Second beta release

% Marsbar defaults in global variable structure
global MARSBAR;

%-Format arguments
%-----------------------------------------------------------------------
if nargin == 0, Action='Startup'; else, Action = varargin{1}; end

%=======================================================================
switch lower(Action), case 'startup'             %-Start marsbar
%=======================================================================

%-Turn on warning messages for debugging
warning backtrace

% splash screen once per session
splashf = isempty(MARSBAR);

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
% mars_setpath

% promote spm_spm directory, affichevol directories
mbpath = fileparts(which('marsbar.m'));
addpath(fullfile(mbpath, 'spmrep'), '-begin');
addpath(fullfile(mbpath, 'fonct'), '-begin');
addpath(fullfile(mbpath, 'init'), '-begin');

fprintf('MarsBaR analysis function prepended to path\n');

% read any necessary defaults
[mbdefs sourcestr] = mars_options('Defaults');
if isempty(MARSBAR)
  fprintf('MarsBaR defaults loaded from %s\n',sourcestr);
end
MARSBAR = mars_options('fill',MARSBAR, mbdefs);
mars_options('put');

%=======================================================================
case 'off'                             %-Unload marsbar 
%=======================================================================
% marsbar('Off')
%-----------------------------------------------------------------------
% save outstanding xCon
marsbar('save_xcon');

% remove marsbar added directories
mbpath = fileparts(which('marsbar.m'));
rmpath(fullfile(mbpath, 'spmrep'));
rmpath(fullfile(mbpath, 'fonct'));
rmpath(fullfile(mbpath, 'init'));
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
Rect = [50 600 300 234];           	%-Raw size menu window rectangle
bno = 5; bgno = bno+1;
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

funcs = {'marsbar(''ana_desmooth'')',...
	 'spm_spm_ui(''cfg'',spm_spm_ui(''DesDefs_PET''));',...
	 '[X,Sess] = spm_fmri_spm_ui;',...		    
	 'spm_spm_ui(''cfg'',spm_spm_ui(''DesDefs_Stats''));',...
	 'spm pointer watch, spm_DesRep; spm pointer arrow',...
	 'marsbar(''estimate'');',...
	 'mars_model_data_ui;'};

uicontrol(Fmenu,'Style','PopUp',...
	  'String',['Design...'...
		    '|Convert to unsmoothed|PET models',...
		    '|FMRI models|Basic models|Explore|Estimate ROI(s)'...
		    '|Estimate input data'],...
	  'Position',[bx by(2) bw bh].*WS,...
	  'ToolTipString','Design specification...',...
	  'CallBack','spm(''PopUpCB'',gcbo)',...
	  'UserData',funcs);

funcs = {...
    'marsbar(''set_results'');',...
    'marsbar(''merge_xcon'');',...
    'marsbar(''set_defregion'');',...
    ['evalin(''base'', ',...
     '''[Y y beta SE cbeta] = marsbar(''''spm_graph'''');'');'],...
    ['evalin(''base'', ',...
     '''marsS = marsbar(''''stat_table'''');'');'],...
	};
uicontrol(Fmenu,'Style','PopUp',...
	  'String',['Results...'...
		    '|Set current results',...
		    '|Import contrasts',...
		    '|Set default region',...
		    '|MarsBaR SPM graph',...
		    '|Statistic table'],...
	  'Position',[bx by(3) bw bh].*WS,...
	  'ToolTipString','Write/display contrasts...',...
	  'CallBack','spm(''PopUpCB'',gcbo)',...
	  'UserData',funcs);

funcs = {['global MARSBAR; '...
	 'MARSBAR=mars_options(''load'');mars_options(''put'');'],...
	 'mars_options(''save'');',...
	 ['global MARSBAR; '...
	 'MARSBAR=mars_options(''edit'');mars_options(''put'');'],...
	 ['global MARSBAR; '...
	  '[MARSBAR str]=mars_options(''defaults'');' ...
	  'mars_options(''put''); '...
	  'fprintf(''Defaults loaded from %s\n'', str)'],...
	 ['global MARSBAR; '...
	  '[MARSBAR str]=mars_options(''basedefaults'');' ...
	  'mars_options(''put''); '...
	  'fprintf(''Defaults loaded from %s\n'', str)']...
	};
	 
uicontrol(Fmenu,'Style','PopUp',...
	  'String',['Options...'...
		    '|Load options'...
		    '|Save options'...
		    '|Edit options'...
		    '|Restore defaults'...
		    '|Base defaults'],...
	  'Position',[bx by(4) bw bh].*WS,...
	  'ToolTipString','Load/save/edit MarsBaR options',...
	  'CallBack','spm(''PopUpCB'',gcbo)',...
	  'UserData',funcs);
uicontrol(Fmenu,'String','Quit',	'Position',[bx by(5) bw bh].*WS,...
	'ToolTipString','exit MarsBaR',...
	'ForeGroundColor','r',		'Interruptible','off',...
	'CallBack','marsbar(''Quit'')');

%-----------------------------------------------------------------------
set(Fmenu,'CloseRequestFcn','marsbar(''Quit'')')
set(Fmenu,'Visible',Vis)
varargout = {Fmenu};

%=======================================================================
case 'ver'                                      %-Return MarsBaR version
%=======================================================================
% marsbar('Ver')
%-----------------------------------------------------------------------
varargout = {MBver, 'MarsBaR - Marseille ROI toolbox'};

%=======================================================================
case 'estimate'                                 %-Estimate callback
%=======================================================================
% marsbar('estimate')
%-----------------------------------------------------------------------
if exist(fullfile('.','mars_estimated.mat'),'file') & ...
      spm_input({'Current directory contains existing SPM stats files:',...
		 ['(pwd = ',pwd,')'],' ',...
		 'Continuing will overwrite existing results!'},1,'bd',...
		'stop|continue',[1,0],1)
  tmp=0; 
else
  tmp=1; 
end
if tmp
  tmp = load(spm_get(1,'SPMcfg.mat','Select SPMcfg.mat...'));
  if isfield(tmp,'Sess') & ~isempty(tmp.Sess)
    Sess=tmp.Sess; xsDes=tmp.xsDes; % because spm_spm uses inputname
    spm_spm(tmp.VY,tmp.xX,tmp.xM,tmp.F_iX0,Sess,xsDes);
  elseif isfield(tmp,'xC')
    xC=tmp.xC; xsDes=tmp.xsDes; % because spm_spm uses inputname
    spm_spm(tmp.VY,tmp.xX,tmp.xM,tmp.F_iX0,xC,xsDes);
  end
end

%=======================================================================
case 'quit'                                      %-Quit MarsBaR window
%=======================================================================
% marsbar('Quit')
%-----------------------------------------------------------------------

% save any pending contrasts
marsbar('save_xcon');

% reenable SPM controls
marsbar('SPMdesconts','on');

% do path stuff
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
DStrs = {'PET/SPECT models', 'fMRI models','Basic models'...
	 'Explore design', 'Estimate', 'Results'};
dH = [];
for i = 1:length(DStrs)
  dH = [dH findobj(Fmenu,'String', DStrs{i})];
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
	{'combinerois','flip_lr'},...
	{'Combine ROIs','Flip L/R'});

%=======================================================================
case 'import'                                     %-import rois
%=======================================================================
% marsbar('import')
%-----------------------------------------------------------------------

marsbar('mars_menu', 'Import ROIs', 'Import ROIs from:',...
	{'saveallblobs','img2rois','img2rois'},...
	{'all SPM results clusters','cluster image',...
	 'number labelled ROI image'},...
	{'','c','i'});

%=======================================================================
case 'export'                                     %-export rois
%=======================================================================
% marsbar('export')
%-----------------------------------------------------------------------

marsbar('mars_menu', 'Export ROI(s)', 'Export ROI(s) to:',...
	{'roi_as_image','rois2img', 'rois2img'},...
	{'image', 'cluster image',...
	'number labelled ROI image'},...
	{'','c','i'});

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
case 'saveallblobs'                          %- save all blobs to ROIs
%=======================================================================
% marsbar('saveallblobs')
%-----------------------------------------------------------------------
evalin('base','[hReg,SPM,VOL,xX,xCon,xSDM] = spm_results_ui;');
errstr = sprintf(['''Cannot find SPM/VOL structs in the workspace; '...
		  'Please run SPM results GUI''']);
SPM = evalin('base', 'SPM', ['error(' errstr ')']);
M = evalin('base', 'VOL.M', ['error(' errstr ')']);
roipath = spm_get([-1 0], '', 'Directory to save ROIs');
if isempty(roipath)
  return
end
rootn = marsbar('str2fname', SPM.title);
rootn = spm_input('Root name for clusters', '+1', 's', rootn);

pre_ones = ones(1, size(SPM.XYZ,2));
clusters = spm_clusters(SPM.XYZ);
[N Z maxes A] = spm_max(SPM.Z,SPM.XYZ);
for c = unique(A)
  % maximum maximum for this cluster
  tmp = Z; tmp(A~=c) = -Inf; 
  [tmp mi] = max(tmp);
  % voxel coordinate of max
  vco = maxes(:, mi);
  % in mm
  maxmm = M * [vco; 1];
  maxmm = maxmm(1:3);
  % corresponding cluster in spm_clusters, XYZ for cluster
  my_c = clusters(all(SPM.XYZ == vco * pre_ones));
  XYZ = SPM.XYZ(:, clusters == my_c(1));
  if ~isempty(XYZ)
    % file name and labels
    d = sprintf('%s cluster at [%0.1f %0.1f %0.1f]', rootn, maxmm);
    l = sprintf('%s_%0.0f_%0.0f_%0.0f', rootn, maxmm);
    fname = maroi('filename', fullfile(roipath, l));
    o = maroi_pointlist(struct('XYZ',XYZ,'mat',M,'descrip',d, 'label', ...
			       l), 'vox');
    fprintf('\nSaving %s as %s...', d, fname);
    saveroi(o, fname);
  end
end
fprintf('\nDone...\n');

%=======================================================================
case 'saveroi'                                  %-save roi
%=======================================================================
% o = marsbar('saveroi', obj)
%-----------------------------------------------------------------------
if nargin < 2 | isempty(varargin{2})
  return
end

o = varargin{2};
varargout = {[]};
fn = source(o);
if isempty(fn)
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
  d = spm_input('Description of ROI', '+1', 's', descrip(o));
  o = descrip(o,d);
  l = spm_input('Label for ROI', '+1', 's', func);
  o = label(o,l);
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
d = spm_input('Description of ROI', '+1', 's', ['LR flip - ' descrip(o)]);
o = descrip(o,d);
l = spm_input('Label for ROI', '+1', 's', ['flip_lr_' label(o)]);
o = label(o,l);
o = marsbar('saveroi', o); 
fprintf('\nSaved ROI as %s\n', source(o));

%=======================================================================
case 'set_results'                                  %-set results
%=======================================================================
% donef = marsbar('set_results', spm_name, xcon_name)
%-----------------------------------------------------------------------
if nargin < 2 
  spm_name = spm_get([0 1], 'mars_estimated.mat', 'Select results file');
else
  spm_name = varargin{2};
end
if nargin < 3
  xcon_name = '';
else
  xcon_name = varargin{3};
end

varargout = {0};
if isempty(spm_name),return,end
if ~exist(spm_name, 'file')
  error(['Results file ' spm_name ' does not appear to exist']);
end
MARSBAR.estim = load(spm_name);
MARSBAR.estim.swd = fileparts(spm_name);
MARSBAR.estim.file = spm_name;

% get default xcon file name
if isempty(xcon_name)
  pn = fileparts(spm_name);
  xcon_name = fullfile(pn, 'mars_xCon.mat');
  if ~exist(xcon_name, 'file')
    warning(['Default xCon file ' xcon_name ' does not exist']);
    xcon_name = '';
  end
end

marsbar('set_contrasts', xcon_name);

MARSBAR_RESULTS.region = [];
varargout = {1};
return

%=======================================================================
case 'set_contrasts'                                  %-set contrasts
%=======================================================================
% donef = marsbar('set_contrasts', xcon_name)
%-----------------------------------------------------------------------
if nargin < 2 
  xcon_name = '';
else
  xcon_name = varargin{2};
end
varargout = {0};
if isempty(xcon_name)
  xcon_name = spm_get([0 1], 'xCon.mat', 'Select contrast file');
  if isempty(xcon_name), return, end
end

% save and wipe any previous xCons
marsbar('save_xcon');
MARSBAR.contrasts = [];

% get new contrasts
load(xcon_name);
MARSBAR.contrasts.xCon = xCon;
MARSBAR.contrasts.startlength = length(xCon);

% can write to this directory?
donef = 0;
while ~donef
  try
    save(xcon_name, 'xCon')
    donef = 1;
  catch
    spm('alert*', 'Cannot save contrast file in directory', ['Contrasts' ...
		    ' cannot be saved']);
    [pn fn ext] = fileparts(xcon_name);
    newdir = spm_get([0 -1], 'x*on.mat', 'New directory (Done for none)');
    if isempty(newdir)
      xcon_name = '';
      spm('alert*', 'New contrasts will not be saved', ['No writeable' ...
		    ' directory']);
      donef = 1;
    else
      xcon_name = fullfile(newdir, [fn ext]);
    end
  end
end
MARSBAR.contrasts.file = xcon_name;

MARSBAR.region = [];
varargout = {donef};
return

%=======================================================================
case 'set_defcon'                                  %-set default contrast
%=======================================================================
% donef = marsbar('set_defcon')
%-----------------------------------------------------------------------
varargout = {0};
if isempty(MARSBAR.estim)
  if ~marsbar('set_results'), return, end
end
if isempty(MARSBAR.contrasts)
  if ~marsbar('set_contrasts'), return, end
end
[defcon xCon] = spm_conman(MARSBAR.estim.xX,...
			   MARSBAR.contrasts.xCon,'T|F',1,...
			 'Select default contrast','',1);
MARSBAR.contrasts.defcon = defcon;
MARSBAR.contrasts.xCon = xCon;
varargout = {1};

%=======================================================================
case 'set_defregion'                                  %-set default region
%=======================================================================
% donef = marsbar('set_defregion')
%-----------------------------------------------------------------------
varargout = {0};
if isempty(MARSBAR.estim)
  if ~marsbar('set_results'), return, end
end
MARSBAR.region = mars_get_region(MARSBAR.estim.marsY.cols);
varargout = {1};

%=======================================================================
case 'save_xcon'                                  %-save xcon file
%=======================================================================
% marsbar('save_xcon')
%-----------------------------------------------------------------------
if is_there(MARSBAR, 'contrasts', 'xCon') &  ...
      is_there(MARSBAR.contrasts, 'startlength') & ...
      is_there(MARSBAR.contrasts, 'file') & ...
      length(MARSBAR.contrasts.xCon) > MARSBAR.contrasts.startlength
  
  xCon = MARSBAR.contrasts.xCon;
  try
    save(MARSBAR.contrasts.file, 'xCon');
    MARSBAR.contrasts.startlength = length(MARSBAR.contrasts.xCon);
    fprintf('New contrasts saved to file %s\n', MARSBAR.contrasts.file);
  catch
    warning(['Failed to save xCon matrix to ' ...
	    MARSBAR.contrasts.file]);
  end
end

%=======================================================================
case 'set_defregion'                                  %-set default region
%=======================================================================
% donef = marsbar('set_defregion')
%-----------------------------------------------------------------------
varargout = {0};
if isempty(MARSBAR.estim)
  if ~marsbar('set_results'), return, end
end
MARSBAR.region = mars_get_region(MARSBAR.estim.marsY.cols);
varargout = {1};

%=======================================================================
case 'spm_graph'                                  %-run spm_graph
%=======================================================================
% [Y,y,beta,SE] =  marsbar('spm_graph')
%-----------------------------------------------------------------------
varargout = {};
if ~is_there(MARSBAR, 'estim')
  if ~marsbar('set_results'), return, end
end
if ~is_there(MARSBAR, 'region')
  if ~marsbar('set_defregion'), return, end
end
[Y,y,beta,SE,cbeta] = mars_spm_graph(MARSBAR.estim, MARSBAR.contrasts.xCon, ...
		       MARSBAR.region);
varargout = {Y, y, beta, SE, cbeta};

%=======================================================================
case 'stat_table'                                  %-run stat_table
%=======================================================================
% marsS =  marsbar('stat_table')
%-----------------------------------------------------------------------
varargout = {};
if ~is_there(MARSBAR, 'estim')
  if ~marsbar('set_results'), return, end
end
[varargout{1} MARSBAR.contrasts.xCon] = ... 
    mars_stat_table(MARSBAR.estim, MARSBAR.contrasts.xCon);

%=======================================================================
case 'merge_xcon'                                  %-import contrasts
%=======================================================================
% marsbar('merge_xcon')
%-----------------------------------------------------------------------
if ~is_there(MARSBAR, 'estim')
  if ~marsbar('set_results'), return, end
end
MARSBAR.contrasts.xCon = mars_merge_xcon(...
    MARSBAR.estim.xX, MARSBAR.contrasts.xCon);

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
   swd    = spm_str_manip(spmmat,'H');
   spmmat = load(spmmat);
   spmmat.swd = swd;
 elseif isstruct(spmmat)
   if isfield(spmmat,'swd')
     swd = spmmat.swd;
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
 
 varargout = {spmmat, swd};

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

my_task = char(...
    spm_input(pstr, '+1', 'm',...
	      {optlabs{:} 'Quit'},...
	      {optfields{:} 'quit'},length(optfields)+1));
if strcmp(my_task, 'quit'), return, end
task_no = find(strcmp(my_task, optfields));
marsbar(my_task, optlabs{task_no});

%=======================================================================
otherwise                                        %-Unknown action string
%=======================================================================
error('Unknown action string')

%=======================================================================
end
return