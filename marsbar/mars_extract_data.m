function Y = mars_extract_data(modality)
% helper function to extract raw / filtered data from images via ROIs
%-----------------------------------------------------------------------
%
% $Id$

if nargin < 1
  modality = 'FMRI';
end

switch lower(modality)
 case 'pet'
  filtf = 0;
  dGM   = 50;
  sess_str = 'Subject';
 case 'fmri'
  filtf = [];  % to be announced
  dGM =   100;
  sess_str = 'Session';
end
  
mars_opts = spm('GetGlobal', 'MARS.OPTIONS');
Y = [];
K = [];
VY = [];
Global = [];  

[Finter,Fgraph,CmdLine] = spm('FnUIsetup','Extract data from ROI(s)');

roilist = spm_get(Inf,'roi.mat','Select ROI(s) to extract data for');
if isempty(roilist)
  return
end

% filter data or no
if isempty(filtf)
  filtf = spm_input('Filter data', '+1','b',...
				      ['Yes|No'], [1 0],1);
end

% images
spmf = spm_input('Images from:', '+1','b',['SPM*.mat|GUI select'], ...
		 [1 0], 2);

% get images, from SPM, or by hand
if spmf
  S = marsbar('get_spmmat');
  if ~isfield(S, 'VY')
    warning('SPM structure does not specify images');
    return
  end
  VY = S.VY;
  if isfield(S, 'Sess')
    nsess = length(S.Sess);
    for s = 1:nsess
      row{s} = S.Sess{s}.row;
    end
    RT = S.xX.RT;
    have_fdata = 1;
  else % PET I guess
    if ~isfield(S.xX, 'I') | ~isfield(S.xX, 'sF')
      error('Expecting I and sF fields in SPM design');
    end
    scol = S.xX.I(:, find(strcmp('subject', S.xX.sF)));
    subjnos = unique(scol);
    nsess = length(subjnos);
    for s = 1:nsess
      row{s} = find(scol == subjnos(s));
    end
    have_fdata = 0;
  end
else
  have_fdata = 0;
end

if filtf & ~have_fdata % filter, none specified, thus need to know about TR
	   
    % get Repeat time
    %---------------------------------------------------------------
    RT  = spm_input('Interscan interval {secs}','+1','batch',{},'RT');

end

if isempty(VY)  % need to know about images
  % no of sessions / subjects
  nsess = spm_input(sprintf('No of %ss', sess_str), '+1', 'r', 1, 1); 
  % select files for each session
  for s = 1:nsess
    simgs = spm_get(Inf, 'img', sprintf('Data images %s %d', sess_str, s));
    row{s} = (1:size(simgs, 1))'+size(VY,1);
    VY = strvcat(VY, simgs);
  end 
end  % of image get routines
if isempty(VY), return, end

% global scaling options
askGMf = 1;
if spmf
  gopts =  {''};
  glabs = ['SPM design|' sess_str ' specific scaling',...
	       '|Proportional scaling|Raw data'];
  tmp = spm_input('Scaling from:', '+1', 'm', glabs, 1:4, 1);
  if tmp == 1
    Global = [];
    askGMf = 0;
  else
    % force remap to wipe out previous SPM scaling
    VY = strvcat(VY(:).fname);
    if tmp == 2
      Global = 'None';
    elseif tmp == 3
      Global = 'Scale';
    elseif tmp == 4  
      Global = [];
    end
  end

else % scaling by hand
  glabs = [sess_str ' specific scaling',...
	   '|Proportional scaling|Raw data'];
  tmp = spm_input('Scaling from:', '+1', 'm', glabs, [1 2 3], 1);
  if tmp == 1
    Global = 'None';
  elseif tmp == 2
    Global = 'Scale';
  else
    Global = [];
  end
end

% Grand mean scaling
GM = 0;
if askGMf
  GM = spm_input('Scale grand mean to (0=raw)','+1','r',dGM,1);
end

% filter options
if spmf & filtf
  if spm_input('Use SPM design filter', '+1','b',...
	       ['Yes|No'], [1 0],1);
    K = S.xX.K;
  end
end

if filtf & isempty(K)  % need hand specified filter
  if spmf, filt_inp = S.Sess;else filt_inp = row;end
  K = mars_get_filter(RT, filt_inp);
  
  % Set filter
  fprintf('%-40s: %30s','Calculating filter',' ')                     %-#
  K       = spm_filter('set',K);
  fprintf('%s%30s\n',sprintf('\b')*ones(1,30),'...done')               %-#
  
end % of hand specified filter option

% map files now, if not yet mapped
if ischar(VY)
  fprintf('\n%-40s: %30s','Mapping files',' ')                     %-#
  VY = spm_vol(VY);
  fprintf('%s%30s\n',sprintf('\b')*ones(1,30),'...done')         %-#
end

% Apply scaling options if necessary
if ~isempty(Global)  
  
%-Compute Global variate
%-----------------------------------------------------------------------
q      = length(VY);
g      = zeros(q,1);
fprintf('%-40s: %30s','Calculating globals',' ')                     %-#
for i  = 1:q
	fprintf('%s%30s',sprintf('\b')*ones(1,30),sprintf('%4d/%-4d',i,q)) %-#
	g(i) = spm_global(VY(i));
end
fprintf('%s%30s\n',sprintf('\b')*ones(1,30),'...done')               %-#

% get null GM scaling
if (GM == 0)
  GM = mean(g);
end

% scale if specified (otherwise subject / session specific grand mean scaling)
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

end

% Now get data
marsY = mars_roidata(roilist, VY, mars_opts.statistics.sumfunc, 'v');
Y = marsY.Y;

% Filter
if filtf
  Y = spm_filter('apply', K, Y);
end

% Save to file
save Y Y

% And leave
fprintf('Data extracted and saved to variable Y in Y.mat\n');

 
% $$$ % save to file
% $$$ [f p] = uiputfile('*.txt', 'File name for extracted data');
% $$$ if any(f~=0)
% $$$   fname = fullfile(p, f);
% $$$   try
% $$$     save(fname, 'Y', '-ascii');
% $$$   catch
% $$$     warning([lasterr ' Error saving data to file ' fname])
% $$$   end
% $$$ end

  