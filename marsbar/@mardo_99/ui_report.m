function varargout = ui_report(D, varargin)
% mathod for SPM99 design reporting
%
% Copied with minor edits from:  
% @(#)spm_DesRep.m	2.22 Andrew Holmes 01/03/14
% 
% See that file for detailed commentary
%
% $Id$

%-Format arguments
%-----------------------------------------------------------------------
if nargin < 2
  action = 'desrepui'; 
else
  action = varargin{1};
end

%-Generic CallBack code
%-----------------------------------------------------------------------
cb = 'tmp = get(findobj(''Tag'', ''DesRepUI''),''UserData''); ';

% simplify access to design
SPM = des_struct(D);

% Add empty fields where necessary
try
  SPM.xC;
catch
  SPM.xC = {};
end
try
  SPM.xsDes;
catch
  SPM.xsDes = [];
end

switch lower(action)

%=======================================================================
case 'desrepui'                                    %-Design reporting UI
%=======================================================================
% h = spm_DesRep('DesRepUI')
% h = spm_DesRep('DesRepUI',D)

%-Table of variable availability
%-----------------------------------------------------------------------
%		SPM_fMRIDesMtx.mat	SPMcfg.mat	SPM.mat
%  .xX		v/			v/		v/
%  .VY		x			v/		v/
%  .xM		x			v/		v/
%  .F_iX0	x			v/		v/
%  .xC		x / []			v/(p)		v/(p)
%  .Sess	v/			v/(f)		v/(f)
%  .xsDes	x			v/		v/
%
%  .SPMid
%
%  .cfg

%-Add a scaled design matrix to the design data structure
%-----------------------------------------------------------------------
if ~isfield(SPM.xX,'nKX'), SPM.xX.nKX = spm_DesMtx('Sca',SPM.xX.X,SPM.xX.Xnames); end

% put back into design object
D = des_struct(D, SPM);

%-Draw menu
%=======================================================================

%-Get Interactive window and delete any previous DesRepUI menu
%-----------------------------------------------------------------------
Finter = spm_figure('GetWin','Interactive');
delete(findobj(get(Finter,'Children'),'flat','Tag','DesRepUI'))

%-Draw top level menu
%-----------------------------------------------------------------------
hC      = uimenu(Finter,'Label','Design',...
		'Separator','on',...
		'Tag','DesRepUI',...
		'UserData',D,...
		'HandleVisibility','on');

%-DesMtx (SPM & SPMcfg)
%-----------------------------------------------------------------------
hDesMtx = uimenu(hC,'Label','Design Matrix','Accelerator','D',...
		'CallBack',[cb,...
		'ui_report(tmp, ''DesMtx'')'],...
		'UserData',hC,...
		'HandleVisibility','off');

%-Design matrix orthogonality
%-----------------------------------------------------------------------
h = uimenu(hC,'Label','Design orthogonality','Accelerator','O',...
		'CallBack',[cb,...
		'ui_report(tmp, ''DesOrth'')'],...
		'UserData',hC,...
		'HandleVisibility','off');

%-Explore design
%-----------------------------------------------------------------------
hExplore = uimenu(hC,'Label','Explore','HandleVisibility','off');

switch modality(D)
case 'pet'
	hFnF = uimenu(hExplore,'Label','Files and factors','Accelerator','F',...
		'CallBack',[cb,...
		'ui_report(tmp, ''Files&Factors'')'],...
		'UserData',hC,...
		'HandleVisibility','off');
	hCovs = uimenu(hExplore,'Label','Covariates','Accelerator','C',...
		'CallBack',[cb,...
		'ui_report(tmp, ''Covs'')'],...
		'UserData',hC,...
		'HandleVisibility','off');
	if isempty(SPM.xC), set(hCovs,'Enable','off'), end
case 'fmri'
    for j = 1:length(SPM.Sess)
        h = uimenu(hExplore,'Label',sprintf('Session %.0f ',j),...
            'HandleVisibility','off');
        for k = 1:length(SPM.Sess{j}.name)
            uimenu(h,'Label',SPM.Sess{j}.name{k},...
                 'CallBack',[cb,...
                 sprintf('ui_report_fmri(tmp,%d,%d);',j,k)],...
                 'UserData',hC,...
                 'HandleVisibility','off')
        end
    end
end


%-Clear, Quit, Help
%-----------------------------------------------------------------------
uimenu(hC,'Label','Clear','Accelerator','L','Separator','on',...
	'CallBack','spm_results_ui(''Clear'')',...
	'HandleVisibility','off');
uimenu(hC,'Label','Help','Separator','on',...
	'CallBack','spm_help(''spm_DesRep'')',...
	'HandleVisibility','off');

%-Pop open 'Interactive' window
%-----------------------------------------------------------------------
figure(Finter)

%-Return handle of menu
%-----------------------------------------------------------------------
varargout = {hC};


%=======================================================================
case 'files&factors'                         %-Summarise files & factors
%=======================================================================
% ui_report(D, 'Files&Factors',fnames,I,xC,sF,xs)

fnames  = image_names(D);
I       = SPM.xX.I;
xC      = SPM.xC;
sF      = SPM.xX.sF;
xs      = SPM.xsDes;  %-Structure of description strings

if isempty(fnames)
  fnames = cell(size(SPM.xX.X, 1), 1);
else
  [fnames,CPath] = spm_str_manip(fnames,'c');	%-extract common path
end
nScan          = size(I,1);			%-#images
nVar           = size(fnames,2);		%-Variates
bL             = any(diff(I,1),1); 		%-Multiple factor levels?

%-Get graphics window & window scaling
Fgraph = spm_figure('GetWin','Graphics');
spm_results_ui('Clear',Fgraph,0)
FS     = spm('FontSizes');

%-Display header information
%-----------------------------------------------------------------------
hTax = axes('Position',[0.03,0.85,0.94,0.1],...
	'DefaultTextFontSize',FS(9),...
	'XLim',[0,1],'YLim',[0,1],...
	'Visible','off');

text(0.5,1,'Statistical analysis: Image files & covariates...',...
	'Fontsize',FS(14),'Fontweight','Bold',...
	'HorizontalAlignment','center')

dx1 = 0.05;
dx2 = 0.08;

x = 0; text(x+.02,.1,'image #','Rotation',90)
if bL(4), x=x+dx1; text(x+.01,.1,sF{4},'Rotation',90), end
if bL(3), x=x+dx1; text(x+.01,.1,sF{3},'Rotation',90), end
if bL(2), x=x+dx1; text(x+.01,.1,sF{2},'Rotation',90), end
if bL(1), x=x+dx1; text(x+.01,.1,sF{1},'Rotation',90), end

for j = 1:length(xC)
	n = size(xC(j).rc,2);
	if n>1, tmp=xC(j).cname; else, tmp={xC(j).rcname}; end
	for k=1:n
		x=x+dx2;
		text(x,.1,tmp{k},'Rotation',90,'Interpreter','TeX')
	end
end

x=x+dx2;
text(x,0.65,'Base directory:','FontWeight','Bold')
text(x,0.5,CPath,'FontSize',FS(8))
text(x,0.2,'filename tails...')

line('XData',[0 1],'YData',[0 0],'LineWidth',3,'Color','r')

%-Tabulate file & covariate information
%-----------------------------------------------------------------------
hAx = axes('Position',[0.03,0.05,0.94,0.8],...
	'DefaultTextFontSize',FS(8),...
	'Units','points',...
	'Visible','off');
AxPos = get(hAx,'Position'); set(hAx,'YLim',[0,AxPos(4)])

dy = FS(9); y0 = floor(AxPos(4)) -dy; y  = y0;

for i = 1:nScan

	%-Scan indices
	x = 0; text(x,y,sprintf('%03d',i))
	if bL(4), x=x+dx1; text(x,y,sprintf('%02d',I(i,4))), end
	if bL(3), x=x+dx1; text(x,y,sprintf('%02d',I(i,3))), end
	if bL(2), x=x+dx1; text(x,y,sprintf('%02d',I(i,2))), end
	if bL(1), x=x+dx1; text(x,y,sprintf('%02d',I(i,1))), end

	%-Covariates
	for j = 1:length(xC)
		for k=1:size(xC(j).rc,2)
			x=x+dx2;
			text(x,y,sprintf('%6g',xC(j).rc(i,k)),...
				'HorizontalAlignment','Center')
		end
	end

	%-Filename tail(s) - could be multivariate
	x=x+dx2;
	for j = 1:nVar
		text(x,y,fnames{i,j})
		y=y-dy;
	end

	%-Paginate if necessary
	if y<dy
		text(0.5,0,sprintf('Page %d',spm_figure('#page')),...
			'FontSize',FS(8),'FontAngle','italic')
		spm_figure('NewPage',[hAx;get(hAx,'Children')])
		hAx = axes('Units','points','Position',AxPos,...
			'DefaultTextFontSize',FS(8),'YLim',[0,AxPos(4)],...
			'Visible','off');
		y = y0;
		text(y,0,'continued...','FontAngle','Italic')
	end
end

line('XData',[0 1],'YData',[y y],'LineWidth',3,'Color','r')


%-Display description strings
% (At bottom of current page - hope there's enough room!)
%-----------------------------------------------------------------------
if ~isempty(xs)
	y = y - 2*dy;
	for sf = fieldnames(xs)'
		text(0.3,y,[strrep(sf{1},'_',' '),' :'],...
			'HorizontalAlignment','Right','FontWeight','Bold',...
			'FontSize',FS(9))
		s = getfield(xs,sf{1});
		if ~iscellstr(s), s={s}; end
		for i=1:prod(size(s))
			text(0.31,y,s{i},'FontSize',FS(9))
			y=y-dy;
		end
	end
end

%-Register last page if paginated
if spm_figure('#page')>1
	text(0.5,0,sprintf('Page %d/%d',spm_figure('#page')*[1,1]),...
		'FontSize',FS(8),'FontAngle','italic')
	spm_figure('NewPage',[hAx;get(hAx,'Children')])
end

%-Pop up the Graphics window
%-----------------------------------------------------------------------
figure(Fgraph)



%=======================================================================
case {'desmtx','desorth'} %-Display design matrix / design orthogonality
%=======================================================================
% ui_report(D, 'DesMtx',xX,fnames,xs)
% ui_report(D, 'DesOrth',xX,fnames)

xX      = SPM.xX;
fnames  = image_names(D);

xs      = SPM.xsDes;  %-Structure of description strings

desmtx = strcmp(lower(varargin{1}),'desmtx');


%-Locate DesMtx (X), scaled DesMtx (nX) & get parameter names (Xnames)
%-----------------------------------------------------------------------
if isfield(xX,'xKXs') & ...
		~isempty(xX.xKXs) & isstruct(xX.xKXs)
	iX = 1;
	[nScan,nPar] = size(xX.xKXs.X);
elseif isfield(xX,'X') & ~isempty(xX.X)
	iX = 0;
	[nScan,nPar] = size(xX.X);
else
	error('Can''t find DesMtx in this structure!')
end

if isfield(xX,'nKX') & ~isempty(xX.nKX)
	inX = 1; else, inX = 0; end

if isfield(xX,'Xnames') & ~isempty(xX.Xnames)
	Xnames = xX.Xnames; else, Xnames = {}; end


%-Compute design orthogonality matrix if DesOrth
%-----------------------------------------------------------------------
if ~desmtx
    if iX
	tmp  = sqrt(sum(xX.xKXs.X.^2));
	O    = xX.xKXs.X'*xX.xKXs.X./kron(tmp',tmp);
    	tmp  = sum(xX.xKXs.X);
    else
	tmp  = sqrt(sum(xX.X.^2));
	O    = xX.X'*xX.X./kron(tmp',tmp);
    	tmp  = sum(xX.X);
    end
    tmp = abs(tmp)<eps*1e5;
    bC  = kron(tmp',tmp);
end


%-Display
%=======================================================================

%-Get graphics window & FontSizes
%-----------------------------------------------------------------------
Fgraph = spm_figure('GetWin','Graphics');
spm_results_ui('Clear',Fgraph,0)
FS = spm('FontSizes');


%-Title
%-----------------------------------------------------------------------
hTax = axes('Position',[0.03,0,0.94,1],...
	'DefaultTextFontSize',FS(9),...
	'XLim',[0,1],'YLim',[0,1],...
	'Visible','off');

str='Statistical analysis: Design'; if ~desmtx, str=[str,' orthogonality']; end
text(0.5,0.95,str,'Fontsize',FS(14),'Fontweight','Bold',...
	'HorizontalAlignment','center')

line('Parent',hTax,...
	'XData',[0.3 0.7],'YData',[0.92 0.92],'LineWidth',3,'Color','r')


%-Display design matrix
%-----------------------------------------------------------------------
hDesMtx = axes('Position',[.07 .4 .6 .4]);
if inX		%-Got a scaled DesMtx
	hDesMtxIm = image((xX.nKX + 1)*32);
elseif iX	%-No scaled DesMtx, DesMtx in .xKXs structure
	hDesMtxIm = image((spm_DesMtx('sca',xX.xKXs.X,Xnames) + 1)*32);
else		%-No scaled DesMtx, no .xKXs, DesMtx in .X
	hDesMtxIm = image((spm_DesMtx('sca',xX.X,     Xnames) + 1)*32);
end

STick = ui_report(D, 'ScanTick',nScan,32);
PTick = ui_report(D, 'ScanTick',nPar,32);

set(hDesMtx,'TickDir','out',...
	'XTick',PTick,'XTickLabel','',...
	'YTick',STick,'YTickLabel','')
if desmtx
	xlabel('parameters'), ylabel('images')
else
	set(get(hDesMtx,'Xlabel'),...
		'Position',get(get(hDesMtx,'Ylabel'),'Position'),...
		'Rotation',90')
	xlabel('design matrix')
end

%-Parameter names
if ~isempty(Xnames)
	axes('Position',[.07 .8 .6 .1],'Visible','off',...
		'DefaultTextFontSize',FS(8),'DefaultTextInterpreter','TeX',...
		'XLim',[0,nPar]+0.5)
	for i=PTick, text(i,.05,Xnames{i},'Rotation',90), end
end

%-Filenames
% ( Show at most 32, showing every 2nd/3rd/4th/... as necessary to pair )
% ( down to <32 items. Always show last item so #images is indicated.   )     
if desmtx & ~isempty(fnames)
	axes('Position',[.68 .4 .3 .4],'Visible','off',...
		'DefaultTextFontSize',FS(8),...
		'YLim',[0,nScan]+0.5,'YDir','Reverse')
	for i=STick, text(0,i,spm_str_manip(fnames(i,:),'Ca35')), end
end

%-Setup callbacks to allow interrogation of design matrix
%-----------------------------------------------------------------------
if iX, 	set(hDesMtxIm,'UserData',...
	struct('X',xX.xKXs.X,'Xnames',{Xnames},'fnames',{fnames}))
else, 	set(hDesMtxIm,'UserData',...
	struct('X',xX.X,     'Xnames',{Xnames},'fnames',{fnames}))
end
set(hDesMtxIm,'ButtonDownFcn',[cb 'ui_report(tmp, ''SurfDesMtx_CB'')'])


if desmtx
	%-Parameter estimability/uniqueness
	%---------------------------------------------------------------
	hPEstAx   = axes('Position',[.07 .315 .6 .025],...
			'DefaultTextInterpreter','TeX');
	if iX,	est = spm_SpUtil('IsCon',xX.xKXs);
	else,	est = spm_SpUtil('IsCon',xX.X); end
	hParEstIm = image((est+1)*32);
	set(hPEstAx,...
		'XLim',[0,nPar]+.5,'XTick',[1:nPar-1]+.5,'XTickLabel','',...
		'YLim',[0,1]+.5,'YDir','reverse','YTick',[],...
		'Box','on','TickDir','in','XGrid','on','GridLineStyle','-');
	xlabel('parameter estimability')
	text((nPar+0.5 + nPar/30),1,...
		'(gray \rightarrow \beta not uniquely specified)',...
		'Interpreter','TeX','FontSize',FS(8))
	set(hParEstIm,'UserData',struct('est',est,'Xnames',{Xnames}))
	set(hParEstIm,'ButtonDownFcn',[cb 'ui_report(tmp, ''SurfEstIm_CB'')'])
else
	%-Design orthogonality
	%---------------------------------------------------------------
	hDesO   = axes('Position',[.07 .18 .6 .2]);
	tmp = 1-abs(O); tmp(logical(tril(ones(nPar),-1))) = 1;
	hDesOIm = image(tmp*64);
	
	set(hDesO,'Box','off','TickDir','out',...
		'XaxisLocation','top','XTick',PTick,'XTickLabel','',...
		'YaxisLocation','right','YTick',PTick,'YTickLabel','',...
		'YDir','reverse')
	tmp = [1,1]'*[[0:nPar]+0.5];
	line('Xdata',tmp(1:end-1)','Ydata',tmp(2:end)')

	xlabel('design orthogonality')
	set(get(hDesO,'Xlabel'),'Position',[0.5,nPar,0],...
		'HorizontalAlignment','left',...
		'VerticalAlignment','top')
	set(hDesOIm,...
		'UserData',struct('O',O,'bC',bC,'Xnames',{Xnames}),...
		'ButtonDownFcn',[cb 'ui_report(tmp, ''SurfDesO_CB'')'])

	if ~isempty(Xnames)
		axes('Position',[.69 .18 0.01 .2],'Visible','off',...
			'DefaultTextFontSize',FS(10),...
			'DefaultTextInterpreter','TeX',...
			'YDir','reverse','YLim',[0,nPar]+0.5)
		for i=PTick
			text(0,i,Xnames{i},'HorizontalAlignment','left')
		end
	end

end

%-Design descriptions
%-----------------------------------------------------------------------
if desmtx
	str = 'Design description...';
	line('Parent',hTax,...
		'XData',[0.3 0.7],'YData',[0.28 0.28],'LineWidth',3,'Color','r')
	hAx = axes('Position',[0.03,0.05,0.94,0.22],'Visible','off');
else
	str = '';
	line('Parent',hTax,...
		'XData',[0.3 0.7],'YData',[0.14 0.14],'LineWidth',3,'Color','r')
	hAx = axes('Position',[0.03,0.05,0.94,0.08],'Visible','off');
	xs = struct('Measure',	['abs. value of cosine of angle between ',...
				 'columns of design matrix'],...
		    'Scale',	{{	'black - colinear (cos=+1/-1)';...
					'white - orthogonal (cos=0)';...
					'gray  - not orthogonal or colinear'}});
end


if ~isempty(xs)
	set(hAx,'Units','points');
	AxPos = get(hAx,'Position');
	set(hAx,'YLim',[0,AxPos(4)])
	
	dy = FS(9); y0 = floor(AxPos(4)) -dy; y = y0;

	text(0.3,y,str,...
		'HorizontalAlignment','Center',...
		'FontWeight','Bold','FontSize',FS(11))
	y=y-2*dy;
	
	for sf = fieldnames(xs)'
		text(0.3,y,[strrep(sf{1},'_',' '),' :'],...
			'HorizontalAlignment','Right','FontWeight','Bold',...
			'FontSize',FS(9))
		s = getfield(xs,sf{1});
		if ~iscellstr(s), s={s}; end
		for i=1:prod(size(s))
			text(0.31,y,s{i},'FontSize',FS(9))
			y=y-dy;
		end
	end
end

%-Pop up the Graphics window
%-----------------------------------------------------------------------
figure(Fgraph)


%=======================================================================
case 'covs'                %-Plot and describe covariates (one per page)
%=======================================================================
% ui_report(D, 'Covs',xX,xC)

xX = SPM.xX;
xC = SPM.xC;

if ~length(xC), spm('alert!','No covariates!',mfilename), return, end

%-Get graphics window & window scaling
Fgraph = spm_figure('GetWin','Graphics');
spm_results_ui('Clear',Fgraph,0)
FS = spm('FontSizes');

%-Title
%-----------------------------------------------------------------------
hTax = axes('Position',[0.03,0,0.94,1],...
	'DefaultTextFontSize',FS(9),...
	'XLim',[0,1],'YLim',[0,1],...
	'Visible','off');

text(0.5,0.95,'Statistical analysis: Covariates',...
	'Fontsize',FS(14),'Fontweight','Bold',...
	'HorizontalAlignment','center')

text(0.5,0.82,'(covariates plotted over transposed design matrix)',...
	'FontSize',FS(8),'HorizontalAlignment','center')

line('XData',[0.3 0.7],'YData',[0.92 0.92],'LineWidth',3,'Color','r')
line('XData',[0.3 0.7],'YData',[0.44 0.44],'LineWidth',3,'Color','r')


%-Design matrix (as underlay for plots) and parameter names
%-----------------------------------------------------------------------
[nScan,nPar]   = size(xX.X);
if isfield(xX,'Xnames') & ~isempty(xX.Xnames)
	Xnames = xX.Xnames; else, Xnames = {}; end

%-Design matrix
hDesMtx = axes('Position',[.1 .5 .7 .3]);
if isfield(xX,'nKX') & ~isempty(xX.nKX)
	image(xX.nKX'*32+32)
elseif isfield(xX,'xKXs') & ~isempty(xX.xKXs)
	image(spm_DesMtx('sca',xX.xKXs.X,Xnames)*32+32)
else
	image(spm_DesMtx('sca',xX.X,Xnames)*32+32)
end
set(hDesMtx,'Visible','off')

%-Parameter names
hParAx = axes('Position',[.8 .5 .2 .3],'Visible','off',...
	'DefaultTextFontSize',FS(8),'DefaultTextInterpreter','TeX',...
	'YLim',[0.5,nPar+0.5],'YDir','Reverse');
hPNames = zeros(nPar,1);
for i = 1:nPar, hPNames(i) = text(.05,i,Xnames{i}); end


%-Covariates - one page each
%-----------------------------------------------------------------------
for i = 1:length(xC)

	%-Title
	%---------------------------------------------------------------
	hSTitle = text(0.5,0.87,sprintf('%d : %s',i,xC(i).rcname),...
			'Parent',hTax,...
			'HorizontalAlignment','center',...
			'FontSize',FS(13),'FontWeight','Bold');

	%-Plot
	%---------------------------------------------------------------
	hAx = axes('Position',[.1 .5 .7 .3],...
			'TickDir','out','Box','off','Color','none',...
			'NextPlot','add',...
			'XLim',[0,nScan]+0.5);
	plot(xC(i).rc,'LineWidth',2)
	if nScan<48, plot(xC(i).rc,'.k','MarkerSize',20); end
	xlabel('image #')
	ylabel('covariate value')


	%-Descriptions
	%---------------------------------------------------------------
	hDAx = axes('Position',[0.03,0.1,0.94,0.30],'Visible','off');
	
	set(hDAx,'Units','points');
	tmp = get(hDAx,'Position');
	set(hDAx,'YLim',[0,tmp(4)])
	
	dy = FS(9); y0 = floor(tmp(4)) -dy; y = y0;

	%-Description strings from xC(i).descrip
	text(0.3,y,'Details :',...
		'HorizontalAlignment','Right',...
		'FontWeight','Bold','FontSize',FS(9))
	s = xC(i).descrip;
	if ~iscellstr(s), s={s}; end
	for j=1:prod(size(s))
		text(0.31,y,s{j},'FontSize',FS(9))
		y=y-dy;
	end
	y=y-dy;

	%-Key (if block of covariates entered)
	%---------------------------------------------------------------
	if size(xC(i).rc,2)>1
		ColorOrder = get(hAx,'ColorOrder');
		text(0.3,y,'Key :',...
			'HorizontalAlignment','Right',...
			'FontWeight','Bold','FontSize',FS(9))
		for j = 1:size(xC(i).rc,2)
			color = ColorOrder(mod(j-1,size(ColorOrder,1))+1,:);
			if size(xC(i).rc,2)==length(xC(i).cname)
				str = xC(i).cname{j};
			else
				str = sprintf('column %d',j);
			end
			text(0.31,y,str,'FontSize',FS(9),...
				'Color',color)
			text(0.5,xC(i).rc(1,j),[str,' \rightarrow'],...
				'Parent',hAx,...
				'FontSize',FS(8),'FontWeight','Bold',...
				'HorizontalAlignment','Right',...
				'Interpreter','TeX',...
				'Color',color)
			y=y-dy;
		end
		y=y-dy;
	end


	%-Associated parameters
	%---------------------------------------------------------------
	text(0.3,y,'Design matrix columns :',...
		'HorizontalAlignment','Right',...
		'FontWeight','Bold','FontSize',FS(9))
	if isempty(xC(i).cols)
		text(0.31,y,'(none)','FontSize',FS(9))
	else
		for j = xC(i).cols
			text(0.31,y,sprintf('%d : %s',j,Xnames{j}),...
				'FontSize',FS(9),'Interpreter','TeX')
			y=y-dy;
		end
	end
	y=y-dy;


	%-Highlight parameter names
	%---------------------------------------------------------------
	hCurPNames = hPNames(xC(i).cols);
	set(hCurPNames,'Color','r','FontWeight','Bold','FontSize',FS(8))


	%-Paginate (if more than one covariate)
	%---------------------------------------------------------------
	if length(xC)>1
		spm_figure('NewPage',[hSTitle; hAx; get(hAx,'Children');...
			hCurPNames; hDAx; get(hDAx,'Children')]);
	end

end

%-Pop up the Graphics window
%-----------------------------------------------------------------------
figure(Fgraph)


%=======================================================================
case 'scantick'
%=======================================================================
% ui_report(D, 'ScanTick',nScan,lim)
% ( Show at most 32, showing every 2nd/3rd/4th/... as necessary to pair )
% ( down to <32 items. Always show last item so #images is indicated.    )     
if nargin<4, lim=32; else, lim=varargin{3}; end
if nargin<3, error('insufficient arguments'), end
nScan = varargin{2};

p = max(1,ceil(nScan/lim));
s = 1:p:nScan; s(end)=nScan;

varargout = {s,lim};


%=======================================================================
case {'surfdesmtx_cb','surfdesmtxmo_cb','surfdesmtxup_cb'} %-Surf DesMtx
%=======================================================================
% ui_report(D, 'SurfDesMtx_CB')
% ui_report(D, 'SurfDesMtxMo_CB')
% ui_report(D, 'SurfDesMtxUp_CB')

h    = get(gca,'Xlabel');

if strcmp(lower(varargin{1}),'surfdesmtxup_cb')
	UD = get(h,'UserData');
	set(h,'String',UD.String,'Interpreter',UD.Interpreter,...
		'UserData',UD.UserData)
	set(gcbf,'WindowButtonMotionFcn','','WindowButtonUpFcn','')
	return
end


if strcmp(lower(varargin{1}),'surfdesmtx_cb')
	UD = struct(	'String',	get(h,'String'),...
			'Interpreter',	get(h,'Interpreter'),...
			'UserData',	get(h,'UserData'));
	set(h,'UserData',UD)
	set(gcbf,'WindowButtonMotionFcn',[cb 'ui_report(tmp, ''SurfDesMtxMo_CB'')'],...
		 'WindowButtonUpFcn',    [cb 'ui_report(tmp, ''SurfDesMtxUp_CB'')'])
end

mm  = [get(gca,'YLim')',get(gca,'XLim')']+[.5,.5;-.5,-.5];
ij  = get(gca,'CurrentPoint');
ij  = round(min(max(ij(1,[2,1]),mm(1,:)),mm(2,:)));

istr = 'none';
switch get(gcbf,'SelectionType')
case 'normal'
	try, str = sprintf('X(%d,%d) = %g',ij(1),ij(2),...
		subsref(get(gco,'UserData'),...
		struct('type',{'.','()'},'subs',{'X',{ij(1),ij(2)}})));
	catch, str='(no cached design matrix to surf)'; end
case 'extend'
	try, str = sprintf('Image %d: %s',ij(1),...
		spm_str_manip(...
		subsref(get(gco,'UserData'),...
		struct('type',{'.','()'},...
			'subs',{'fnames',{ij(1),':'}})),'Ca40'));
	catch, str='(no cached image filenames to surf)'; end
case 'alt'
	try, str = sprintf('Parameter %d: %s',ij(2),...
		subsref(get(gco,'UserData'),...
		struct('type',{'.','{}'},'subs',{'Xnames',{ij(2)}})));
		istr = 'tex';
	catch, str='(no cached parameter names to surf)'; end
case 'open'
	try,	assignin('base','ans',subsref(get(gco,'UserData'),...
			struct('type',{'.'},'subs',{'X'})))
		evalin('base','ans')
	catch,	fprintf('%s GUI: can''t find design matrix\n',mfilename)
	end
	return
end

set(h,'String',str,'Interpreter',istr)


%=======================================================================
case {'surfestim_cb','surfestimmo_cb','surfestimup_cb'}  %-Surf ParEstIm
%=======================================================================
% ui_report(D, 'SurfEstIm_CB')
% ui_report(D, 'SurfEstImMo_CB')
% ui_report(D, 'SurfEstImUp_CB')

h    = get(gca,'Xlabel');

if strcmp(lower(varargin{1}),'surfestimup_cb')
	UD = get(h,'UserData');
	set(h,'String',UD.String,'Interpreter',UD.Interpreter,...
		'UserData',UD.UserData)
	set(gcbf,'WindowButtonMotionFcn','','WindowButtonUpFcn','')
	return
end

if strcmp(lower(varargin{1}),'surfestim_cb')
	UD = struct(	'String',	get(h,'String'),...
			'Interpreter',	get(h,'Interpreter'),...
			'UserData',	get(h,'UserData'));
	set(h,'UserData',UD)
	set(gcbf,'WindowButtonMotionFcn',[cb 'ui_report(tmp, ''SurfEstImMo_CB'')'],...
		 'WindowButtonUpFcn',    [cb 'ui_report(tmp, ''SurfEstImUp_CB'')'])
end

mm  = [get(gca,'XLim')]+[.5,-.5];
i   = get(gca,'CurrentPoint');
i   = round(min(max(i(1,1),mm(1)),mm(2)));

istr = 'none';
switch get(gcbf,'SelectionType')
case 'normal'
	try, tmp = {' (not unique)',' (unique)'};
	str = sprintf('Parameter %d : %s%s',...
		i,...
		subsref(get(gco,'UserData'),...
			struct('type',{'.','{}'},'subs',{'Xnames',{i}})),...
		tmp{subsref(get(gco,'UserData'),...
			struct('type',{'.','()'},'subs',{'est',{i}}))+1});
		istr = 'tex';
	catch, str='(no cached data to surf)'; end
case {'extend','alt'}
	return
case 'open'
	try,	UD = get(gco,'UserData');
		assignin('base','ans',...
			subsref(get(gco,'UserData'),...
				struct('type',{'.'},'subs',{'est'})))
		evalin('base','ans')
	catch,	fprintf('%s GUI: can''t find design orthogonality\n',mfilename)
	end
	return
end

set(h,'String',str,'Interpreter',istr)



%=======================================================================
case {'surfdeso_cb','surfdesomo_cb','surfdesoup_cb'}    %-Surf DesOrthIm
%=======================================================================
% ui_report(D, 'SurfDesO_CB')
% ui_report(D, 'SurfDesOMo_CB')
% ui_report(D, 'SurfDesOUp_CB')

h    = get(gca,'Xlabel');

if strcmp(lower(varargin{1}),'surfdesoup_cb')
	UD = get(h,'UserData');
	set(h,'String',UD.String,'Interpreter',UD.Interpreter,...
		'UserData',UD.UserData)
	set(gcbf,'WindowButtonMotionFcn','','WindowButtonUpFcn','')
	return
end

if strcmp(lower(varargin{1}),'surfdeso_cb')
	UD = struct(	'String',	get(h,'String'),...
			'Interpreter',	get(h,'Interpreter'),...
			'UserData',	get(h,'UserData'));
	set(h,'UserData',UD)
	set(gcbf,'WindowButtonMotionFcn',[cb 'ui_report(tmp, ''SurfDesOMo_CB'')'],...
		 'WindowButtonUpFcn',    [cb 'ui_report(tmp, ''SurfDesOUp_CB'')'])
end

mm  = [get(gca,'YLim')',get(gca,'XLim')']+[.5,.5;-.5,-.5];
ij  = get(gca,'CurrentPoint');
ij  = round(min(max(ij(1,[2,1]),mm(1,:)),mm(2,:)));
if ij(1)>ij(2), return, end

istr = 'none';
switch get(gcbf,'SelectionType')
case 'normal'
	try
		UD = get(gco,'UserData');
		if abs(abs(UD.O(ij(1),ij(2)))-1) < eps*1e1
		 	str = '{\bf colinear}';
		elseif abs(UD.O(ij(1),ij(2))) < eps*1e1
			str = '{\bf orthogonal}';
		else
			str = '{\bf not orthogonal}';
		end
		if ~diff(ij), str=[str,' {\it(same column)}']; end
		if UD.bC(ij(1),ij(2)), tmp=' ={\it r}'; else, tmp=''; end
		str = {	sprintf('{\\bf %s} (col %d) & {\\bf %s} (col %d)',...
				UD.Xnames{ij(1)},ij(1),...
				UD.Xnames{ij(2)},ij(2)),...
			sprintf('cos(\\theta)%s = %1.2f',...
				tmp,UD.O(ij(1),ij(2))),...
			['\rightarrow ',str]};
		istr = 'tex';
	catch, str='(no cached data to surf)'; end
case {'extend','alt'}
	return
case 'open'
	try,	UD = get(gco,'UserData');
		assignin('base','ans',UD.O)
		evalin('base','ans')
	catch,	fprintf('%s GUI: can''t find design orthogonality\n',mfilename)
	end
	return
end

set(h,'String',str,'Interpreter',istr)


%=======================================================================
case {'surfcon_cb','surfconmo_cb','surfconup_cb'}        %-Surf Contrast
%=======================================================================
% ui_report(D, 'SurfCon_CB')
% ui_report(D, 'SurfConOMo_CB')
% ui_report(D, 'SurfConOUp_CB')

cUD = get(gco,'UserData');
if ~isstruct(cUD) | ~isfield(cUD,'h')
	warning('contrast GUI objects setup incorrectly'), return
end
h    = cUD.h;

if strcmp(lower(varargin{1}),'surfconup_cb')
	UD = get(h,'UserData');
	set(h,'String',UD.String,'Interpreter',UD.Interpreter,...
		'UserData',UD.UserData)
	set(gcbf,'WindowButtonMotionFcn','','WindowButtonUpFcn','')
	return
end

if strcmp(lower(varargin{1}),'surfcon_cb')
	UD = struct(	'String',	get(h,'String'),...
			'Interpreter',	get(h,'Interpreter'),...
			'UserData',	get(h,'UserData'));
	set(h,'UserData',UD)
	set(gcbf,'WindowButtonMotionFcn',[cb 'ui_report(tmp, ''SurfConMo_CB'')'],...
		 'WindowButtonUpFcn',    [cb 'ui_report(tmp, ''SurfConUp_CB'')'])
end

mm  = [get(gca,'YLim')',get(gca,'XLim')']+[.5,.5;-.5,-.5];
ij  = get(gca,'CurrentPoint');
ij  = round(min(max(ij(1,[2,1]),mm(1,:)),mm(2,:)));

istr = 'none';
switch get(gcbf,'SelectionType')
case 'normal'
	try
		if cUD.i>0, str = sprintf('%d',cUD.i); else, str = ''; end
		switch get(gco,'Type')
		case 'image'
			str = sprintf('%s\\{F\\}: {\\bf%s} (%d,%d) = %.2f',...
				str,cUD.xCon.name,ij(2),ij(1),...
				cUD.xCon.c(ij(2),ij(1)));
		case 'patch'
			str = sprintf('%s\\{T\\}: {\\bf%s} (%d) = %.2f',...
				str,cUD.xCon.name,ij(2),...
				cUD.xCon.c(ij(2)));
		otherwise, error('unexpected object type')
		end
		istr = 'TeX';
	catch, str='(no cached data to surf)'; end
case {'alt','extend'}
	return
case 'open'
	try,	assignin('base','ans',cUD.xCon.c')
		evalin('base','ans')
	catch,	fprintf('%s GUI: can''t find contrast\n',mfilename)
	end
	return
end

set(h,'String',str,'Interpreter',istr)


%=======================================================================
otherwise                                        %-Unknown action string
%=======================================================================
error(['Unknown action string: ',varargin{1}])



%=======================================================================
end
