function o = fill_design(o, fill_flags)
% fills missing entries from SPM FMRI design matrix 
% FORMAT o = fill_design(o, fill_flags)
% 
% o          - mardo object containing spm design
% fill_flags - string with zero or more character flags from
%            'i' - fill in with images (if not already present)
%            'f' - fill in with filter details (even if present)
%
% o         - returned mardo SPM design
%
% Copied/pasted from spm_fmri_spm_ui
% Matthew Brett - 17/11/01 - MRS2TH
%
% $Id$

if nargin < 2
  fill_flags = '';
end
if isempty(fill_flags)
  fill_flags = ' ';
end

spmD = des_struct(o);

fill_imgs = 0; fill_filt = 0; will_have_imgs = 0;
if any(fill_flags == 'i'), fill_imgs = 1; will_have_imgs = 1; end
if any(fill_flags == 'f'), fill_filt = 1; end

% refuse to refill images if already present
% perverse I know, but otherwise can't use SPM2 routines simply
if has_images(o)
  disp('Design already contains images...');
  will_have_imgs = 1; 
  fill_imgs = 0; 
end

% Maybe nothing to do
if ~(fill_imgs | fill_filt), return, end

% Off we go
[Finter,Fgraph,CmdLine] = spm('FnUIsetup','fMRI stats model setup',0);
changef = 1;

% unpack fields to variables
xX = spmD.xX;
Sess = spmD.Sess;
RT     = xX.RT;

% get file indices
%---------------------------------------------------------------
nsess  = length(xX.iB);
nscan  = zeros(1,nsess);
for  i = 1:nsess
  nscan(i) = length(find(xX.X(:,xX.iB(i))));
end

% get rows
%-----------------------------------------------------------------------
for i = 1:nsess
  row{i} = find(xX.X(:,xX.iB(i)));
end
BFstr  = Sess{1}.BFstr;
DSstr  = Sess{1}.DSstr;
if ~length(xX.iC)
  DSstr = 'Block [session] effects only';
end

P      = [];
if fill_imgs
  % select images into matrix P
  if nsess < 16
    for i = 1:nsess
      str = sprintf('select scans for session %0.0f',i);
      q = spm_get(Inf,mars_veropts('get_img_ext'),str);
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
end % img options

if fill_filt
  % Temporal filtering
  %=======================================================================
  spm_input('Temporal autocorrelation options','+1','d',mfilename)
  
  [K HFstr LFstr] = get_filter(RT, Sess);
  
  % intrinsic autocorrelations (Vi)
  %-----------------------------------------------------------------------
  str     = 'Model intrinsic correlations?';
  cVimenu = {'none','AR(1)'};
  cVi     = spm_input(str,'+1','b',cVimenu);

  %-Estimation options
  %=======================================================================
  spm_input('Estimation options',1,'d',mfilename)
  
  %-Generate default trial-specific F-contrasts specified by session?
  %-----------------------------------------------------------------------
  bFcon = spm_input('Setup trial-specific F-contrasts?','+1','y/n',[1,0],1);
  
end

%=======================================================================
% - C O N F I G U R E   D E S I G N
%=======================================================================
spm_clf(Finter);
spm('FigName','Configuring, please wait...',Finter,CmdLine);
spm('Pointer','Watch');

if fill_filt
  % Construct K and Vi structs
  %=======================================================================
  K       = spm_filter('set',K);

  % Adjust for missing scans
  %-----------------------------------------------------------------------
  [xX,Sess,K,P,nscan,row] = spm_bch_tsampl(xX,Sess,K,P,nscan,row); %-SR
  
  % create Vi struct
  %-----------------------------------------------------------------------
  Vi      = speye(sum(nscan));
  xVi     = struct('Vi',Vi,'Form',cVi);
  for   i = 1:nsess
    xVi.row{i} = row{i};
  end
end

