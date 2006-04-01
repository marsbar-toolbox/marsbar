function o = mardo_2(o)
% method to convert SPM2 design to SPM99 design
%
% Heavily based with thanks on work by Jeff Cooper:
% Written June 2003 by Jeff Cooper (jcooper@stanford.edu)
% 
% $Id$

% Process design
params = paramfields(o);
SPM99  = params.des_struct;
xX     = SPM99.xX;

SPM.xY = struct('P', char(image_names(o)), ...
		'VY', get_images(o));
RT =  mars_struct('getifthere', SPM99, 'xX', 'RT');
if ~isempty(RT), SPM.xY.RT = RT; end

SPM = mars_struct('merge', SPM, ...
		  mars_struct('split', SPM99, {'xM', 'xGX'}));
SPM.xCon = mars_struct('getifthere', SPM99, 'xCon');

% This is the first substructure that we have to do some
% actual work to assemble.  Much of the details of the
% condition structures (U) can be gleaned from the SPM99
% Sess variable - onset vectors, stick functions, etc. - but
% not quite everything.  Trial durations are difficult to figure out, but
% we'll give it a go here with the event_onsets method

if isfield(SPM99, 'Sess'), Sess = SPM99.Sess; else Sess = []; end
for i = 1:length(Sess)
    currsess = Sess{i};
    
    % indices for this session's row in design matrix
    SPM.Sess(i).row = currsess.row;      
    
    % indices for this session's cols in design matrix
    SPM.Sess(i).col = currsess.col;      
    
    % number of scans in this session
    SPM.nscan(i) = length(currsess.row);
    
    % We can use the length of the onset cell array as an
    % effective number of conditions variable - only 'true'
    % conditions have onset vectors, not Volterra items or
    % user-specified covariates.
    for j = 1:length(currsess.ons) 
      
      % Try getting onsets and durations from design
      [ons dur] = event_onsets(D, [i j]);
      
      % time bin length in seconds
      SPM.Sess(i).U(j).dt = xX.dt;
      
      % name of trial type
      SPM.Sess(i).U(j).name = {currsess.name{j}};
      
      % vector of onsets
      SPM.Sess(i).U(j).ons = ons;
      
      % duration of trials 
      SPM.Sess(i).U(j).dur = dur;
      
      % actual stick functions - SPM2 uses 32-bin offset.
      SPM.Sess(i).U(j).u = [zeros(32,1); currsess.sf{j}];
      
      % peristimulus time course (seconds)
      SPM.Sess(i).U(j).pst = currsess.pst{j};
      
      % parameter name
      SPM.Sess(i).U(j).P.name = currsess.Pname{j};
      if isempty(currsess.Pname{j})
	% SPM2 includes these values for 'none'
	% parameters - just mimicking what they do...
	SPM.Sess(i).U(j).P.name = 'none';
	SPM.Sess(i).U(j).P.P = currsess.ons{j};         % values of parameter
	SPM.Sess(i).U(j).P.h = 0;                       % order of polynomial expansion
      else
	SPM.Sess(i).U(j).P.name = currsess.Pname{j};    % parameter name
	SPM.Sess(i).U(j).P.P = currsess.Pv{j};          % parameter values
							% leave h and i blank for now...
      end
    end
    % SPM99 doesn't save regressors in independent
    % structures as SPM2 does, but it does always append
    % them to the end of the session and append 'user
    % specified covariates' to the description string of the
    % session if they exist, which we can use.
    %
    % First check and see if there are any:
    if ~(isempty(strfind(lower(currsess.DSstr), 'user specified covariates')))
      % i.e., some are in here, so find out what their indices
      % are - all the columns that don't correspond to
      % specified conditions with onsets and such.
      % Note that Volterra items aren't included in
      % onsets, either, but they are included in 'the 'name'
      % field - so we want to use that as our chopping 
      % point for finding covariate columns - everything
      % after name is a covariate.
      reg_indices = currsess.col((length(currsess.name)+1):end);
      % extract values from design matrix
      SPM.Sess(i).C.C = xX.X(currsess.row, reg_indices);  % user-specified covariate values
      SPM.Sess(i).name = xX.Xnames(reg_indices);          % user-specified covariate names
    else
      % there are no user specified covariates
      SPM.Sess(i).C.C = [];
      SPM.Sess(i).C.name = {};
    end
    % Everything which is in the 'name' field is either an
    % actual condition or a Volterra item, so that's our
    % effective number for the Fc array.
    for j = 1:length(currsess.name)
      SPM.Sess(i).Fc(j).i = currsess.ind{j};      % index for input j and interactions
      SPM.Sess(i).Fc(j).name = char(currsess.name(j));  % name for input j and interactions
    end
