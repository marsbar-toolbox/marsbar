function D = fill_design(D, actions)
% fills missing entries from SPM FMRI design matrix 
% FORMAT D = fill_design(D, actions)
% 
% D          - mardo object containing spm design
% actions    - string or cell array of strings with actions:
%            'defaults' - fills empty parts of design with defaults
%            (in fact this is always done)
%            'filter'  - asks for and fills filter, autocorrelation 
%            'images'  - asks for and fills with images, mask, scaling
%
% Returns
% D         - returned mardo SPM design
%
% Copied/pasted then rearranged from SPM99 spm_fmri_spm_ui
% Matthew Brett - 17/11/01 - MRS2TH
%
% $Id$

if nargin < 2
  actions = '';
end
if isempty(actions), actions = {'defaults'}; end
if ischar(actions), actions = {actions}; end
actions = [{'defaults'}, actions];
actions = unique(actions);

% Get design, put into some useful variables
spmD = des_struct(D);
xX = spmD.xX;
if isfield(spmD, 'Sess')
  have_sess = 1;
  Sess = spmD.Sess;
else
  have_sess = 0;
end
try 
  RT     = xX.RT;
catch
  RT  = spm_input('Interscan interval {secs}','+1','batch',{},'RT');
  spmD.xX.RT = RT;
end

% get file indices
%---------------------------------------------------------------
row = block_rows(D);
nsess  = length(row);
nscan  = zeros(1,nsess);
for  i = 1:nsess
  nscan(i) = length(row{i});
end

