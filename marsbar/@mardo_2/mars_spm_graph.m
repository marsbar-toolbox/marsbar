function [r_st,marsD,changef] = mars_spm_graph(marsD,rno,Ic)
% Graphical display of adjusted data
% FORMAT [r_st,marsD,changef] = mars_spm_graph(marsD,rno,Ic)
%
% marsD    - SPM design object
%        required fields in des_struct are:
%        xX     - Design Matrix structure
%        - (see spm_spm.m for structure)
%        betas  - the betas!
%        ResidualMS  - the residual mean square
%        xCon   - contrast definitions
%          - required fields are:
%          .c  - contrast vector/matrix
%          (see spm_FcUtil.m for details of contrast structure... )
%        marsY  - MarsBaR data object
%
% rno    - region number (index for marsD.marsY)
% Ic     - contrast number (optional)
% 
% Returns
% r_st   - return structure, with fields
%          Y      - fitted   data for the selected voxel
%          y      - adjusted data for the selected voxel
%          beta   - parameter estimates
%          Bcov   - covariance of parameter estimates
%          cbeta  = betas multiplied by contrast
% marsD   - design structure, with possibly added contrasts
% changef - set to 1 if design has changed
%
% see spm2 version of spm_graph for details
%_______________________________________________________________________
% @(#)spm_graph.m	2.43 Karl Friston 03/12/19
%
% $Id$

if ~is_mars_estimated(marsD)
  error('Need estimated design for plot');
end
if nargin < 2
  rno = [];
end
if nargin < 3
  Ic = [];
end
changef = 0;

% make values ready for return 
def_r_st = struct(...
    'Y', [],...
    'y', [],...
    'beta', [],...
    'SE', [],...
    'cbeta',[], ...
    'PSTH',[]);
cbeta = []; PSTH = [];

% get stuff from object
SPM = des_struct(marsD);
xCon = SPM.xCon;
  
% Check if we want to, and can, assume region no is 1
if isempty(rno) 
  if n_regions(SPM.marsY) > 1
    error('Need to specify region number');
  end
  rno = 1;
end

% Get required data and filter
sY    = summary_data(SPM.marsY);
y     = apply_filter(marsD, sY(:, rno));

% Get design matrix for convenience
xX = SPM.xX;

% Label for region
XYZstr = region_name(SPM.marsY, rno);
XYZstr = XYZstr{1};

%-Get parameter estimates, ResidualMS, (compute) fitted data & residuals
%=======================================================================

%-Parameter estimates: beta = xX.pKX*xX.K*y;
%-----------------------------------------------------------------------
beta  = SPM.betas(:, rno);

%-Residual mean square: ResidualMS = sum(R.^2)/xX.trRV;
%-----------------------------------------------------------------------
ResidualMS = SPM.ResidualMS(rno);
Bcov  = ResidualMS*SPM.xX.Bcov;

%-Get Graphics figure handle
%-----------------------------------------------------------------------
Fgraph = spm_figure('GetWin','Graphics');


%-Delete previous axis and their pagination controls (if any)
%-----------------------------------------------------------------------
spm_results_ui('Clear',Fgraph,2);

%-Compute residuals
%-----------------------------------------------------------------------
if isempty(y)

	% make R = NaN so it will not be plotted
	%---------------------------------------------------------------
	R   = NaN*ones(size(SPM.xX.X,1),1);

else
	% residuals (non-whitened)
	%---------------------------------------------------------------
	R   = spm_sp('r',SPM.xX.xKXs,y);

end

%-Get parameter and hyperparameter estimates
%=======================================================================
%-Parameter estimates:   beta = xX.pKX*xX.K*y;
%-Residual mean square: ResidualMS = sum(R.^2)/xX.trRV
%---------------------------------------------------------------

P05_Z = 1.6449;					% = spm_invNcdf(1 - 0.05);
CI    = P05_Z;

%-Colour specifications and index;
%-----------------------------------------------------------------------
Col   = [0 0 0; .8 .8 .8; 1 .5 .5];

%-Plot
%=======================================================================

% find out what to plot
%-----------------------------------------------------------------------
Cplot = {	'Contrast estimates and 90% C.I.',...
	 	'Fitted responses',...
	 	'Event-related responses',...
	 	'Parametric responses',...
		'Volterra Kernels'};


% ensure options are appropriate
%-----------------------------------------------------------------------
try
	Sess  = SPM.Sess;
catch
	Cplot = Cplot(1:2);	
end
Cplot  = Cplot{spm_input('Plot',-1,'m',Cplot)};

switch Cplot

% select contrast if
%----------------------------------------------------------------------
case {'Contrast estimates and 90% C.I.','Fitted responses'}

        if isempty(Ic)
	  % determine which contrast
	  %---------------------------------------------------------------
	  [Ic marsD changef] = ui_get_contrasts(...
	      marsD, 'T|F',1, 'Select contrast...', ' for plot', 1);
	  if changef, SPM.xCon = get_contrasts(marsD); end
	end
	TITLE = {Cplot SPM.xCon(Ic).name};

% select session and trial if
%----------------------------------------------------------------------
case {'Event-related responses','Parametric responses','Volterra Kernels'}

	% get session
	%--------------------------------------------------------------
	s     = length(Sess);
	if  s > 1
		s = spm_input('which session','+1','n1',1,s);
	end

	% effect names
	%--------------------------------------------------------------
	switch Cplot
	case 'Volterra Kernels'
		u = length(Sess(s).Fc);
	otherwise
		u = length(Sess(s).U);
	end
	Uname = {};
	for i = 1:u
		Uname{i} = Sess(s).Fc(i).name;
	end

	% get effect
	%--------------------------------------------------------------
	str   = sprintf('which effect');
	u     = spm_input(str,'+1','m',Uname);

	% bin size
	%--------------------------------------------------------------
	dt    = SPM.xBF.dt;

end

switch Cplot

% plot parameter estimates
%----------------------------------------------------------------------
case 'Contrast estimates and 90% C.I.'

	% compute contrast of parameter estimates and 90% C.I.
	%--------------------------------------------------------------
	cbeta = SPM.xCon(Ic).c'*beta;
	CI    = CI*sqrt(diag(SPM.xCon(Ic).c'*Bcov*SPM.xCon(Ic).c));

	% bar chart
	%--------------------------------------------------------------
	figure(Fgraph)
	subplot(2,1,2)
	cla
	hold on

	% estimates
	%--------------------------------------------------------------
	h     = bar(cbeta);
	set(h,'FaceColor',Col(2,:))

	% standard error
	%--------------------------------------------------------------
	for j = 1:length(cbeta)
		line([j j],([CI(j) 0 - CI(j)] + cbeta(j)),...
			    'LineWidth',6,'Color',Col(3,:))
	end

	title(TITLE,'FontSize',12)
	xlabel('contrast')
	ylabel(['contrast estimate',XYZstr])
	set(gca,'XLim',[0.4 (length(cbeta) + 0.6)])
	hold off

	% set Y to empty so outputs are assigned
	%-------------------------------------------------------------
	Y = [];

% all fitted effects or selected effects
%-----------------------------------------------------------------------
case 'Fitted responses'

	% predicted or adjusted response
	%---------------------------------------------------------------
	str   = 'predicted or adjusted response?';
	if spm_input(str,'!+1','b',{'predicted','adjusted'},[1 0]);

		% fitted (predicted) data (Y = X1*beta)
		%--------------------------------------------------------
		Y = SPM.xX.X*SPM.xCon(Ic).c*pinv(SPM.xCon(Ic).c)*beta;
	else

		% fitted (corrected)  data (Y = X1o*beta)
		%-------------------------------------------------------
		Y = spm_FcUtil('Yc',SPM.xCon(Ic),SPM.xX.xKXs,beta);

	end

	% adjusted data
	%---------------------------------------------------------------
	y     = Y + R;

	% get ordinates
	%---------------------------------------------------------------
	Xplot = {	'an explanatory variable',...
			'scan or time',...
			'a user specified ordinate'};
	Cx    = spm_input('plot against','!+1','m',Xplot);

	% an explanatory variable
	%---------------------------------------------------------------
	if     Cx == 1

		str  = 'Which explanatory variable?';
		i    = spm_input(str,'!+1','m',SPM.xX.name);
		x    = SPM.xX.xKXs.X(:,i);
		XLAB = SPM.xX.name{i};

	% scan or time
	%---------------------------------------------------------------
	elseif Cx == 2

		if isfield(SPM.xY,'RT')
			x    = SPM.xY.RT*[1:size(Y,1)]';
			XLAB = 'time {seconds}';
		else
			x    = [1:size(Y,1)]';
			XLAB = 'scan number';
		end

	% user specified
	%---------------------------------------------------------------
	elseif Cx == 3

		x    = spm_input('enter ordinate','!+1','e','',size(Y,1));
		XLAB = 'ordinate';

	end

	% plot
	%---------------------------------------------------------------
	figure(Fgraph)
	subplot(2,1,2)
	cla
	hold on
	[p q] = sort(x);
	if all(diff(x(q)))
		plot(x(q),Y(q),'LineWidth',4,'Color',Col(2,:));
		plot(x(q),y(q),':','Color',Col(1,:));
		plot(x(q),y(q),'.','MarkerSize',8, 'Color',Col(3,:)); 

	else
		plot(x(q),Y(q),'.','MarkerSize',16,'Color',Col(1,:));
		plot(x(q),y(q),'.','MarkerSize',8, 'Color',Col(2,:));
		xlim = get(gca,'XLim');
		xlim = [-1 1]*diff(xlim)/4 + xlim;
		set(gca,'XLim',xlim)

	end
	title(TITLE,'FontSize',12)
	xlabel(XLAB)
	ylabel(['response',XYZstr])
	legend('fitted','plus error')
	hold off

% modeling evoked responses based on Sess
%----------------------------------------------------------------------
case 'Event-related responses'

	% get plot type
	%--------------------------------------------------------------
	Rplot   = {	'fitted response and PSTH',...
			'fitted response and 90% C.I.',...
			'fitted response and adjusted data'};

	if isempty(y)
		TITLE = Rplot{2};
	else
		TITLE = Rplot{spm_input('plot in terms of','+1','m',Rplot)};
	end

	% plot
	%--------------------------------------------------------------
	switch TITLE
	case 'fitted response and PSTH'


		% build a simple FIR model subpartition (X); bin size = TR
		%------------------------------------------------------
		str         = 'bin size (secs)';
                BIN         = sprintf('%0.2f',SPM.xY.RT);
		BIN         = spm_input(str,'!+1','r',BIN);
		xBF         = SPM.xBF;
		U           = Sess(s).U(u);
		U.u         = U.u(:,1);
		xBF.name    = 'Finite Impulse Response';
		xBF.order   = round(32/BIN);
		xBF.length  = xBF.order*BIN;
		xBF         = pr_spm_get_bf(xBF);
		BIN         = xBF.length/xBF.order;
		X           = pr_spm_volterra(U,xBF.bf,1);
		k           = SPM.nscan(s);
		X           = X([0:(k - 1)]*SPM.xBF.T + SPM.xBF.T0 + 32,:);

		% place X in SPM.xX.X
		%------------------------------------------------------
		jX          = Sess(s).row;
		iX          = Sess(s).col(Sess(s).Fc(u).i);
		iX0         = [1:size(SPM.xX.X,2)];
		iX0(iX)     = [];
		X           = [X SPM.xX.X(jX,iX0)];
		X           = SPM.xX.W(jX,jX)*X;
		X           = [X SPM.xX.K(s).X0];

		% Re-estimate to get PSTH and CI
		%------------------------------------------------------
		j           = xBF.order;
		xX          = spm_sp('Set',X);
		pX          = spm_sp('x-',xX);
		PSTH        = pX*y(jX);
		res         = spm_sp('r',xX,y(jX));
		df          = size(X,1) - size(X,2);
		bcov        = pX*pX'*sum(res.^2)/df;
		PSTH        = PSTH(1:j)/dt;
		PST         = [1:j]*BIN - BIN/2;
		PCI         = CI*sqrt(diag(bcov(1:j,(1:j))))/dt;
	end

	% basis functions and parameters
	%--------------------------------------------------------------
	X     = SPM.xBF.bf/dt;
	x     = ([1:size(X,1)] - 1)*dt;
	j     = Sess(s).col(Sess(s).Fc(u).i(1:size(X,2)));
	B     = beta(j);
	
	% fitted responses with standard error
	%--------------------------------------------------------------
	Y     = X*B;
	CI    = CI*sqrt(diag(X*Bcov(j,j)*X'));

	% peristimulus times and adjusted data (y = Y + R)
	%--------------------------------------------------------------
	pst   = Sess(s).U(u).pst;
	bin   = round(pst/dt);
	q     = find((bin >= 0) & (bin < size(X,1)));
	y     = R(Sess(s).row(:));
	pst   = pst(q);
	y     = y(q) + Y(bin(q) + 1);

	% plot
	%--------------------------------------------------------------
	figure(Fgraph)
	subplot(2,1,2)
	hold on
	switch TITLE

		case 'fitted response and PSTH'
		%------------------------------------------------------
		errorbar(PST,PSTH,PCI)
		plot(PST,PSTH,'LineWidth',4,'Color',Col(2,:))
		plot(x,Y,'-.','Color',Col(3,:))

		case 'fitted response and 90% C.I.'
		%------------------------------------------------------
		plot(x,Y,'Color',Col(2,:),'LineWidth',4)
		plot(x,Y + CI,'-.',x,Y - CI,'-.','Color',Col(1,:))

		case 'fitted response and adjusted data'
		%------------------------------------------------------
		plot(x,Y,'Color',Col(2,:),'LineWidth',4)
		plot(pst,y,'.','Color',Col(3,:))

	end

	% label
	%-------------------------------------------------------------
	[i j] = max(Y);
	text(ceil(1.1*x(j)),i,Sess(s).Fc(u).name,'FontSize',8);
	title(TITLE,'FontSize',12)
	xlabel('peristimulus time {secs}')
	ylabel(['response',XYZstr])
	hold off


% modeling evoked responses based on Sess
%----------------------------------------------------------------------
case 'Parametric responses'


	% return gracefully if no parameters
	%--------------------------------------------------------------
	if ~Sess(s).U(u).P(1).h, return, end

	% basis functions
	%--------------------------------------------------------------
	bf    = SPM.xBF.bf;
	pst   = ([1:size(bf,1)] - 1)*dt;

	% orthogonalised expansion of parameteric variable
	%--------------------------------------------------------------
	str   = 'which parameter';
	p     = spm_input(str,'+1','m',{Sess(s).U(u).P.name});
	P     = Sess(s).U(u).P(p).P;
	q     = [];
	for i = 0:Sess(s).U(u).P(p).h;
		q = [q spm_en(P).^i];
	end
	q     = spm_orth(q);


	% parameter estimates for this effect
	%--------------------------------------------------------------
	j     = Sess(s).col(Sess(s).Fc(u).i);
	B     = beta(j);

	% reconstruct trial-specific responses
	%--------------------------------------------------------------
	Y     = zeros(size(bf,1),size(q,1));
	uj    = Sess(s).U(u).P(p).i;
	for i = 1:size(P,1)
		U      = sparse(1,uj,q(i,:),1,size(Sess(s).U(u).u,2));
		X      = kron(U,bf);
		Y(:,i) = X*B;
	end
	[P j] = sort(P);
	Y     = Y(:,j);

	% plot
	%--------------------------------------------------------------
	figure(Fgraph)
	subplot(2,2,3)
	surf(pst,P,Y')
	shading flat
	title(Sess(s).U(u).name{1},'FontSize',12)
	xlabel('PST {secs}')
	ylabel(Sess(s).U(u).P(p).name)
	zlabel(['responses',XYZstr])
	axis square

	% plot
	%--------------------------------------------------------------
	subplot(2,2,4)
	[j i] = max(mean(Y,2));
	plot(P,Y(i,:),'LineWidth',4,'Color',Col(2,:))
	str   = sprintf('response at %0.1fs',i*dt);
	title(str,'FontSize',12)
	xlabel(Sess(s).U(u).P(p).name)
	axis square
	grid on


% modeling evoked responses based on Sess
%----------------------------------------------------------------------
case 'Volterra Kernels'

	% Parameter estimates and basis functions
	%------------------------------------------------------
	bf    = SPM.xBF.bf/dt;
	pst   = ([1:size(bf,1)] - 1)*dt;

	% second order kernel
	%--------------------------------------------------------------
	if u > length(Sess(s).U)

		% Parameter estimates and kernel
		%------------------------------------------------------
		j     = Sess(s).col(Sess(s).Fc(u).i);
		B     = beta(j);
		i     = 1;
		Y     = 0;
		for p = 1:size(bf,2)
		for q = 1:size(bf,2)
     			Y = Y + B(i)*bf(:,p)*bf(:,q)';
			i = i + 1;
		end
		end

		% plot
		%------------------------------------------------------
		figure(Fgraph)
		subplot(2,2,3)
		imagesc(pst,pst,Y)
		axis xy
		axis image

		title('2nd order Kernel','FontSize',12);
		xlabel('perstimulus time {secs}')
		ylabel('perstimulus time {secs}')

		subplot(2,2,4)
		plot(pst,Y)
		axis square
		grid on

		title(Sess(s).Fc(u).name,'FontSize',12);
		xlabel('perstimulus time {secs}')


	% first  order kernel
	%--------------------------------------------------------------
	else
		j     = Sess(s).col(Sess(s).Fc(u).i(1:size(bf,2)));
		B     = beta(j);
		Y     = bf*B;

		% plot
		%------------------------------------------------------
		figure(Fgraph)
		subplot(2,1,2)
		plot(pst,Y)
		grid on
		axis square

		title({'1st order Volterra Kernel' Sess(s).Fc(u).name},...
			'FontSize',12);
		xlabel('perstimulus time {secs}')
		ylabel(['impluse response',XYZstr])
	end

end


%-call Plot UI
%----------------------------------------------------------------------
spm_results_ui('PlotUi',gca)

% Complete return values
r_st = mars_struct('fillafromb', def_r_st, struct(...
    'Y', Y, 'y', y, 'beta', beta, 'Bcov', Bcov, ...
    'cbeta', cbeta, 'PSTH', PSTH));
