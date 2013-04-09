function varargout = pr_spm_ui(varargin)
% MarsBaR: setting up the general linear model for independent data
%
% MarsBaR version copied with minor edits from:
% @(#)spm_spm_ui.m	2.49 Andrew Holmes 03/03/20
% See that (SPM2) file for comments and help
%
% $Id$

%-Condition arguments
%-----------------------------------------------------------------------
if (nargin==0), Action = 'CFG'; else, Action = varargin{1}; end

% For selecting images, later
img_flt = mars_veropts('get_img_ext');

switch lower(Action), case 'cfg'
%=======================================================================
% - C O N F I G U R E   D E S I G N
%=======================================================================
% pr_spm_ui('CFG',D)
if nargin<2, D = []; else, D = varargin{2}; end

%-GUI setup
%-----------------------------------------------------------------------
SPMid    = spm('SFnBanner',mfilename,marsbar('ver'));
[Finter,Fgraph,CmdLine] = spm('FnUIsetup','Stats: Setup analysis',0);
spm_help('!ContextHelp',mfilename)

%-Option definitions
%-----------------------------------------------------------------------
%-Generic factor names
sF = {'sF1','sF2','sF3','sF4'};

%-Covariate by factor interaction options
sCFI = {'<none>';...							%-1
	'with sF1';'with sF2';'with sF3';'with sF4';...			%-2:5
	'with sF2 (within sF4)';'with sF3 (within sF4)'};		%-6,7

%-DesMtx argument components for covariate by factor interaction options
% (Used for CFI's Covariate Centering (CC), GMscale & Global normalisation)
CFIforms = {	'[]',		'C',	'{}';...			%-1
		'I(:,1)',	'FxC',	'{D.sF{1}}';...			%-2
		'I(:,2)',	'FxC',	'{D.sF{2}}';...			%-3
		'I(:,3)',	'FxC',	'{D.sF{3}}';...			%-4
		'I(:,4)',	'FxC',	'{D.sF{4}}';...			%-5
		'I(:,[4,2])',	'FxC',	'{D.sF{4},D.sF{2}}';...		%-6
		'I(:,[4,3])',	'FxC',	'{D.sF{4},D.sF{3}}'	};	%-7

%-Centre (mean correction) options for covariates & globals            (CC)
% (options 9-12 are for centering of global when using AnCova GloNorm) (GC)
sCC = {		'around overall mean';...				%-1
		'around sF1 means';...					%-2
		'around sF2 means';...					%-3
		'around sF3 means';...					%-4
		'around sF4 means';...					%-5
		'around sF2 (within sF4) means';...			%-6
		'around sF3 (within sF4) means';...			%-7
		'<no centering>';...					%-8
		'around user specified value';...			%-9
		'(as implied by AnCova)';...				%-10
		'GM';...						%-11
		'(redundant: not doing AnCova)'}';			%-12
%-DesMtx I forms for covariate centering options
CCforms = {'ones(nScan,1)',CFIforms{2:end,1},''}';


%-Global normalization options (options 1-7 match CFIforms)       (GloNorm)
sGloNorm = {	'AnCova';...						%-1
		'AnCova by sF1';...					%-2
		'AnCova by sF2';...					%-3
		'AnCova by sF3';...					%-4
		'AnCova by sF4';...					%-5
		'AnCova by sF2 (within sF4)';...			%-6
		'AnCova by sF3 (within sF4)';...			%-7
		'proportional scaling';...				%-8
		'<no global normalisation>'};				%-9

%-Grand mean scaling options                                        (GMsca)
sGMsca = {	'scaling of overall grand mean';...			%-1
		'scaling of sF1 grand means';...			%-2
		'scaling of sF2 grand means';...			%-3
		'scaling of sF3 grand means';...			%-4
		'scaling of sF4 grand means';...			%-5
		'scaling of sF2 (within sF4) grand means';...		%-6
		'scaling of sF3 (within sF4) grand means';...		%-7
		'(implicit in PropSca global normalisation)';...	%-8
		'<no grand Mean scaling>'	};			%-9
%-NB: Grand mean scaling by subject is redundent for proportional scaling


%-Global calculation options                                       (GXcalc)
sGXcalc  = {	'omit';...						%-1
		'user specified';...					%-2
		'mean voxel value (within per image fullmean/8 mask)'};	%-3



%=======================================================================
%-D E S I G N   P A R A M E T E R S
%=======================================================================
%-Get design type
%-----------------------------------------------------------------------
if isempty(D)

	D = pr_spm_ui( ...
		char(spm_input('Select design class...','+1','m',...
		{'Basic stats','Standard PET designs','SPM96 PET designs'},...
		{'DesDefs_Stats','DesDefs_PET','DesDefs_PET96'},2)));
end

D = D(spm_input('Select design type...','+1','m',{D.DesName}'));


%-Set factor names for this design
%-----------------------------------------------------------------------
sCC      = sf_estrrep(sCC,[sF',D.sF']);
sCFI     = sf_estrrep(sCFI,[sF',D.sF']);
sGloNorm = sf_estrrep(sGloNorm,[sF',D.sF']);
sGMsca   = sf_estrrep(sGMsca,[sF',D.sF']);

%-Get filenames & factor indicies
%-----------------------------------------------------------------------
[P,I]    = pr_spm_ui('Files&Indices',D.sF,D.n,D.b.aTime);
nScan    = size(I,1);						%-#obs

%-Additional design parameters
%-----------------------------------------------------------------------
bL       = any(diff(I,1),1); 	%-Multiple factor levels?
	    % NB: bL(2) might be thrown by user specified f1 levels
	    %     (D.b.aTime & D.n(2)>1) - assumme user is consistent?
bFI      = [bL(1),bL(2:3)&~bL(4),bL(4),bL([2,3])&bL(4)];
	    %-Allowable interactions for covariates
	    %-Only offer interactions with multi-level factors, and
	    % don't offer by F2|F3 if bL(4)!

%-Build Condition (H) and Block (B) partitions
%=======================================================================
eval(['[H,Hnames] = spm_DesMtx(',D.Hform,');'])
if rank(H)==nScan, error('unestimable condition effects'), end
eval(['[B,Bnames] = spm_DesMtx(',D.Bform,');'])
if rank(B)==nScan, error('unestimable block effects'), end

%-Drop a constant H partition if B partition can model constant
if size(H,2)>0 & all(H(:)==1) & (rank([H B])==rank(B))
	H = []; Hnames = {};
	warning('Dropping redundant constant H partition')
end


%-Covariate partition(s): interest (C) & nuisance (G) excluding global
%=======================================================================
nC = D.nC;			%-Default #covariates
C  = {[],[]}; Cnames = {{},{}};	%-Covariate DesMtx partitions & names
xC = [];			%-Struct array to hold raw covariates


dcname = {'CovInt','NusCov'};	%-Default root names for covariates
dstr   = {'covariate','nuisance variable'};

GUIpos = spm_input('!NextPos');
nc     = [0,0];
for i  = 1:2			% 1:covariates of interest, 2:nuisance variables

    if isinf(nC(i)), nC(i)=spm_input(['# ',dstr{i},'s'],GUIpos,'w1'); end

    while nc(i) < nC(i)

	%-Create prompt, get covariate, get covariate name
        %---------------------------------------------------------------
	if nC(i)==1, str=dstr{i}; else, str=sprintf('%s %d',dstr{i},nc(i)+1); end
        c = spm_input(str,GUIpos,'r',[],[nScan,Inf]);
        if any(isnan(c(:))), break, end		%-NaN is dummy value to exit
	nc(i)  = nc(i)+1;			%-#Covariates (so far)
	if nC(i)>1,	tstr = sprintf('%s^{%d}',dcname{i},nc(i));
	else,		tstr = dcname{i}; end
       	cname  = spm_input([str,' name?'],'+1','s',tstr);
       	rc     = c;				%-Save covariate value
	rcname = cname;				%-Save covariate name

        %-Interaction option? (if single covariate vector entered)?
        %---------------------------------------------------------------
        if size(c,2) == 1
       	    if length(D.iCFI{i})>1
       		%-User choice of interaction options, default is negative
       		%-Only offer interactions for appropriate factor combinations
		iCFI = intersect(abs(D.iCFI{i}),find([1,bFI]));
		dCFI = max([1,intersect(iCFI,-D.iCFI{i}(D.iCFI{i}<0))]);
        	iCFI = spm_input([str,': interaction?'],'+1','m',...
			sCFI(iCFI),iCFI,find(iCFI==dCFI));
	    else
		iCFI = abs(D.iCFI{i});		%-AutoSelect default option
	    end
	else
	    iCFI = 1;
	end

        %-Centre covariate(s)? (Default centring to correspond to CFI)
        % Always offer "no centering" as default for design matrix blocks
        %---------------------------------------------------------------
	DiCC = D.iCC{i};
	if size(c,2)>1, DiCC = union(DiCC,-8); end
        if length(DiCC)>1
        	%-User has a choice of centering options
		%-Only offer factor specific for appropriate factor combinations
		iCC = intersect(abs(DiCC),find([1,bFI,1]) );
        	%-Default is max -ve option in D, overridden by iCFI if CFI
		if iCFI == 1, dCC = -DiCC(DiCC<0); else, dCC = iCFI; end
		dCC = max([1,intersect(iCC,dCC)]);
		iCC = spm_input([str,': centre?'],'+1','m',...
			sCC(iCC),iCC,find(iCC==dCC));
        else
        	iCC = abs(DiCC);	%-AutoSelect default option
        end
	%-Centre within factor levels as appropriate
        if any(iCC == [1:7]), c = c - spm_meanby(c,eval(CCforms{iCC})); end

        %-Do any interaction (only for single covariate vectors)
        %---------------------------------------------------------------
        if iCFI > 1				%-(NB:iCFI=1 if size(c,2)>1)
       		tI        = [eval(CFIforms{iCFI,1}),c];
		tConst    = CFIforms{iCFI,2};
		tFnames   = [eval(CFIforms{iCFI,3}),{cname}];
		[c,cname] = spm_DesMtx(tI,tConst,tFnames);
	elseif size(c,2)>1			%-Design matrix block
		[null,cname] = spm_DesMtx(c,'X',cname);
	else
		cname = {cname};
	end

	%-Store raw covariate details in xC struct for reference
	%-Pack c into appropriate DesMtx partition
        %---------------------------------------------------------------
	%-Construct description string for covariate
	str = {sprintf('%s: %s',str,rcname)};
	if size(rc,2)>1, str = {sprintf('%s (block of %d covariates)',...
		str{:},size(rc,2))}; end
	if iCC < 8, str=[str;{['used centered ',sCC{iCC}]}]; end
	if iCFI> 1, str=[str;{['fitted as interaction ',sCFI{iCFI}]}]; end

	tmp       = struct(	'rc',rc,	'rcname',rcname,...
				'c',c,		'cname',{cname},...
				'iCC',iCC,	'iCFI',iCFI,...
				'type',i,...
				'cols',[1:size(c,2)] + ...
						size([H,C{1}],2) +  ...
						size([B,C{2}],2)*(i-1),...
				'descrip',{str}				);
	if isempty(xC), xC = tmp; else, xC = [xC,tmp]; end
	C{i}      = [C{i},c];
	Cnames{i} = [Cnames{i}; cname];

    end	% (while)

end % (for)
clear c tI tConst tFnames
spm_input('!SetNextPos',GUIpos);

%-Unpack into C & G design matrix sub-partitions
G = C{2}; Gnames = Cnames{2};
C = C{1}; Cnames = Cnames{1};


%-Options...
%=======================================================================
%-Global normalization options                                 (GloNorm)
%-----------------------------------------------------------------------
if length(D.iGloNorm)>1
	%-User choice of global normalisation options, default is negative
	%-Only offer factor specific for appropriate factor combinations
	iGloNorm = intersect(abs(D.iGloNorm),find([1,bFI,1,1]));
	dGloNorm = max([0,intersect(iGloNorm,-D.iGloNorm(D.iGloNorm<0))]);
	iGloNorm = spm_input('GloNorm: Select global normalisation','+1','m',...
	    	sGloNorm(iGloNorm),iGloNorm,find(iGloNorm==dGloNorm));
else
	iGloNorm = abs(D.iGloNorm);
end


%-Grand mean scaling options                                     (GMsca)
%-----------------------------------------------------------------------
if iGloNorm==8
	iGMsca=8;	%-grand mean scaling implicit in PropSca GloNorm
elseif length(D.iGMsca)==1
	iGMsca = abs(D.iGMsca);
else
	%-User choice of grand mean scaling options
	%-Only offer factor specific for appropriate factor combinations
	iGMsca = intersect(abs(D.iGMsca),find([1,bFI,0,1]));
        %-Default is max -ve option in D, overridden by iGloNorm if AnCova
        if iGloNorm==9, dGMsca=-D.iGMsca(D.iGMsca<0); else, dGMsca=iGloNorm; end
	dGMsca = max([0,intersect(iGMsca,dGMsca)]);
	iGMsca = spm_input('GMsca: grand mean scaling','+1','m',...
	    	sGMsca(iGMsca),iGMsca,find(iGMsca==dGMsca));
end


%-Value for PropSca / GMsca                                         (GM)
%-----------------------------------------------------------------------
if iGMsca == 9                          %-Not scaling (GMsca or PropSca)
	GM = 0;                         %-Set GM to zero when not scaling
else                                    %-Ask user value of GM
	if iGloNorm==8
		str = 'PropSca global mean to';
	else
		str = [strrep(sGMsca{iGMsca},'scaling of','scale'),' to'];
	end
	GM = spm_input(str,'+1','r',D.GM,1);
	%-If GM is zero then don't GMsca! or PropSca GloNorm
	if GM==0, iGMsca=9; if iGloNorm==8, iGloNorm=9; end, end
end

%-Sort out description strings for GloNorm and GMsca
%-----------------------------------------------------------------------
sGloNorm = sGloNorm{iGloNorm};
sGMsca   = sGMsca{iGMsca};
if iGloNorm==8
	sGloNorm = sprintf('%s to %-4g',sGloNorm,GM);
elseif iGMsca<8
	sGMsca   = sprintf('%s to %-4g',sGMsca,GM);
end


%-Global centering (for AnCova GloNorm)                             (GC)
%-----------------------------------------------------------------------
%-Specify the centering option for the global covariate for AnCova
%-Basically, if 'GMsca'ling then should centre to GM (iGC=11). Otherwise,
% should centre in similar fashion to AnCova (i.e. by the same factor(s)),
% such that models are seperable (iGC=10). This is particularly important
% for subject specific condition effects if then passed on to a second-level
% model. (See also spm_adjmean_ui.m) SPM96 (& earlier) used to just centre
% GX around its (overall) mean (iGC=1).

%-This code allows more general options to be specified (but is a bit complex)
%-Setting D.iGC=[-10,-11] gives the standard choices above

%-If not doing AnCova then GC is irrelevant
if ~any(iGloNorm == [1:7])
	iGC = 12;
	gc  = [];
else
	%-Annotate options 10 & 11 with specific details
	%---------------------------------------------------------------
	%-Tag '(as implied by AnCova)' with actual AnCova situation
	sCC{10} = [sCC{iGloNorm},' (<= ',sGloNorm,')'];
	%-Tag 'GM' case with actual GM & GMsca case
	sCC{11} = sprintf('around GM=%g (i.e. %s after grand mean scaling)',...
		GM,strrep(sCC{iGMsca},'around ',''));

	%-Constuct vector of allowable iGC
	%---------------------------------------------------------------
	%-Weed out redundent factor combinations from pre-set allowable options
	iGC = intersect(abs(D.iGC),find([1,bFI,1,1,1,1]));
	%-Omit 'GM' option if didn't GMsca (iGMsca~=8 'cos doing AnCova)
	if any(iGMsca==[8,9]), iGC = setdiff(iGC,11); end
	%-Omit 'GM' option if same as '(as implied by AnCova)'
	if iGloNorm==iGMsca, iGC = setdiff(iGC,11); end

	%-If there's a choice, set defaults (if any), & get answer
	%---------------------------------------------------------------
	if length(iGC)>1
		dGC = max([0,intersect(iGC,-D.iGC(D.iGC<0))]);
		str = 'Centre global covariate';
		if iGMsca<8, str = [str,' (after grand mean scaling)']; end
		iGC = spm_input(str,'+1','m',sCC(iGC),iGC,find(iGC==dGC));
	elseif isempty(iGC)
		error('Configuration error: empty iGC')
	end

	%-If 'user specified' then get value
	%---------------------------------------------------------------
	if iGC==9
		gc     = spm_input('Centre globals around','+0','r',D.GM,1);
		sCC{9} = sprintf('%s of %g',sCC{iGC},gc);
	else
		gc  = 0;
	end
end


%-Thresholds & masks defining voxels to analyse                   (MASK)
%=======================================================================
GUIpos = spm_input('!NextPos');

%-Analysis threshold mask
%-----------------------------------------------------------------------
%-Work out available options:
% -Inf=>None, real=>absolute, complex=>proportional, (i.e. times global)
M_T = D.M_.T; if isempty(M_T), M_T = [-Inf, 100, 0.8*sqrt(-1)]; end
M_T = {	'none',		M_T(min(find(isinf(M_T))));...
	'absolute',	M_T(min(find(isfinite(M_T)&(M_T==real(M_T)))));...
	'relative',	M_T(min(find(isfinite(M_T)&(M_T~=real(M_T)))))	};

%-Work out available options
%-If there's a choice between proportional and absolute then ask
%-----------------------------------------------------------------------
q = ~[isempty(M_T{1,2}), isempty(M_T{2,2}), isempty(M_T{3,2})];

if all(q(2:3))
	tmp = spm_input('Threshold masking',GUIpos,'b',M_T(q,1),find(q));
	q(setdiff([1:3],tmp))=0;
end

%-Get mask value - note that at most one of q(2:3) is true
%-----------------------------------------------------------------------
if ~any(q)				%-Oops - nothing specified!
	M_T = -Inf;
elseif all(q==[1,0,0])			%-no threshold masking
	M_T = -Inf;
else					%-get mask value
	if q(1),	args = {'br1','None',-Inf,abs(M_T{1+find(q(2:3)),2})};
	else,		args = {'r',abs(M_T{1+find(q(2:3)),2})}; end
	if q(2)
		M_T = spm_input('threshold',GUIpos,args{:});
	elseif q(3)
		M_T = spm_input('threshold (relative to global)',GUIpos,...
								args{:});
		if isfinite(M_T) & isreal(M_T), M_T=M_T*sqrt(-1); end
	else
		error('Shouldn''t get here!')
	end
end

%-Make a description string
%-----------------------------------------------------------------------
if isinf(M_T)
	xsM.Analysis_threshold = 'None (-Inf)';
elseif isreal(M_T)
	xsM.Analysis_threshold = sprintf('images thresholded at %6g',M_T);
else
	xsM.Analysis_threshold = sprintf(['images thresholded at %6g ',...
		'times global'],imag(M_T));
end


%-Implicit masking: Ignore zero voxels in low data-types?
%-----------------------------------------------------------------------
% (Implicit mask is NaN in higher data-types.)
type = mars_vol_utils('type', spm_vol(P{1,1}));
if ~spm_type(type,'nanrep')
	switch D.M_.I
	case Inf,    M_I = spm_input('Implicit mask (ignore zero''s)?',...
			'+1','y/n',[1,0],1);		%-Ask
	case {0,1}, M_I = D.M_.I;			%-Pre-specified
	otherwise,  error('unrecognised D.M_.I type')
	end

	if M_I, xsM.Implicit_masking = 'Yes: zero''s treated as missing';
	else,   xsm.Implicit_masking = 'No'; end
else
	M_I = 1;
	xsM.Implicit_masking = 'Yes: NaN''s treated as missing';
end


%-Explicit mask images (map them later...)
%-----------------------------------------------------------------------
switch(D.M_.X)
case Inf,   M_X = spm_input('explicitly mask images?','+1','y/n',[1,0],2);
case {0,1}, M_X = D.M_.X;
otherwise,  error('unrecognised D.M_.X type')
end
if M_X, M_P = spm_get(Inf,img_flt,{'select mask images'}); else, M_P = {}; end


%-Global calculation                                            (GXcalc)
%=======================================================================
iGXcalc = abs(D.iGXcalc);
%-Only offer "omit" option if not doing any GloNorm, GMsca or PropTHRESH
if ~(iGloNorm==9 & iGMsca==9 & (isinf(M_T)|isreal(M_T)))
	iGXcalc = intersect(iGXcalc,[2:size(sGXcalc,1)]);
end
if isempty(iGXcalc)
	error('no GXcalc options')
elseif length(iGXcalc)>1
	%-User choice of global calculation options, default is negative
	dGXcalc = max([1,intersect(iGXcalc,-D.iGXcalc(D.iGXcalc<0))]);
	iGXcalc = spm_input('Global calculation','+1','m',...
	    	sGXcalc(iGXcalc),iGXcalc,find(iGXcalc==dGXcalc));
else
	iGXcalc = abs(D.iGXcalc);
end

if iGXcalc==2				%-Get user specified globals
	g = spm_input('globals','+0','r',[],[nScan,1]);
end
sGXcalc = sGXcalc{iGXcalc};


% Non-sphericity correction
%=======================================================================

% if there are multilevel factors, ask for correction
%-----------------------------------------------------------------------
if length(find(max(I) > 1)) > 1
	xVi.iid  = spm_input('non-sphericity correction?','+1','y/n',[0,1],1);
else
	xVi.iid  = 1;
end


if xVi.iid

	% i.i.d. assumptions where xVi.V = 1
	%---------------------------------------------------------------
	xVi.V    = speye(nScan);

else
	% otherwise, we have repeated measures design 
	%===============================================================
	nL      = max(I);		% number of levels
	mL      = find(nL > 1);		% multilevel factors
	xVi.I   = I;
	xVi.sF  = D.sF;
	xVi.var = sparse(1,4);
	xVi.dep = sparse(1,4);


	% eliminate replication factor from mL
	%---------------------------------------------------------------
	for i = 1:4
		mstr{i} = sprintf('%s (%i)',D.sF{i},nL(i));
	end
	str   = 'replications are over?';
	rep   = spm_input(str,'+1','m',mstr(mL),1:length(mL));

	% and ask whether repeated measures are independent
	%---------------------------------------------------------------
	str   = 'correlated repeated measures';
	dep   = spm_input(str,'+1','b',{'yes','no'},[1 0],1);


	%-Place covariance components Q{:} in xVi.Vi
	%---------------------------------------------------------------
	mL(rep)     = [];
	xVi.var(mL) = 1;
	xVi.dep(mL) = dep;
	xVi         = spm_non_sphericity(xVi);

end


%=======================================================================
% - C O N F I G U R E   D E S I G N
%=======================================================================
spm('FigName','Stats: configuring',Finter,CmdLine);
spm('Pointer','Watch');


%-Images & image info: Map Y image files and check consistency of
% dimensions and orientation / voxel size
%=======================================================================
fprintf('%-40s: ','Mapping files')                                   %-#
VY    = spm_vol(char(P));


%-Check compatability of images
%-----------------------------------------------------------------------
[samef msg] = mars_vol_check(VY);
if ~samef, disp(char(msg)),error('Cannot use images'),end;

fprintf('%30s\n','...done')                                          %-#


%-Global values, scaling and global normalisation
%=======================================================================
%-Compute global values
%-----------------------------------------------------------------------
switch iGXcalc, case 1
	%-Don't compute => no GMsca (iGMsca==9) or GloNorm (iGloNorm==9)
	g = [];
case 2
	%-User specified globals
case 3
	%-Compute as mean voxel value (within per image fullmean/8 mask)
	g     = zeros(nScan,1 );
	fprintf('%-40s: %30s','Calculating globals',' ')             %-#
	for i = 1:nScan
		str = sprintf('%3d/%-3d',i,nScan);
		fprintf('%s%30s',repmat(sprintf('\b'),1,30),str)%-#
		g(i) = spm_global(VY(i));
	end
	fprintf('%s%30s\n',repmat(sprintf('\b'),1,30),'...done')       %-#
otherwise
	error('illegal iGXcalc')
end
rg = g;


fprintf('%-40s: ','Design configuration')                            %-#


%-Scaling: compute global scaling factors gSF required to implement proportional
% scaling global normalisation (PropSca) or grand mean scaling (GMsca),
% as specified by iGMsca (& iGloNorm)
%-----------------------------------------------------------------------
switch iGMsca, case 8
	%-Proportional scaling global normalisation
	if iGloNorm~=8, error('iGloNorm-iGMsca(8) mismatch for PropSca'), end
	gSF    = GM./g;
	g      = GM*ones(nScan,1);
case {1,2,3,4,5,6,7}
	%-Grand mean scaling according to iGMsca
	gSF    = GM./spm_meanby(g,eval(CCforms{iGMsca}));
	g      = g.*gSF;
case 9
	%-No grand mean scaling
	gSF    = ones(nScan,1);
otherwise
	error('illegal iGMsca')
end


%-Apply gSF to memory-mapped scalefactors to implement scaling
%-----------------------------------------------------------------------
for i = 1:nScan
	VY(i).pinfo(1:2,:) = VY(i).pinfo(1:2,:)*gSF(i);
end


%-AnCova: Construct global nuisance covariates partition (if AnCova)
%-----------------------------------------------------------------------
if any(iGloNorm == [1:7])

	%-Centre global covariate as requested
	%---------------------------------------------------------------
	switch iGC, case {1,2,3,4,5,6,7}	%-Standard sCC options
		gc = spm_meanby(g,eval(CCforms{iGC}));
	case 8					%-No centering
		gc = 0;
	case 9					%-User specified centre
		%-gc set above
	case 10					%-As implied by AnCova option
		gc = spm_meanby(g,eval(CCforms{iGloNorm}));
	case 11					%-Around GM
		gc = GM;
	otherwise				%-unknown iGC
		error('unexpected iGC value')
	end
	
	
	%-AnCova - add scaled centred global to DesMtx `G' partition
	%---------------------------------------------------------------
	rcname     = 'global'; 
	tI         = [eval(CFIforms{iGloNorm,1}),g - gc];
	tConst     = CFIforms{iGloNorm,2};
	tFnames    = [eval(CFIforms{iGloNorm,3}),{rcname}];
	[f,gnames]  = spm_DesMtx(tI,tConst,tFnames);
	clear tI tConst tFnames
	
	%-Save GX info in xC struct for reference
	%---------------------------------------------------------------
	str     = {sprintf('%s: %s',dstr{2},rcname)};
	if any(iGMsca==[1:7]), str=[str;{['(after ',sGMsca,')']}]; end
	if iGC ~= 8, str=[str;{['used centered ',sCC{iGC}]}]; end
	if iGloNorm > 1
		str=[str;{['fitted as interaction ',sCFI{iGloNorm}]}]; 
	end
	tmp  = struct(	'rc',rg.*gSF,		'rcname',rcname,...
			'c',f,			'cname'	,{gnames},...
			'iCC',iGC,		'iCFI'	,iGloNorm,...
			'type',			3,...
			'cols',[1:size(f,2)] + size([H C B G],2),...
				'descrip',		{str}		);

	G = [G,f]; Gnames = [Gnames; gnames];
	if isempty(xC), xC = tmp; else, xC = [xC,tmp]; end


elseif iGloNorm==8 | iGXcalc>1

	%-Globals calculated, but not AnCova: Make a note of globals
	%---------------------------------------------------------------
	if iGloNorm==8
		str = { 'global values: (used for proportional scaling)';...
			'("raw" unscaled globals shown)'};
	elseif isfinite(M_T) & ~isreal(M_T)
		str = { 'global values: (used to compute analysis threshold)'};
	else
		str = { 'global values: (computed but not used)'};
	end

	rcname ='global';
	tmp     = struct(	'rc',rg,	'rcname',rcname,...
				'c',{[]},	'cname'	,{{}},...
				'iCC',0,	'iCFI'	,0,...
				'type',		3,...
				'cols',		{[]},...
				'descrip',	{str}			);

	if isempty(xC), xC = tmp; else, xC = [xC,tmp]; end
end


%-Save info on global calculation in xGX structure
%-----------------------------------------------------------------------
xGX = struct(...
	'iGXcalc',iGXcalc,	'sGXcalc',sGXcalc,	'rg',rg,...
	'iGMsca',iGMsca,	'sGMsca',sGMsca,	'GM',GM,'gSF',gSF,...
	'iGC',	iGC,		'sGC',	sCC{iGC},	'gc',	gc,...
	'iGloNorm',iGloNorm,	'sGloNorm',sGloNorm);



%-Construct masking information structure and compute actual analysis
% threshold using scaled globals (rg.*gSF)
%-----------------------------------------------------------------------
if isreal(M_T),	M_TH =      M_T  * ones(nScan,1);	%-NB: -Inf is real
else,		M_TH = imag(M_T) * (rg.*gSF); end

if ~isempty(M_P)
	VM  = spm_vol(char(M_P));
	xsM.Explicit_masking = [{'Yes: mask images :'};{VM.fname}'];
else
	VM  = [];
	xsM.Explicit_masking = 'No';
end
xM     = struct('T',M_T, 'TH',M_TH, 'I',M_I, 'VM',{VM}, 'xs',xsM);


%-Construct full design matrix (X), parameter names and structure (xX)
%=======================================================================
X      = [H C B G];
tmp    = cumsum([size(H,2), size(C,2), size(B,2), size(G,2)]);
xX     = struct(	'X',		X,...
			'iH',		[1:size(H,2)],...
			'iC',		[1:size(C,2)] + tmp(1),...
			'iB',		[1:size(B,2)] + tmp(2),...
			'iG',		[1:size(G,2)] + tmp(3),...
			'name',		{[Hnames; Cnames; Bnames; Gnames]},...
			'I',		I,...
			'sF',		{D.sF});


%-Design description (an nx2 cellstr) - for saving and display
%=======================================================================
tmp = {	sprintf('%d condition, +%d covariate, +%d block, +%d nuisance',...
		size(H,2),size(C,2),size(B,2),size(G,2));...
	sprintf('%d total, having %d degrees of freedom',...
		size(X,2),rank(X));...
	sprintf('leaving %d degrees of freedom from %d images',...
		size(X,1)-rank(X),size(X,1))				};
xsDes = struct(	'Design',			{D.DesName},...
		'Global_calculation',		{sGXcalc},...
		'Grand_mean_scaling',		{sGMsca},...
		'Global_normalisation',		{sGloNorm},...
		'Parameters',			{tmp}			);


fprintf('%30s\n','...done')                                          %-#



%-Assemble SPM structure
%=======================================================================
SPM.xY.P	= P;			% filenames
SPM.xY.VY	= VY;			% mapped data
SPM.nscan	= size(xX.X,1);		% scan number
SPM.xX		= xX;			% design structure
SPM.xC		= xC;			% covariate structure
SPM.xGX		= xGX;			% global structure
SPM.xVi		= xVi;			% non-sphericity structure
SPM.xM		= xM;			% mask structure
SPM.xsDes	= xsDes;		% description
SPM.SPMid	= SPMid;		% version

varargout = {SPM};

%-End: Cleanup GUI
%=======================================================================
spm_clf(Finter)
spm('Pointer','Arrow')
fprintf('%-40s: %30s\n','Completed',spm('time'))                     %-#
spm('FigName','Stats: configured',Finter,CmdLine);
spm('Pointer','Arrow')
fprintf('\n\n')



case 'files&indices'
%=======================================================================
% - Get files and factor indices
%=======================================================================
% [P,I] = pr_spm_ui('Files&Indices',DsF,Dn,DbaTime,nV)
% DbaTime=D.b.aTime; Dn=D.n; DsF=D.sF;
if nargin<5, nV = 1; else, nV = varargin{5}; end
if nargin<4, DbaTime = 1; else, DbaTime = varargin{4}; end
if nargin<3, Dn  = [Inf,Inf,Inf,Inf]; else, Dn=varargin{3}; end
if nargin<2, DsF = {'Fac1','Fac2','Fac3','Fac4'}; else, DsF=varargin{2}; end

%-Initialise variables
%-----------------------------------------------------------------------
i4 = [];		% factor 4 index (usually group)
i3 = [];		% factor 3 index (usually subject), per f4
i2 = [];		% factor 2 index (usually condition), per f3/f4
i1 = [];		% factor 1 index (usually replication), per f2/f3/f4
P  = {};		% cell array of string filenames

%-Accrue filenames and factor level indicator vectors
%-----------------------------------------------------------------------
bMV = nV>1;
if isinf(Dn(4)), n4 = spm_input(['#',DsF{4},'''s'],'+1','n1');
	else, n4 = Dn(4); end
bL4 = n4>1;

ti2 = '';
GUIpos = spm_input('!NextPos');
for j4  = 1:n4
    spm_input('!SetNextPos',GUIpos);
    sF4P=''; if bL4, sF4P=[DsF{4},' ',int2str(j4),': ']; end
    if isinf(Dn(3)), n3=spm_input([sF4P,'#',DsF{3},'''s'],'+1','n1');
	    else, n3 = Dn(3); end
    bL3 = n3>1;
    
    if DbaTime & Dn(2)>1
	%disp('NB:selecting in time order - manually specify conditions')
	%-NB: This means f2 levels might not be 1:n2
	GUIpos2 = spm_input('!NextPos');
	for j3 = 1:n3
	    sF3P=''; if bL3, sF3P=[DsF{3},' ',int2str(j3),': ']; end
	    str = [sF4P,sF3P];
	    tP  = {};
	    n21 = Dn(2)*Dn(1);
	    for v=1:nV
	    	vstr=''; if bMV, vstr=sprintf(' (var-%d)',v); end
	    	ttP = spm_get(n21,img_flt,{[str,'select images',vstr]});
	    	n21 = length(ttP);
	    	tP  = [tP,ttP];
	    end
	    ti2 = spm_input([str,' ',DsF{2},'?'],GUIpos2,'c',ti2',n21,Dn(2));
	    %-Work out i1 & check
	    [tl2,null,j] = unique(ti2);
	    tn1 = zeros(size(tl2)); ti1 = zeros(size(ti2));
	    for i=1:length(tl2)
		    tn1(i)=sum(j==i); ti1(ti2==tl2(i))=1:tn1(i); end
	    if isfinite(Dn(1)) & any(tn1~=Dn(1))
		%-#i1 levels mismatches specification in Dn(1)
		error(sprintf('#%s not %d as pre-specified',DsF{1},Dn(1)))
	    end
	    P  = [P;tP];
	    i4 = [i4; j4*ones(n21,1)];
	    i3 = [i3; j3*ones(n21,1)];
	    i2 = [i2; ti2];
	    i1 = [i1; ti1];
	end

    else

	if isinf(Dn(2))
	    n2 = spm_input([sF4P,'#',DsF{2},'''s'],'+1','n1');
	else
	    n2 = Dn(2);
	end
	bL2 = n2>1;

	if n2==1 & Dn(1)==1 %-single scan per f3 (subj)
	    %disp('NB:single scan per f3')
	    str = [sF4P,'select images, ',DsF{3},' 1-',int2str(n3)];
	    tP = {};
	    for v=1:nV
	    	vstr=''; if bMV, vstr=sprintf(' (var-%d)',v); end
	    	ttP = spm_get(n3,img_flt,{[str,vstr]});
	    	tP = [tP,ttP];
	    end
	    P   = [P;tP];
	    i4  = [i4; j4*ones(n3,1)];
	    i3  = [i3; [1:n3]'];
	    i2  = [i2; ones(n3,1)];
	    i1  = [i1; ones(n3,1)];
	else
	    %-multi scan per f3 (subj) case
	    %disp('NB:multi scan per f3')
	    for j3 = 1:n3
		sF3P=''; if bL3, sF3P=[DsF{3},' ',int2str(j3),': ']; end
		if Dn(1)==1
			%-No f1 (repl) within f2 (cond)
			%disp('NB:no f1 within f2')
			str = [sF4P,sF3P,'select images: ',DsF{2},...
				 ' 1-',int2str(n2)];
			tP = {};
			for v=1:nV
				vstr=''; if bMV, vstr=sprintf(' (var-%d)',v); end
				ttP = spm_get(n2,img_flt,{[str,vstr]});
				tP = [tP,ttP];
			end
			P   = [P;tP];
			i4  = [i4; j4*ones(n2,1)];
			i3  = [i3; j3*ones(n2,1)];
			i2  = [i2; [1:n2]'];
			i1  = [i1; ones(n2,1)];
		else
		    %-multi f1 (repl) within f2 (cond)
		    %disp('NB:f1 within f2')
		    for j2  = 1:n2
			sF2P='';
			if bL2, sF2P=[DsF{2},' ',int2str(j2),': ']; end
			str = [sF4P,sF3P,sF2P,' select images...'];
			tP  = {};
			n1  = Dn(1);
			for v=1:nV
				vstr=''; if bMV, vstr=sprintf(' (var-%d)',v); end
				ttP = spm_get(n1,img_flt,{[str,vstr]});
				n1  = length(ttP);
				tP  = [tP,ttP];
			end
			P   = [P;tP];
			i4  = [i4; j4*ones(n1,1)];
			i3  = [i3; j3*ones(n1,1)];
			i2  = [i2; j2*ones(n1,1)];
			i1  = [i1; [1:n1]'];
		    end                         % (for j2)
		end                             % (if Dn(1)==1)
	    end                                 % (for j3)
	end                                     % (if  n2==1 &...)
    end                                         % (if DbaTime & Dn(2)>1)
end                                             % (for j4)
varargout = {P,[i1,i2,i3,i4]};


case 'desdefs_stats'
%=======================================================================
% - Basic Stats Design definitions...
%=======================================================================
% D = pr_spm_ui('DesDefs_Stats');
% These are the basic Stats design definitions...

%-Note: struct expands cell array values to give multiple records:
%       => must embed cell arrays within another cell array!
%-Negative indices indicate defaults (first used)

D = struct(...
	'DesName','One sample t-test',...
	'n',	[Inf 1 1 1],	'sF',{{'obs','','',''}},...
	'Hform',		'I(:,2),''-'',''mean''',...
	'Bform',		'[]',...
	'nC',[0,0],'iCC',{{8,8}},'iCFI',{{1,1}},...
	'iGXcalc',[-1,2,3],'iGMsca',[1,-9],'GM',[],...
	'iGloNorm',9,'iGC',12,...
	'M_',struct('T',-Inf,'I',Inf,'X',Inf),...
	'b',struct('aTime',0));

D = [D, struct(...
	'DesName','Two sample t-test',...
	'n',	[Inf 2 1 1],	'sF',{{'obs','group','',''}},...
	'Hform',		'I(:,2),''-'',''group''',...
	'Bform',		'I(:,3),''-'',''\mu''',...
	'nC',[0,0],'iCC',{{8,8}},'iCFI',{{1,1}},...
	'iGXcalc',[-1,2,3],'iGMsca',[1,-9],'GM',[],...
	'iGloNorm',9,'iGC',12,...
	'M_',struct('T',[-Inf,0,0.8*sqrt(-1)],'I',Inf,'X',Inf),...
	'b',struct('aTime',1))];

D = [D, struct(...
	'DesName','Paired t-test',...
	'n',	[1 2 Inf 1],	'sF',{{'','cond','pair',''}},...
	'Hform',		'I(:,2),''-'',''condition''',...
	'Bform',		'I(:,3),''-'',''\gamma''',...
	'nC',[0,0],'iCC',{{8,8}},'iCFI',{{1,1}},...
	'iGXcalc',[-1,2,3],'iGMsca',[1,-9],'GM',[],...
	'iGloNorm',9,'iGC',12,...
	'M_',struct('T',[-Inf,0,0.8*sqrt(-1)],'I',Inf,'X',Inf),...
	'b',struct('aTime',0))];

D = [D, struct(...
	'DesName','One way Anova',...
	'n',	[Inf Inf 1 1],	'sF',{{'repl','group','',''}},...
	'Hform',		'I(:,2),''-'',''group''',...
	'Bform',		'[]',...
	'nC',[0,0],'iCC',{{8,8}},'iCFI',{{1,1}},...
	'iGXcalc',[-1,2,3],'iGMsca',[1,-9],'GM',[],...
	'iGloNorm',9,'iGC',12,...
	'M_',struct('T',[-Inf,0,0.8*sqrt(-1)],'I',Inf,'X',Inf),...
	'b',struct('aTime',0))];

D = [D, struct(...
	'DesName','One way Anova (with constant)',...
	'n',	[Inf Inf 1 1],	'sF',{{'repl','group','',''}},...
	'Hform',		'I(:,2),''-'',''group''',...
	'Bform',		'I(:,3),''-'',''\mu''',...
	'nC',[0,0],'iCC',{{8,8}},'iCFI',{{1,1}},...
	'iGXcalc',[-1,2,3],'iGMsca',[1,-9],'GM',[],...
	'iGloNorm',9,'iGC',12,...
	'M_',struct('T',[-Inf,0,0.8*sqrt(-1)],'I',Inf,'X',Inf),...
	'b',struct('aTime',0))];

D = [D, struct(...
	'DesName','One way Anova (Within-subjects)',...
	'n',	[1 Inf Inf 1],'sF',{{'repl','condition','subject',''}},...
	'Hform',		'I(:,2),''-'',''cond''',...
	'Bform',		'I(:,3),''-'',''subj''',...
	'nC',[0,0],'iCC',{{8,8}},'iCFI',{{1,1}},...
	'iGXcalc',[-1,2,3],'iGMsca',[1,-9],'GM',[],...
	'iGloNorm',9,'iGC',12,...
	'M_',struct('T',[-Inf,0,0.8*sqrt(-1)],'I',Inf,'X',Inf),...
	'b',struct('aTime',0))];

D = [D, struct(...
	'DesName','Simple regression (correlation)',...
	'n',	[Inf 1 1 1],	'sF',{{'repl','','',''}},...
	'Hform',		'[]',...
	'Bform',		'I(:,2),''-'',''\mu''',...
	'nC',[1,0],'iCC',{{8,8}},'iCFI',{{1,1}},...
	'iGXcalc',[-1,2,3],'iGMsca',[1,-9],'GM',[],...
	'iGloNorm',9,'iGC',12,...
	'M_',struct('T',[-Inf,0,0.8*sqrt(-1)],'I',Inf,'X',Inf),...
	'b',struct('aTime',0))];


D = [D, struct(...
	'DesName','Multiple regression',...
	'n',	[Inf 1 1 1],	'sF',{{'repl','','',''}},...
	'Hform',		'[]',...
	'Bform',		'[]',...
	'nC',[Inf,0],'iCC',{{8,8}},'iCFI',{{1,1}},...
	'iGXcalc',[-1,2,3],'iGMsca',[1,-9],'GM',[],...
	'iGloNorm',9,'iGC',12,...
	'M_',struct('T',[-Inf,0,0.8*sqrt(-1)],'I',Inf,'X',Inf),...
	'b',struct('aTime',0))];

D = [D, struct(...
	'DesName','Multiple regression (with constant)',...
	'n',	[Inf 1 1 1],	'sF',{{'repl','','',''}},...
	'Hform',		'[]',...
	'Bform',		'I(:,2),''-'',''\mu''',...
	'nC',[Inf,0],'iCC',{{8,8}},'iCFI',{{1,1}},...
	'iGXcalc',[-1,2,3],'iGMsca',[1,-9],'GM',[],...
	'iGloNorm',9,'iGC',12,...
	'M_',struct('T',[-Inf,0,0.8*sqrt(-1)],'I',Inf,'X',Inf),...
	'b',struct('aTime',0))];

D = [D, struct(...
	'DesName','AnCova',...
	'n',	[Inf Inf 1 1],	'sF',{{'repl','group','',''}},...
	'Hform',		'I(:,2),''-'',''group''',...
	'Bform',		'I(:,3),''-'',''\mu''',...
	'nC',[0,1],'iCC',{{8,1}},'iCFI',{{1,1}},...
	'iGXcalc',[-1,2,3],'iGMsca',[1,-9],'GM',[],...
	'iGloNorm',9,'iGC',12,...
	'M_',struct('T',[-Inf,0,0.8*sqrt(-1)],'I',Inf,'X',Inf),...
	'b',struct('aTime',0))];

varargout = {D};


case 'desdefs_pet'
%=======================================================================
% - Standard (SPM99) PET/SPECT Design definitions...
%=======================================================================
% D = pr_spm_ui('DesDefs_PET');
% These are the standard PET design definitions...

%-Single subject
%-----------------------------------------------------------------------
D = struct(...
	'DesName','Single-subject: conditions & covariates',...
	'n',	[Inf Inf 1 1],	'sF',{{'repl','condition','',''}},...
	'Hform',		'I(:,2),''-'',''cond''',...
	'Bform',		'I(:,3),''-'',''\mu''',...
	'nC',[Inf,Inf],'iCC',{{[-1,3,8],[-1,8]}},'iCFI',{{[1,3],1}},...
	'iGXcalc',[1,2,-3],'iGMsca',[-1,9],'GM',50,...
	'iGloNorm',[1,8,9],'iGC',10,...
	'M_',struct('T',[0,0.8*sqrt(-1)],'I',0,'X',0),...
	'b',struct('aTime',1));

D = [D, struct(...
	'DesName','Single-subject: covariates only',...
	'n',	[Inf 1 1 1],	'sF',{{'repl','','',''}},...
	'Hform',		'[]',...
	'Bform',		'I(:,3),''-'',''\mu''',...
	'nC',[Inf,Inf],'iCC',{{[-1,8],[-1,8]}},'iCFI',{{1,1}},...
	'iGXcalc',[1,2,-3],'iGMsca',[-1,9],'GM',50,...
	'iGloNorm',[1,8,9],'iGC',10,...
	'M_',struct('T',[0,0.8*sqrt(-1)],'I',0,'X',0),...
	'b',struct('aTime',1))];

%-Multi-subject
%-----------------------------------------------------------------------
D = [D, struct(...
	'DesName','Multi-subj: conditions & covariates',...
	'n',[Inf Inf Inf 1],	'sF',{{'repl','condition','subject',''}},...
	'Hform',		'I(:,2),''-'',''cond''',...
	'Bform',		'I(:,3),''-'',''subj''',...
	'nC',[Inf,Inf],'iCC',{{[1,3,4,8],[1,4,8]}},'iCFI',{{[1,3,-4],[1,-4]}},...
	'iGXcalc',[1,2,-3],'iGMsca',[-4,9],'GM',50,...
	'iGloNorm',[4,8,9],'iGC',10,...
	'M_',struct('T',[0,0.8*sqrt(-1)],'I',0,'X',0),...
	'b',struct('aTime',1))];

D = [D, struct(...
	'DesName','Multi-subj: cond x subj  interaction & covariates',...
	'n',[Inf Inf Inf 1],	'sF',{{'repl','condition','subject',''}},...
	'Hform',		'I(:,[3,2]),''-'',{''subj'',''cond''}',...
	'Bform',		'I(:,3),''-'',''subj''',...
	'nC',[Inf,Inf],'iCC',{{[1,3,4,8],[1,4,8]}},'iCFI',{{[1,3,-4],[1,-4]}},...
	'iGXcalc',[1,2,-3],'iGMsca',[-4,9],'GM',50,...
	'iGloNorm',[4,8,9],'iGC',10,...
	'M_',struct('T',[0,0.8*sqrt(-1)],'I',0,'X',0),...
	'b',struct('aTime',1))];

D = [D, struct(...
	'DesName','Multi-subj: covariates only',...
	'n',[Inf 1 Inf 1],	'sF',{{'repl','','subject',''}},...
	'Hform',		'[]',...
	'Bform',		'I(:,3),''-'',''subj''',...
	'nC',[Inf,Inf],'iCC',{{[1,4,8],[1,4,8]}},'iCFI',{{[1,-4],[1,-4]}},...
	'iGXcalc',[1,2,-3],'iGMsca',[-4,9],'GM',50,...
	'iGloNorm',[4,8:9],'iGC',10,...
	'M_',struct('T',[0,0.8*sqrt(-1)],'I',0,'X',0),...
	'b',struct('aTime',0))];

%-Multi-group
%-----------------------------------------------------------------------
D = [D, struct(...
	'DesName','Multi-group: conditions & covariates',...
	'n',[Inf Inf Inf Inf],	'sF',{{'repl','condition','subject','group'}},...
	'Hform',		'I(:,[4,2]),''-'',{''stud'',''cond''}',...
	'Bform',		'I(:,[4,3]),''-'',{''stud'',''subj''}',...
	'nC',[Inf,Inf],'iCC',{{[5:8],[5,7,8]}},'iCFI',{{[1,5,6,-7],[1,5,-7]}},...
	'iGXcalc',[1,2,-3],'iGMsca',[-7,9],'GM',50,...
	'iGloNorm',[7,8,9],'iGC',10,...
	'M_',struct('T',[0,0.8*sqrt(-1)],'I',0,'X',0),...
	'b',struct('aTime',1))];

D = [D, struct(...
	'DesName','Multi-group: covariates only',...
	'n',[Inf 1 Inf Inf],	'sF',{{'repl','','subject','group'}},...
	'Hform',		'[]',...
	'Bform',		'I(:,[4,3]),''-'',{''stud'',''subj''}',...
	'nC',[Inf,Inf],'iCC',{{[5,7,8],[5,7,8]}},'iCFI',{{[1,5,-7],[1,5,-7]}},...
	'iGXcalc',[1,2,-3],'iGMsca',[-7,9],'GM',50,...
	'iGloNorm',[7,8,9],'iGC',10,...
	'M_',struct('T',[0,0.8*sqrt(-1)],'I',0,'X',0),...
	'b',struct('aTime',0))];

%-Population comparisons
%-----------------------------------------------------------------------
D = [D, struct(...
	'DesName',...
	'Population main effect: 2 cond''s, 1 scan/cond (paired t-test)',...
	'n',[1 2 Inf 1],	'sF',{{'','condition','subject',''}},...
	'Hform',		'I(:,2),''-'',''cond''',...
	'Bform',		'I(:,3),''-'',''\mu''',...
	'nC',[0,0],'iCC',{{8,8}},'iCFI',{{1,1}},...
	'iGXcalc',[1,2,-3],'iGMsca',[-1,9],'GM',50,...
	'iGloNorm',[8,9],'iGC',10,...
	'M_',struct('T',[0,0.8*sqrt(-1)],'I',0,'X',0),...
	'b',struct('aTime',0))];

D = [D, struct(...
	'DesName',...
	'Dodgy population main effect: >2 cond''s, 1 scan/cond',...
	'n',[1 Inf Inf 1],	'sF',{{'','condition','subject',''}},...
	'Hform',		'I(:,2),''-'',''cond''',...
	'Bform',		'I(:,3),''-'',''\mu''',...
	'nC',[0,0],'iCC',{{8,8}},'iCFI',{{1,1}},...
	'iGXcalc',[1,2,-3],'iGMsca',[-1,9],'GM',50,...
	'iGloNorm',[8,9],'iGC',10,...
	'M_',struct('T',[0,0.8*sqrt(-1)],'I',0,'X',0),...
	'b',struct('aTime',0))];

D = [D, struct(...
	'DesName','Compare-populations: 1 scan/subject (two sample t-test)',...
	'n',[Inf 2 1 1],	'sF',{{'subject','group','',''}},...
	'Hform',		'I(:,2),''-'',''group''',...
	'Bform',		'I(:,3),''-'',''\mu''',...
	'nC',[0,0],'iCC',{{8,8}},'iCFI',{{1,1}},...
	'iGXcalc',[1,2,-3],'iGMsca',[-1,9],'GM',50,...
	'iGloNorm',[8,9],'iGC',10,...
	'M_',struct('T',[0,0.8*sqrt(-1)],'I',0,'X',0),...
	'b',struct('aTime',0))];

D = [D, struct(...
	'DesName','Compare-populations: 1 scan/subject (AnCova)',...
	'n',[Inf 2 1 1],	'sF',{{'subject','group','',''}},...
	'Hform',		'I(:,2),''-'',''group''',...
	'Bform',		'I(:,3),''-'',''\mu''',...
	'nC',[0,Inf],'iCC',{{8,1}},'iCFI',{{1,1}},...
	'iGXcalc',[1,2,-3],'iGMsca',[-1,9],'GM',50,...
	'iGloNorm',[1,8,9],'iGC',10,...
	'M_',struct('T',[0,0.8*sqrt(-1)],'I',0,'X',0),...
	'b',struct('aTime',0))];

%-The Full Monty!
%-----------------------------------------------------------------------
D = [D, struct(...
	'DesName','The Full Monty...',...
	'n',[Inf Inf Inf Inf],	'sF',{{'repl','cond','subj','group'}},...
	'Hform',		'I(:,[4,2]),''-'',{''stud'',''cond''}',...
	'Bform',		'I(:,[4,3]),''-'',{''stud'',''subj''}',...
	'nC',[Inf,Inf],'iCC',{{[1:8],[1:8]}},'iCFI',{{[1:7],[1:7]}},...
	'iGXcalc',[1,2,3],'iGMsca',[1:7],'GM',50,...
	'iGloNorm',[1:9],'iGC',[1:11],...
	'M_',struct('T',[-Inf,0,0.8*sqrt(-1)],'I',Inf,'X',Inf),...
	'b',struct('aTime',1))];


varargout = {D};

case 'desdefs_pet96'
%=======================================================================
% - SPM96 PET/SPECT Design definitions...
%=======================================================================
% D = pr_spm_ui('DesDefs_PET96');

%-Single subject
%-----------------------------------------------------------------------
D = struct(...
	'DesName','SPM96:Single-subject: replicated conditions',...
	'n',	[Inf Inf 1 1],	'sF',{{'repl','condition','',''}},...
	'Hform',		'I(:,2),''-'',''cond''',...
	'Bform',		'I(:,3),''-'',''\mu''',...
	'nC',[0,0],'iCC',{{8,8}},'iCFI',{{1,1}},...
	'iGXcalc',3,'iGMsca',[1,9],'GM',50,...
	'iGloNorm',[1,8,9],'iGC',10,...
	'M_',struct('T',[0.8*sqrt(-1)],'I',0,'X',0),...
	'b',struct('aTime',0));

D = [D, struct(...
	'DesName','SPM96:Single-subject: replicated conditions & covariates',...
	'n',	[Inf Inf 1 1],	'sF',{{'repl','condition','',''}},...
	'Hform',		'I(:,2),''-'',''cond''',...
	'Bform',		'I(:,3),''-'',''\mu''',...
	'nC',[Inf,Inf],'iCC',{{1,1}},'iCFI',{{1,1}},...
	'iGXcalc',3,'iGMsca',[1,9],'GM',50,...
	'iGloNorm',[1,8,9],'iGC',10,...
	'M_',struct('T',[0.8*sqrt(-1)],'I',0,'X',0),...
	'b',struct('aTime',0))];

D = [D, struct(...
	'DesName','SPM96:Single-subject: covariates only',...
	'n',	[Inf 1 1 1],	'sF',{{'repl','','',''}},...
	'Hform',		'[]',...
	'Bform',		'I(:,3),''-'',''\mu''',...
	'nC',[Inf,Inf],'iCC',{{1,1}},'iCFI',{{1,1}},...
	'iGXcalc',3,'iGMsca',[1,9],'GM',50,...
	'iGloNorm',[1,8,9],'iGC',10,...
	'M_',struct('T',[0.8*sqrt(-1)],'I',0,'X',0),...
	'b',struct('aTime',0))];

%-Multi-subject
%-----------------------------------------------------------------------
D = [D, struct(...
	'DesName','SPM96:Multi-subject: different conditions',...
	'n',	[1 Inf Inf 1],	'sF',{{'','condition','subject',''}},...
	'Hform',		'I(:,2),''-'',''scancond''',...
	'Bform',		'I(:,3),''-'',''subj''',...
	'nC',[0,0],'iCC',{{8,8}},'iCFI',{{1,1}},...
	'iGXcalc',3,'iGMsca',[1,9],'GM',50,...
	'iGloNorm',[1,4,8,9],'iGC',10,...
	'M_',struct('T',[0.8*sqrt(-1)],'I',0,'X',0),...
	'b',struct('aTime',0))];

D = [D, struct(...
	'DesName','SPM96:Multi-subject: replicated conditions',...
	'n',[Inf Inf Inf 1],	'sF',{{'repl','condition','subject',''}},...
	'Hform',		'I(:,2),''-'',''cond''',...
	'Bform',		'I(:,3),''-'',''subj''',...
	'nC',[0,0],'iCC',{{8,8}},'iCFI',{{1,1}},...
	'iGXcalc',3,'iGMsca',[1,9],'GM',50,...
	'iGloNorm',[1,4,8,9],'iGC',10,...
	'M_',struct('T',[0.8*sqrt(-1)],'I',0,'X',0),...
	'b',struct('aTime',0))];

D = [D, struct(...
	'DesName','SPM96:Multi-subject: different conditions & covariates',...
	'n',	[1 Inf Inf 1],	'sF',{{'','condition','subject',''}},...
	'Hform',		'I(:,2),''-'',''cond''',...
	'Bform',		'I(:,3),''-'',''subj''',...
	'nC',[Inf,Inf],'iCC',{{1,1}},'iCFI',{{[1,4],[1,4]}},...
	'iGXcalc',3,'iGMsca',[1,9],'GM',50,...
	'iGloNorm',[1,4,8,9],'iGC',10,...
	'M_',struct('T',[0.8*sqrt(-1)],'I',0,'X',0),...
	'b',struct('aTime',0))];

D = [D, struct(...
	'DesName','SPM96:Multi-subject: replicated conditions & covariates',...
	'n',[Inf Inf Inf 1],	'sF',{{'repl','condition','subject',''}},...
	'Hform',		'I(:,2),''-'',''condition''',...
	'Bform',		'I(:,3),''-'',''subj''',...
	'nC',[Inf,Inf],'iCC',{{1,1}},'iCFI',{{[1,3,4],[1,4]}},...
	'iGXcalc',3,'iGMsca',[1,9],'GM',50,...
	'iGloNorm',[1,4,8,9],'iGC',10,...
	'M_',struct('T',[0.8*sqrt(-1)],'I',0,'X',0),...
	'b',struct('aTime',0))];

D = [D, struct(...
	'DesName','SPM96:Multi-subject: covariates only',...
	'n',[Inf 1 Inf 1],	'sF',{{'repl','','subject',''}},...
	'Hform',		'[]',...
	'Bform',		'I(:,3),''-'',''subj''',...
	'nC',[Inf,Inf],'iCC',{{[1,4,8],[1,4,8]}},'iCFI',{{[1,4],[1,4]}},...
	'iGXcalc',3,'iGMsca',[1,9],'GM',50,...
	'iGloNorm',[1,4,8,9],'iGC',10,...
	'M_',struct('T',[0.8*sqrt(-1)],'I',0,'X',0),...
	'b',struct('aTime',0))];

%-Multi-study
%-----------------------------------------------------------------------
D = [D, struct(...
	'DesName','SPM96:Multi-study: different conditions',...
	'n',[1 Inf Inf Inf],	'sF',{{'','cond','subj','study'}},...
	'Hform',		'I(:,[4,2]),''-'',{''study'',''cond''}',...
	'Bform',		'I(:,[4,3]),''-'',{''study'',''subj''}',...
	'nC',[0,0],'iCC',{{8,8}},'iCFI',{{1,1}},...
	'iGXcalc',3,'iGMsca',[1,5,9],'GM',50,...
	'iGloNorm',[1,5,7,8,9],'iGC',10,...
	'M_',struct('T',[0.8*sqrt(-1)],'I',0,'X',0),...
	'b',struct('aTime',0))];

D = [D, struct(...
	'DesName','SPM96:Multi-study: replicated conditions',...
	'n',[Inf Inf Inf Inf],	'sF',{{'repl','cond','subj','study'}},...
	'Hform',		'I(:,[4,2]),''-'',{''study'',''condition''}',...
	'Bform',		'I(:,[4,3]),''-'',{''study'',''subj''}',...
	'nC',[0,0],'iCC',{{8,8}},'iCFI',{{1,1}},...
	'iGXcalc',3,'iGMsca',[1,5,9],'GM',50,...
	'iGloNorm',[1,5,7,8,9],'iGC',10,...
	'M_',struct('T',[0.8*sqrt(-1)],'I',0,'X',0),...
	'b',struct('aTime',0))];

D = [D, struct(...
	'DesName','SPM96:Multi-study: different conditions & covariates',...
	'n',[1 Inf Inf Inf],	'sF',{{'','cond','subj','study'}},...
	'Hform',		'I(:,[4,2]),''-'',{''study'',''cond''}',...
	'Bform',		'I(:,[4,3]),''-'',{''study'',''subj''}',...
	'nC',[Inf,Inf],'iCC',{{1,1}},'iCFI',{{[1,5,6,7],[1,5,7]}},...
	'iGXcalc',3,'iGMsca',[1,5,9],'GM',50,...
	'iGloNorm',[1,5,7,8,9],'iGC',10,...
	'M_',struct('T',[0.8*sqrt(-1)],'I',0,'X',0),...
	'b',struct('aTime',0))];

D = [D, struct(...
	'DesName','SPM96:Multi-study: replicated conditions & covariates',...
	'n',[Inf Inf Inf Inf],	'sF',{{'','cond','subj','study'}},...
	'Hform',		'I(:,[4,2]),''-'',{''study'',''condition''}',...
	'Bform',		'I(:,[4,3]),''-'',{''study'',''subj''}',...
	'nC',[Inf,Inf],'iCC',{{1,1}},'iCFI',{{[1,5,6,7],[1,5,7]}},...
	'iGXcalc',3,'iGMsca',[1,5,9],'GM',50,...
	'iGloNorm',[1,5,7,8,9],'iGC',10,...
	'M_',struct('T',[0.8*sqrt(-1)],'I',0,'X',0),...
	'b',struct('aTime',0))];

D = [D, struct(...
	'DesName','SPM96:Multi-study: covariates only',...
	'n',[Inf 1 Inf Inf],	'sF',{{'repl','','subj','study'}},...
	'Hform',		'[]',...
	'Bform',		'I(:,[4,3]),''-'',{''study'',''subj''}',...
	'nC',[Inf,Inf],'iCC',{{1,1}},'iCFI',{{[1,5,7],[1,5,7]}},...
	'iGXcalc',3,'iGMsca',[1,5,9],'GM',50,...
	'iGloNorm',[1,5,7,8,9],'iGC',10,...
	'M_',struct('T',[0.8*sqrt(-1)],'I',0,'X',0),...
	'b',struct('aTime',0))];

%-Group comparisons
%-----------------------------------------------------------------------
D = [D, struct(...
	'DesName','SPM96:Compare-groups: 1 scan per subject',...
	'n',[Inf Inf 1 1],	'sF',{{'subject','group','',''}},...
	'Hform',		'I(:,2),''-'',''group''',...
	'Bform',		'[]',...
	'nC',[0,0],'iCC',{{8,8}},'iCFI',{{1,1}},...
	'iGXcalc',3,'iGMsca',[1,9],'GM',50,...
	'iGloNorm',[1,8,9],'iGC',10,...
	'M_',struct('T',[0.8*sqrt(-1)],'I',0,'X',0),...
	'b',struct('aTime',0))];

varargout = {D};


otherwise
%=======================================================================
% - U N K N O W N   A C T I O N
%=======================================================================
warning(['Illegal Action string: ',Action])


%=======================================================================
% - E N D
%=======================================================================
end




%=======================================================================
%- S U B - F U N C T I O N S
%=======================================================================

function str = sf_estrrep(str,srstr)
%=======================================================================
for i = 1:size(srstr,1)
	str = strrep(str,srstr{i,1},srstr{i,2});
end