end % Session loop

if ~isempty(Sess)
  %%%%%%%%%%
  % SPM.xBF - basis function structure
  %%%%%%%%%%
  
  % NOTE on the BF structure - where SPM99 allows the
  % individual specification of basis functions for each trial
  % type, SPM2 just has one basis function set for the whole
  % experiment.  Since it's difficult to figure out which of
  % the various SPM99 basis functions to use on any kind of
  % reasoned basis, this program takes the arbitrary step of
  % just taking the first one from the first session.  This
  % should work fine for most experiments, but those with
  % mixed basis functions that want to select a different one
  % among the ones save are encouraged to modify the lines
  % below to get the one to their liking...
  sess_idx_for_bf = 1;
  cond_idx_for_bf = 1;
  
  SPM.xBF.T = xX.RT / xX.dt;

  % # of time bins per scan
  % T0 - the reference time bin - isn't saved by SPM99, and
  % it's not extractable from the design matrix in any way I
  % can figure out.  So we'll take a stab at loading it from
  % the site's defaults, and if you re-set it, you'd better be
  % paying attention...
  % first run local defaults file - that'll pull something
  % up uniquely.
  spm_defaults;
  global defaults; %SPM2-style
  global fMRI_T0;  %SPM99-style
  if ~isempty(defaults)
    SPM.xBF.T0 = defaults.stats.fmri.t0;    % reference time bin
  elseif ~isempty(fMRI_T0)
    SPM.xBF.T0 = fMRI_T0;
  else
    % shouldn't get here - there should be some defaults on
    % this system - but not a killer error.  One they should
    % know about, though...
    disp('Warning: Defaults don''t contain reference slice value!');
    SPM.xBF.T0 = 1;
  end
  % SPM99 onsets were reconstructed in scan units
  % units that onsets are in ['scans', 'seconds']
  SPM.xBF.UNITS = 'scans';
  if length(SPM.Sess(1).U) < length(SPM.Sess(1).Fc)
    % Volterra flag [1=no Volterra, 2=Volterra modeled]
    SPM.xBF.Volterra = 2;                   
  else
    SPM.xBF.Volterra = 1;
  end
  SPM.xBF.dt = xX.dt;                         % time bin length in seconds
  SPM.xBF.name = '';                          % string: type of basis function - not saved by SPM99 batching
  SPM.xBF.bf = Sess{sess_idx_for_bf}.bf(cond_idx_for_bf);     
  % the actual basis function matrix    
  % SPM99 doesn't explicitly save length or order of basis
  % functions, but this below should work for all non-Fourier,
  % non-Gamma basis fns, and maybe even some of them...
  SPM.xBF.length = xX.dt*size(SPM.xBF.bf, 1);        % window length of basis fn in secs
  SPM.xBF.order = size(SPM.xBF.bf,2);                % order of basis fn
  
end

%%%%%%%%%%
% SPM.xVi - temporal non-sphericity struct
%%%%%%%%%%

% We'll be assuming that SPM99 results, in general, made the
% i.i.d. assumption.  Estimation of results with the AR(1)
% option specified proceeds very differently in SPM2 than in
% SPM99, and so those that used AR(1) in SPM99 are warned
% that their results will not translate perfectly to SPM2,
% as the whitening matrix W will always be set to identity
% in importing these results.

