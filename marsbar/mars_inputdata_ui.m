function [spmD, marsY] = mars_inputdata_ui;
% gets model and data from matlab input
%
% $Id$

%-Say hello
%-----------------------------------------------------------------------
[Finter,Fgraph,CmdLine] = spm('FnUIsetup','MarsBar input data and model',0);
    
% get data and column names
marsY.Y = spm_input('Input data (scans x region)', '+1', 'e');  
    
% get model
spmN = spm_get(1, 'SPM*mat', 'Select model');
spmD = load(spmN);
% check there is a design here
if ~isfield(spmD, 'xX')
  error([spmN ' does not appear to contain a valid design']);
end
swd    = spm_str_manip(spmN,'H');
spmD.swd = swd;
% remove large and unused field
if isfield(spmD, 'XYZ')
  rmfield(spmD, 'XYZ');
end

% if no filter etc, fetch now
if ~isfield(spmD.xX, 'K')
  
  % Get filter
  [K LFstr HFstr] = mars_get_filter(spmD.xX.RT, {spmD.Sess{:}.row}, spmD.Sess);
  								       
% Do other design related stuff - copied / edited from spm_fmri_spm_ui
%-----------------------------------------------------------------------
%-----------------------------------------------------------------------
%-----------------------------------------------------------------------
% Need nscan, nsess
nsess = length(spmD.Sess);
for i = 1:nsess
  nscan(i) = length(spmD.Sess{i}.row;
end

% intrinsic autocorrelations (Vi)
%-----------------------------------------------------------------------
str     = 'Model intrinsic correlations?';
cVimenu = {'none','AR(1)'};
cVi     = spm_input(str,'+1','b',cVimenu,'batch',{},'int_corr');

%-Estimation options
%=======================================================================
spm_input('Estimation options',1,'d',mfilename,'batch')

%-Generate default trial-specific F-contrasts specified by session?
%-----------------------------------------------------------------------
bFcon = spm_input('Setup trial-specific F-contrasts?','+1','y/n',[1,0],1,...
		'batch',{},'trial_fcon');

%=======================================================================
% - C O N F I G U R E   D E S I G N
%=======================================================================
spm_clf(Finter);
spm('FigName','Configuring, please wait...',Finter,CmdLine);
spm('Pointer','Watch');


% Construct K and Vi structs
%=======================================================================
K       = spm_filter('set',K);

% Adjust for missing scans
%-----------------------------------------------------------------------
% [spmD.xX,Sess,K,P,nscan,row] = spm_bch_tsampl(spmD.xX,Sess,K,P,nscan,row); %-SR

% create Vi struct
%-----------------------------------------------------------------------
Vi      = speye(sum(nscan));
xVi     = struct('Vi',Vi,'Form',cVi);
for   i = 1:nsess
  xVi.row{i} = spmD.Sess{i}.row;
end

%-Masking structure
%-----------------------------------------------------------------------
xM     = [];

%-Complete design matrix (xX)
%=======================================================================
spmD.xX.K   = K;
spmD.xX.xVi = xVi;

%-Effects designated "of interest" - constuct F-contrast structure array
%-----------------------------------------------------------------------
if length(spmD.xX.iC)
	F_iX0  = struct(	'iX0',		spmD.xX.iB,...
				'name',		'effects of interest');
else
	F_iX0  = [];
	DSstr  = 'Block [session] effects only';
end

%-Trial-specific effects specified by Sess
%-----------------------------------------------------------------------
%-NB: With many sessions, these default F-contrasts can make xCon huge!
if bFcon
	i      = length(F_iX0) + 1;
	if (spmD.Sess{1}.rep)
		for t = 1:length(spmD.Sess{1}.name)
			u     = [];
			for s = 1:length(spmD.Sess)
				u = [u spmD.Sess{s}.col(spmD.Sess{s}.ind{t})];
			end
			q             = 1:size(spmD.xX.X,2);
			q(u)          = [];
			F_iX0(i).iX0  = q;
			F_iX0(i).name = spmD.Sess{s}.name{t};
			i             = i + 1;
		end
	else
		for s = 1:length(spmD.Sess)
			str   = sprintf('Session %d: ',s);
			for t = 1:length(spmD.Sess{s}.name)
				q             = 1:size(spmD.xX.X,2);
				q(spmD.Sess{s}.col(spmD.Sess{s}.ind{t})) = [];
				F_iX0(i).iX0  = q;
				F_iX0(i).name = [str spmD.Sess{s}.name{t}];
				i             = i + 1;
			end
		end
	end
end


%-Design description (an nx2 cellstr) - for saving and display
%=======================================================================
for i    = 1:length(spmD.Sess), ntr(i) = length(spmD.Sess{i}.name); end
sGXcalc  = 'none';
sGMsca   = 'none';
xsDes    = struct('Design',			DSstr,...
		  'Basis_functions',		BFstr,...
		  'Number_of_sessions',		sprintf('%d',nsess),...
		  'Conditions_per_session',	sprintf('%-3d',ntr),...
		  'Interscan_interval',		sprintf('%0.2f',spmD.xX.RT),...
		  'High_pass_Filter',		LFstr,...
		  'Low_pass_Filter',		HFstr,...
		  'Intrinsic_correlations',	xVi.Form,...
		  'Global_calculation',		sGXcalc,...
		  'Grand_mean_scaling',		sGMsca,...
		  'Global_normalisation',	'none');

%-global structure
%-----------------------------------------------------------------------
spmD.xGX = [];
 
%-Display Design report
%=======================================================================
fprintf('%-40s: ','Design reporting')                                %-#
spm_DesRep('DesMtx',spmD.xX,[],xsDes)
fprintf('%30s\n','...done')                                          %-#

% end of copy from spm_fmri_spm_ui  
  
  % save new model
  %-----------------------------------------------------------------------
  fprintf('%-40s: ','Saving MarsBar stats configuration')              %-#
  spmD.xsDes = xsDes;
  spmD.F_iX0 = F_ix0;
  spmD.cfg = 'mars_design_cfg';
  savestruct('mars_design_cfg.mat', spmD);
  fprintf('%30s\n','...mars_design_cfg.mat saved')                     %-#

  
end  
  
%-Estimate now or later?
%-----------------------------------------------------------------------
bEstNow = spm_input('estimate?','_','b','now|later',[1,0],1,...
		'batch',{},'now_later');

if bEstNow
	spm('Pointer','Watch')
	spm('FigName','Stats: estimating...',Finter,CmdLine);
	spm_spm(VY,xX,xM,F_iX0,Sess,xsDes);
	spm('Pointer','Arrow')
else
	spm_clf(Finter)
	spm('FigName','Stats: configured',Finter,CmdLine);
	spm('Pointer','Arrow')
	spm_DesRep('DesRepUI',struct(	'xX',		xX,...
					'VY',		VY,...
					'xM',		xM,...
					'F_iX0',	F_iX0,...
					'Sess',		{Sess},...
					'xsDes',	xsDes,...
					'swd',		pwd,...
					'SPMid',	SPMid,...
					'cfg',		'SPMcfg'));
end


%-End: Cleanup GUI
%-----------------------------------------------------------------------
fprintf('\n\n')