if fill_filt & ~will_have_imgs
  % set up empty global and masking structures
  xM = [];
  xGX = [];
  sGXcalc  = 'none';
  sGMsca   = 'none';
  Global = 'none';
end

if fill_imgs
  % get file identifiers and Global values
  %=======================================================================
  fprintf('%-40s: ','Mapping files')                                   %-#
  VY     = spm_vol(P);
  fprintf('%30s\n','...done')                                          %-#
  
  if any(any(diff(cat(1,VY.dim),1,1),1)&[1,1,1,0])
    error('images do not all have the same dimensions'),           end
    if any(any(any(diff(cat(3,VY.mat),1,3),3)))
      error('images do not all have same orientation & voxel size'), end
      
      %-Compute Global variate
      %-----------------------------------------------------------------------
      GM     = 100;
      q      = sum(nscan);
      g      = zeros(q,1);
      fprintf('%-40s: %30s','Calculating globals',' ')                     %-#
      for i  = 1:q
	fprintf('%s%30s',sprintf('\b')*ones(1,30),sprintf('%4d/%-4d',i,q)) %-#
	g(i) = spm_global(VY(i));
      end
      fprintf('%s%30s\n',sprintf('\b')*ones(1,30),'...done')               %-#
      
      % scale if specified (otherwise session specific grand mean scaling)
      %-----------------------------------------------------------------------
      gSF     = GM./g;
      if strcmp(Global,'None')
	for i = 1:nsess
	  j      = row{i};
	  gSF(j) = GM./mean(g(j));
	end
      end
      
      %-Apply gSF to memory-mapped scalefactors to implement scaling
      %-----------------------------------------------------------------------
      for  i = 1:q, VY(i).pinfo(1:2,:) = VY(i).pinfo(1:2,:)*gSF(i); end

      sGXcalc  = 'mean voxel value';
      sGMsca   = 'session specific';
      
      %-Masking structure
      %-----------------------------------------------------------------------
      xM     = struct('T',	ones(q,1),...
		      'TH',	g.*gSF,...
		      'I',	0,...
		      'VM',	{[]},...
		      'xs',	struct('Masking','analysis threshold'));
end

if fill_filt
  %-Complete design matrix (xX)
  %=======================================================================
  xX.K   = K;
  xX.xVi = xVi;
  
end

%-Design description (an nx2 cellstr) - for saving and display
%=======================================================================
for i    = 1:length(Sess), ntr(i) = length(Sess{i}.name); end
xsDes    = struct(	'Design',			DSstr,...
			'Basis_functions',		BFstr,...
			'Number_of_sessions',		sprintf('%d',nsess),...
			'Conditions_per_session',	sprintf('%-3d',ntr),...
			'Interscan_interval',		sprintf('%0.2f',RT),...
			'Intrinsic_correlations',	xX.xVi.Form,...
			'Global_calculation',		sGXcalc,...
			'Grand_mean_scaling',		sGMsca,...
			'Global_normalisation',		Global);

if fill_filt
  xsDes.High_pass_Filter = LFstr;
  xsDes.Low_pass_Filter  = HFstr;
end

if fill_imgs
  %-global structure
  %-----------------------------------------------------------------------
  xGX.iGXcalc  = Global{1};
  xGX.sGXcalc  = sGXcalc;
  xGX.rg       = g;
  xGX.sGMsca   = sGMsca;
  xGX.GM       = GM;
  xGX.gSF      = gSF;
  
  % Images
  spmD.VY = VY;
end
  
%-return into spm design
%-----------------------------------------------------------------------
spmD.xX = xX;
spmD.Sess = Sess;
spmD.xsDes = xsDes;
spmD.xGX = xGX;
spmD.xM = xM;
%spmD.SPMid = SPMid;
spmD.SPMid = 'Pretend';

if fill_filt 
  % add F contrasts
  spmD = my_fcons(spmD, bFcon) ;
end

% finish GUI
spm('Pointer','Arrow')

% return object
o = des_struct(o,spmD);