for a = 1:length(actions)
  switch lower(actions{a})
   case 'defaults'
    % prepare various default settings, offer to design
    xM = [];             % masking 
    xGX = [];            % globals
    sGXcalc  = 'none';   % global calculation description
    sGMsca   = 'none';   % grand mean scaling description
    Global = 'none';     % proportional scaling or no
 
    BFstr = ''; DSstr = ''; ntr = [];
    if have_sess
      BFstr  = Sess{1}.BFstr;
      DSstr  = Sess{1}.DSstr;
      if ~length(xX.iC)
	DSstr = 'Block [session] effects only';
      end
      
      % Number of trial types per session
      for i = 1:length(Sess)
	ntr(i) = length(Sess{i}.name);
      end
    end
    
    xsDes = struct( 'Design',			DSstr,...
		    'Basis_functions',		BFstr,...
		    'Number_of_sessions',	sprintf('%d',nsess),...
		    'Conditions_per_session',	sprintf('%-3d',ntr),...
		    'Interscan_interval',	sprintf('%0.2f',RT),...
		    'Global_calculation',	sGXcalc,...
		    'Grand_mean_scaling',	sGMsca,...
		    'Global_normalisation',	Global);

    if isfield(spmD, xsDes)
      xsDes = mars_struct('fillafromb', spmD.xsDes, xsDes);
    end
    
    spmD.xsDes = xsDes;
    spmD = mars_struct('merge', spmD, ...
		       struct('xGX', xGX,...
			      'xM',  xM));
			      
   case 'images'
    [Finter,Fgraph,CmdLine] = spm('FnUIsetup','fMRI stats model setup',0);
    % select images into matrix P
    P = '';
    if nsess < 16
      for i = 1:nsess
	str = sprintf('select scans for session %0.0f',i);
	q = spm_get(nscan(i),mars_veropts('get_img_ext'),str);
	P   = strvcat(P,q);
      end
    else
      str   = sprintf('select scans for this study');
      P     = spm_get(sum(nscan),mars_veropts('get_img_ext'),str);
    end
    
    % Assemble other design parameters
    %=======================================================================
    spm_help('!ContextHelp',mfilename)
    spm_input('Global intensity normalisation...',1,'d',mfilename);
    
    % Global normalization
    %-----------------------------------------------------------------------
    str    = 'remove Global effects';
    Global = spm_input(str,'+1','scale|none',{'Scaling' 'None'});
    if ischar(Global),
      Global = {Global};
    end

    % finish GUI
    spm('Pointer','Arrow')

    % get file identifiers and Global values
    %=======================================================================
    fprintf('%-40s: ','Mapping files')                                   %-#
    VY     = spm_vol(P);
    fprintf('%30s\n','...done')                                          %-#
    
    if any(any(diff(cat(1,VY.dim),1,1),1)&[1,1,1,0])
      error('images do not all have the same dimensions')
    end
    if any(any(any(diff(cat(3,VY.mat),1,3),3)))
      error('images do not all have same orientation & voxel size')
    end
	
    %-Compute Global variate
    %-------------------------------------------------------------------
    GM     = 100;
    q      = sum(nscan);
    g      = zeros(q,1);
    fprintf('%-40s: %30s','Calculating globals',' ');                     
    for i  = 1:q
      fprintf('%s%30s',sprintf('\b')*ones(1,30),sprintf('%4d/%-4d',i,q));
      g(i) = spm_global(VY(i));
    end
    fprintf('%s%30s\n',sprintf('\b')*ones(1,30),'...done')             
    
    % scale if specified (otherwise session specific grand mean scaling)
    %------------------------------------------------------------------
    gSF     = GM./g;
    if strcmp(Global,'None')
      for i = 1:nsess
	j      = row{i};
	gSF(j) = GM./mean(g(j));
      end
    end
    
    %-Apply gSF to memory-mapped scalefactors to implement scaling
    %---------------------------------------------------------------
    for  i = 1:q, VY(i).pinfo(1:2,:) = VY(i).pinfo(1:2,:)*gSF(i); end
    
    sGXcalc  = 'mean voxel value';
    sGMsca   = 'session specific';
    
    %-Masking structure
    %---------------------------------------------------------------
    xM     = struct('T',	ones(q,1),...
		    'TH',	g.*gSF,...
		    'I',	0,...
		    'VM',	{[]},...
		    'xs',	struct('Masking','analysis threshold'));
    
    % Global structure
    xGX.iGXcalc  = Global{1};
    xGX.sGXcalc  = sGXcalc;
    xGX.rg       = g;
    xGX.sGMsca   = sGMsca;
    xGX.GM       = GM;
    xGX.gSF      = gSF;
    
    xsDes = struct(...
	'Global_calculation',		sGXcalc,...
	'Grand_mean_scaling',		sGMsca,...
	'Global_normalisation',		Global);
	  
    spmD.xsDes = mars_struct('ffillmerge',...
			     spmD.xsDes,...
			     xsDes);
    spmD = mars_struct('ffillmerge', ...
		       spmD,...
		       struct('xGX', xGX,...
			      'VY',   VY,...
			      'xM',   xM));

   case 'filter'
    % Get filter and autocorrelation options
    if ~have_sess, return, end
    
    [Finter,Fgraph,CmdLine] = spm('FnUIsetup','fMRI stats model setup',0);
    
    % Temporal filtering
    %=======================================================================
    spm_input('Temporal autocorrelation options','+1','d',mfilename)
    
    [K HFstr LFstr] = get_filter(RT, Sess);
    
    % intrinsic autocorrelations (Vi)
    %-----------------------------------------------------------------------
    str     = 'Model intrinsic correlations?';
    cVimenu = {'none','AR(1)'};
    cVi     = spm_input(str,'+1','b',cVimenu);
    
    % finish GUI
    spm('Pointer','Arrow')
    
    % Construct K and Vi structs
    %=======================================================================
    K       = spm_filter('set',K);
        
    % create Vi struct
    %-----------------------------------------------------------------------
    Vi      = speye(sum(nscan));
    xVi     = struct('Vi',Vi,'Form',cVi);
    for   i = 1:nsess
      xVi.row{i} = row{i};
    end
    
    % fill into design
    xsDes = struct(...
	'Intrinsic_correlations',	xVi.Form,...
	'High_pass_Filter',             LFstr,...
	'Low_pass_Filter',              HFstr);

    spmD.xsDes = mars_struct('ffillmerge',...
			     spmD.xsDes,...
			     xsDes);
    spmD.xX.xVi = xVi;
    spmD.K = K;
    
   case 'fcontrasts'
    
    [Finter,Fgraph,CmdLine] = spm('FnUIsetup','fMRI stats model setup',0);
    
    %-Generate default trial-specific F-contrasts specified by session?
    %-----------------------------------------------------------------------
    bFcon = spm_input('Setup trial-specific F-contrasts?','+1','y/n',[1,0],1);

    % finish GUI
    spm('Pointer','Arrow')
    
    spmD = my_fcons(spmD, bFcon) ;
    
   otherwise
    error(['Unpredictable: ' actions{a}]);
  end
end

% put stuff into object
o = des_struct(D,spmD);