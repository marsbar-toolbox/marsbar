function D = fill(D, actions)
% fills missing entries from SPM FMRI design matrix 
% FORMAT D = fill(D, actions)
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
% Copied/pasted then rearranged from SPM2 spm_fmri_spm_ui
% Matthew Brett - 17/11/01 - MRS2TH
%
% $Id$

if nargin < 2
  actions = '';
end
if ~is_fmri(D), return, end
if isempty(actions), actions = {'defaults'}; end
if ischar(actions), actions = {actions}; end
actions = [{'defaults'}, actions];
actions = unique(actions);

% Get design, put into some useful variables
v_f = verbose(D);
SPM = des_struct(D);
xX  = SPM.xX;
have_sess = isfield(SPM, 'Sess');
if have_sess, Sess = SPM.Sess; end

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
      % Number of trial types per session
      for i     = 1:nsess, ntr(i) = length(SPM.Sess(i).U); end
      BFstr = SPM.xBF.name;
    end
    
    xsDes = struct(...
	'Basis_functions',	BFstr,...
	'Number_of_sessions',	sprintf('%d',nsess),...
	'Trials_per_session',	sprintf('%-3d',ntr),...
	'Global_calculation',	sGXcalc,...
	'Grand_mean_scaling',	sGMsca,...
	'Global_normalisation',	Global);

    if isfield(SPM, xsDes)
      xsDes = mars_struct('fillafromb', SPM.xsDes, xsDes);
    end
    
    SPM.xsDes = xsDes;
    SPM = mars_struct('merge', SPM, ...
		       struct('xGX', xGX,...
			      'xM',  xM));
			      
   case 'images'
    [Finter,Fgraph,CmdLine] = spm('FnUIsetup','fMRI stats model setup',0);
    % get filenames
    %---------------------------------------------------------------
    P     = [];
    for i = 1:nsess
      str = sprintf('select scans for session %0.0f',i);
      q   = spm_get(nscan(i),'.img',str);
      P   = strvcat(P,q);
    end
    
    % place in data field
    %---------------------------------------------------------------
    SPM.xY.P = P;
    
    % Assemble remaining design parameters
    %=======================================================================
    
    % Global normalization
    %-----------------------------------------------------------------------
    spm_input('Global intensity normalisation...',1,'d',mfilename)
    str             = 'remove Global effects';
    SPM.xGX.iGXcalc = spm_input(str,'+1','scale|none',{'Scaling' 'None'});
    SPM.xGX.sGXcalc = 'mean voxel value';
    SPM.xGX.sGMsca  = 'session specific';
    
    % Assemble other design parameters
    %=======================================================================
    spm_help('!ContextHelp',mfilename)
    spm_input('Global intensity normalisation...',1,'d',mfilename);
    
    % finish GUI
    spm('Pointer','Arrow')

    % get file identifiers and Global values
    %=======================================================================
    fprintf('%-40s: ','Mapping files')                                   %-#
    VY     = spm_vol(SPM.xY.P);
    fprintf('%30s\n','...done')                                          %-#
    
    %-check internal consistency of images
    %-----------------------------------------------------------------------
    if any(any(diff(cat(1,VY.dim),1,1),1) & [1,1,1,0])
      error('images do not all have the same dimensions')           
    end
    if any(any(any(diff(cat(3,VY.mat),1,3),3)))
      error('images do not all have same orientation & voxel size')
    end
	
    %-place in xY
    %-----------------------------------------------------------------------
    SPM.xY.VY = VY;
    
    %-Compute Global variate
    %=======================================================================
    GM    = 100;
    q     = length(VY);
    g     = zeros(q,1);
    fprintf('%-40s: %30s','Calculating globals',' ')                     %-#
    for i = 1:q
      fprintf('%s%30s',sprintf('\b')*ones(1,30),sprintf('%4d/%-4d',i,q)) %-#
      g(i) = spm_global(VY(i));
    end
    fprintf('%s%30s\n',sprintf('\b')*ones(1,30),'...done')               %-#
    
    % scale if specified (otherwise session specific grand mean scaling)
    %-----------------------------------------------------------------------
    gSF   = GM./g;
    if strcmp(SPM.xGX.iGXcalc,'None')
      for i = 1:nsess
	gSF(SPM.Sess(i).row) = GM./mean(g(SPM.Sess(i).row));
      end
    end
    
    %-Apply gSF to memory-mapped scalefactors to implement scaling
    %-----------------------------------------------------------------------
    for i = 1:q
      SPM.xY.VY(i).pinfo(1:2,:) = SPM.xY.VY(i).pinfo(1:2,:)*gSF(i);
    end
    
    %-place global variates in global structure
    %-----------------------------------------------------------------------
    SPM.xGX.rg    = g;
    SPM.xGX.GM    = GM;
    SPM.xGX.gSF   = gSF;
    
    
    %-Masking structure
    %---------------------------------------------------------------
    SPM.xM     = struct('T',	ones(q,1),...
		    'TH',	g.*gSF,...
		    'I',	0,...
		    'VM',	{[]},...
		    'xs',	struct('Masking','analysis threshold'));
        
    xsDes = struct(...
	'Global_calculation',	SPM.xGX.sGXcalc,...
	'Grand_mean_scaling',	SPM.xGX.sGMsca,...
	'Global_normalisation',	SPM.xGX.iGXcalc);
	  
    SPM.xsDes = mars_struct('ffillmerge',...
			     SPM.xsDes,...
			     xsDes);

   case 'filter'
    % Get filter and autocorrelation options
    if ~have_sess, return, end
    
    [Finter,Fgraph,CmdLine] = spm('FnUIsetup','fMRI stats model setup',0);
    
    % TR if not set (it should be) 
    if ~mars_struct('isthere', SPM, 'xY', 'RT')
      SPM.xY.RT  = spm_input('Interscan interval {secs}','+1');
    end
    RT = SPM.xY.RT;

    % High-pass filtering and serial correlations
    %=======================================================================
    
    % specify low frequnecy confounds
    %---------------------------------------------------------------
    spm_input('Temporal autocorrelation options','+1','d',mfilename)
    [K f_str] = pr_get_filter(SPM.xY.RT, SPM.Sess);
    SPM.xX.K = K;
    
    % intrinsic autocorrelations (Vi)
    %-----------------------------------------------------------------------
    
    % Contruct Vi structure for non-sphericity ReML estimation
    %===============================================================
    str   = 'Correct for serial correlations?';
    cVi   = {'none','AR(1)'};
    cVi   = spm_input(str,'+1','b',cVi);
    
    % create Vi struct
    %-----------------------------------------------------------------------
    switch cVi

     case ~ischar(cVi)	
      % AR coeficient[s] specified
      %---------------------------------------------------------------
      SPM.xVi.Vi = pr_spm_ce(nscan,cVi(1:3));
      cVi        = sprintf('AR(%0.1f)',cVi(1));
      f2cl       = 'V'; 
      
     case 'none'		
      %  xVi.V is i.i.d
      %---------------------------------------------------------------
      SPM.xVi.V  = speye(sum(nscan));
      cVi        = 'i.i.d';
      f2cl       = 'Vi'; 
                  
     otherwise		
      % otherwise assume AR(0.2) in xVi.Vi
      %---------------------------------------------------------------
      SPM.xVi.Vi = pr_spm_ce(nscan,0.2);
      cVi        = 'AR(0.2)';
      f2cl       = 'V'; 
      
    end

    % If we've set V, need to clear Vi, because
    % esimate method takes the presence of Vi to mean that
    % V can be cleared, with 'redo_covar' flag
    % Conversely V needs to be cleared if Vi was estimated
    if isfield(SPM.xVi, f2cl)
      SPM.xVi = rmfield(SPM.xVi, f2cl);
      if v_f, fprintf('Clearing previous %s matrix\n', f2cl); end
    end
    
    % Also: remove previous W matrices
    % Either will need to be recalculated or won't be used
    if isfield(SPM.xX, 'W')
      SPM.xX = rmfield(SPM.xX, 'W');
      if v_f, fprintf('Clearing previous W matrix\n'); end
    end

    
    % fill into design
    SPM.xVi.form = cVi;
    
    xsDes = struct(...
	'Interscan_interval',	sprintf('%0.2f {s}',RT),...
	'Intrinsic_correlations',	SPM.xVi.form,...
	'High_pass_Filter',             str);
    
    SPM.xsDes = mars_struct('ffillmerge',...
			  SPM.xsDes,...
			  xsDes);
  
   otherwise
    error(['Unpredictable: ' actions{a}]);
  end
end

% put stuff into object
D = des_struct(D,SPM);