switch xX.xVi.Form
 case 'none'
  SPM.xVi.form = 'i.i.d';                 % string description of xVi   
  % covariance constraints - sparse identity matrix in this option for both SPM99 and SPM2.
  SPM.xVi.Vi = {xX.xVi.Vi};               
  SPM.xVi.V = speye(size(xX.xVi));         % estimated non-sphericity itself.
 case 'AR(1)'
  SPM.xVi.form = 'AR(0.2)';               % string description of xVi - this is parallel to what SPM2 does
  SPM.xVi.Vi = {xX.xVi.Vi}                % covariance constraints
  
  % I don't think this will actually make a
  % difference, as the whitening matrix W is always
  % going to be identity.  But it may be useful to
  % have.  True SPM2 results will also have xVi.V and
  % so forth, but not these imported ones...
end

%%%%%%%%%%
% SPM.xX - design matrix structure
%%%%%%%%%%

% Here's the big 'un.  Much of this stuff will be translated
% directly from the SPM99 results, and it remains to be seen
% how well that's going to work.  We will assume that
% ordinary least squares estimation has been used in SPM99,
% and therefore set W to the identity matrix.

SPM.xX = mars_struct('split', xX, ...
		     {'X','iH', 'iC', 'iB', 'iG', 'V', 'I' ...
		    'xKXs', 'pKX', 'Bcov', 'trRV', 'trRVRV', 'erdf', 'nKX'});
SPM.xX.name = xX.Xnames;
if isfield(xX, 'K')
  if iscell(xX.K)
    for i = 1:length(xX.K)
      SPM.xX.K(i).RT = SPM.xY.RT;             % experimental RT
      SPM.xX.K(i).row = xX.K{i}.row;          % row indices in design matrix for this filter
      SPM.xX.K(i).HParam = xX.K{i}.HParam;    % high-pass cutoff period in secs
      SPM.xX.K(i).X0 = full(xX.K{i}.KH);      % frequencies to be removed by filter.
    end
  else
    SPM.xX.K = xX.K;
  end
end
SPM.xX.W = speye(size(xX.X,1));       % whitening matrix - identity for ordinary least squares estimates

if isfield(SPM99, 'M')
  SPM.xVol = mars_struct('split', SPM99, ...
			 {'M', 'DIM', 'XYZ', 'S', 'R', 'FWHM'});
  SPM.xVol.iM = inv(SPM.xVol.M);   % inverse of M
  % We will deal with the RPV image later on...
end

%%%%%%%%%%
% SPM.miscellaneous stuff
%%%%%%%%%%

% various string descriptions of experimental design
SPM.xsDes = SPM99.xsDes;
if isfield(SPM.xsDes, 'Conditions_per_session')
  SPM.xsDes.Trials_per_session = SPM.xsDes.Conditions_per_session;
  rmfield(SPM.xsDes, 'Conditions_per_session');
end
SPM.xsDes.Serial_correlations = SPM.xVi.form;

SPM.SPMid = ['SPM2: Results imported from SPM99 design: ' SPM99.SPMid];

% Try and deal with estimated result volumes
if isfield(SPM99, 'swd')
  SPM.swd = SPM99.swd;
  if ~exist(SPM99.swd, 'dir')
    warning(['Could not find directory: ' SPM.swd]);
  else
    o_pwd = pwd;
    cd(SPM99.swd);
    if isfield(SPM99, 'Vbeta')
      for i = 1:length(SPM99.Vbeta)
	SPM.Vbeta(i) = spm_vol(SPM99.Vbeta{i});
      end
      SPM.VResMS = spm_vol(SPM99.VResMS);
      SPM.VM = spm_vol(SPM99.VM);
    end
    for i = 1:length(SPM.xCon) 
      if ~isempty(SPM.xCon(i).Vcon)
	SPM.xCon(i).Vcon = spm_vol(SPM.xCon(i).Vcon);
      end
      if ~isempty(SPM.xCon(i).Vspm)
	SPM.xCon(i).Vspm = spm_vol(SPM.xCon(i).Vspm);   
      end
    end
    if isfield(SPM99, 'M')
      % Now deal with RPV image
      if exist('RPV.img', 'file')
	% filehandle of resels per voxel image
	SPM.xVol.VRpv = spm_vol('RPV.img'); 
      else
	% Don't really understand this one...
	SPM.xVol.VRpv.fname = ['../' SPM.xVol.VRpv.fname];
      end
    end
    cd(o_pwd);
  end
end

% put into parent object
params.des_struct = SPM;
o = mardo_2(params);

return
