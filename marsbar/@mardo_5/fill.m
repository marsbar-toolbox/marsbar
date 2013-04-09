function D = fill(D, actions)
% fills missing entries from SPM FMRI design matrix 
% FORMAT D = fill(D, actions)
% 
% D          - mardo object containing spm design
% actions    - string or cell array of strings with actions:
%            'defaults' - fills empty parts of design with defaults
%            (in fact this is always done)
%            'filter'  - asks for and fills filter
%            'autocorr' - asks for and fills autocorrelation 
%            'for_estimation' fill filter &| autocorr if not present
%            'images'  - asks for and fills with images, mask, scaling
%
% Returns
% D         - returned mardo SPM design
%
% Copied/pasted then rearranged from SPM2 spm_fmri_spm_ui
% Matthew Brett - 17/11/01 - MRS2TH
%
% $Id: fill.m 543 2004-12-14 08:58:05Z matthewbrett $

if nargin < 2
  actions = '';
end
if ~is_fmri(D), return, end
if isempty(actions), actions = {'defaults'}; end
if ischar(actions), actions = {actions}; end
fe = find(ismember(actions, 'for_estimation'));
if ~isempty(fe)
  A = [];
  if is_fmri(D)
    if ~has_filter(D), A = {'filter'}; end
    if ~has_autocorr(D), A = [A {'autocorr'}]; end
  end
  actions(fe) = [];
  actions = [actions(1:fe(1)-1) A actions(fe(1):end)];
end
actions = [{'defaults'}, actions];

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

done_list = {};
for a = 1:length(actions)
  if ismember(actions{a}, done_list), continue, end
  done_list = [actions(a) done_list];
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

    if isfield(SPM, 'xsDes')
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
      q   = spm_get(nscan(i),mars_veropts('get_img_ext'),str);
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
    
    % get file identifiers and Global values
    %=======================================================================
    fprintf('%-40s: ','Mapping files')                                   %-#
    VY     = spm_vol(SPM.xY.P);
    fprintf('%30s\n','...done')                                          %-#
    
    %-Check compatability of images
    %-----------------------------------------------------------------------
    [samef msg] = mars_vol_check(VY);
    if ~samef, disp(char(msg)),error('Cannot use images'),end;
	
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
      fprintf('%s%30s',repmat(sprintf('\b'),1,30),sprintf('%4d/%-4d',i,q)) %-#
      g(i) = spm_global(VY(i));
    end
    fprintf('%s%30s\n',repmat(sprintf('\b'),1,30),'...done')               %-#
    
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
    % Get filter 
    if ~have_sess, return, end

    [Finter,Fgraph,CmdLine] = spm('FnUIsetup', 'FMRI model filter', 0);

    % TR if not set (it should be) 
    if ~mars_struct('isthere', SPM, 'xY', 'RT')
      SPM.xY.RT  = spm_input('Interscan interval {secs}','+1');
    end
    SPM.xsDes.Interscan_interval = sprintf('%0.2f {s}',SPM.xY.RT);

    spm_input('High pass filter','+1','d',mfilename)
    [SPM.xX.K SPM.xsDes.High_pass_Filter] = ...
	pr_get_filter(SPM.xY.RT, SPM.Sess);
    
   case 'autocorr'
    [Finter,Fgraph,CmdLine] = ...
	spm('FnUIsetup','FMRI autocorrelation options',0);

    % Contruct Vi structure for non-sphericity ReML estimation
    %===============================================================
    str   = 'Correct for serial correlations?';
    cVi   = {'none', 'SPM AR(0.2)','SPM AR (specify)', 'fmristat AR(n)'};
    cVi   = spm_input(str,'+1','m',cVi, cVi);
    
    % create Vi struct
    %-----------------------------------------------------------------------
    vox_cov_possible = 0;
    switch lower(cVi{1})

     case 'fmristat ar(n)'
      % Fit fmristat model AR(n)
      %---------------------------------------------------------------
      cVi = spm_input('fmristat AR model order', '+1', 'e', 2);
      SPM.xVi.Vi = struct('type', 'fmristat', 'order', cVi);
      cVi        = sprintf('fmristat AR(%d)',cVi);
      f2cl       = 'V'; % Field to CLear
      
     case 'spm ar (specify)'
      % SPM AR coefficient(s) to be specified
      %---------------------------------------------------------------
      cVi = spm_input('AR rho parameter(s)', '+1', 'e', 0.2);
      SPM.xVi.Vi = pr_spm_ce(nscan,cVi);
      cVi        = sprintf('AR(%0.1f)',cVi(1));
      f2cl       = 'V'; 
      vox_cov_possible   = 1;
      
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
      vox_cov_possible   = 1;
      
    end

    % If we've set V, need to clear Vi, because the
    % estimate method takes the presence of Vi to mean that
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
    
    % Whether to average covariance estimates over voxels
    SPM.xVi.cov_calc = 'summary';
    if vox_cov_possible
      if spm_input('Use voxel data for covariance','+1','y/n', [1 0], 1);
	SPM.xVi.cov_calc = 'vox';
      end
    end
    
    % fill into design
    SPM.xVi.form = cVi;
    xsDes = struct('Serial_correlations', SPM.xVi.form);
    SPM.xsDes = mars_struct('ffillmerge', SPM.xsDes, xsDes);
  
   otherwise
    error(['Unpredictable: ' actions{a}]);
  end
end

% put stuff into object
D = des_struct(D,SPM);
