function marsY = mars_extract_data(marsD, roi_list, modality)
% extract raw / scaled data from images via ROIs
%-----------------------------------------------------------------------
%
% The data is always extracted unfiltered
%
% Inputs
% marsD      - design matrix to (optionally) get parameters from
% roi_list   - ROIs to extract data for (names, or object array)
% modality   - optional string for modality ('pet' or 'fmri')
% 
% Returns
% marsY      - extracted data in marsY structure
%
% $Id$

marsY = [];
if nargin < 1
  marsD = [];
end
if nargin < 2
  roilist = spm_get(Inf,'roi.mat','Select ROI(s) to extract data for');
end
if nargin < 3
  modality = '';
end

if isempty(roi_list), return, end
if ischar(roi_list)
  for i = 1:size(roi_list, 1)
    o{i} = maroi('load', deblank(roi_list(i,:)));
  end
  roi_list = o;
end

% if modality not passed, try and work it out from design
if isempty(modality)
  if ~isempty(marsD)
    % some good code here
  else
    modality = 'fmri'; % The don't know default
  end
end
switch lower(modality)
 case 'pet'
  dGM   = 50;
  sess_str = 'Subject';
 case 'fmri'
  dGM =   100;
  sess_str = 'Session';
end
  
VY = [];
Global = [];  

[Finter,Fgraph,CmdLine] = spm('FnUIsetup','Extract data from ROI(s)');

% images
if isempty(marsD)
  spmf = 0
else
  spmf = spm_input('Images from:', '+1','b',['SPM design|GUI select'], ...
		   [1 0], 2);
end

% get images, from design, or by hand
if spmf
  if ~isfield(marsD, 'VY')
    warning('Design structure does not specify images');
    return
  end
  VY = marsD.VY;
  if isfield(marsD, 'Sess')
    nsess = length(marsD.Sess);
    for s = 1:nsess
      row{s} = marsD.Sess{s}.row;
    end
  else % PET I guess
    if ~isfield(marsD.xX, 'I') | ~isfield(marsD.xX, 'sF')
      error('Expecting I and sF fields in SPM design');
    end
    scol = marsD.xX.I(:, find(strcmp('subject', marsD.xX.sF)));
    subjnos = unique(scol);
    nsess = length(subjnos);
    for s = 1:nsess
      row{s} = find(scol == subjnos(s));
    end
  end
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

end % of global options

% Now get data
marsY = mars_roidata(roilist, VY, mars_opts.statistics.sumfunc, 'v');

  