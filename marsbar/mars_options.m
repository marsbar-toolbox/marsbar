function [mars, msgstr] = mars_options(varargin)
% options utility routines
% FORMAT [mars msgstr] = mars_options(opstr, mars, cfg_fname)
%
% Input [default]
% optstr            - option string: one of
%                     'put','load','save','edit','defaults','basedefaults','fill'
%                     [load]  
% mars              - marsbar options structure [MARSBAR]
% cfg_fname         - filename for configuration file [GUI]
% 
% Output
% mars              - possible modified marsbar structure
% msgstr            - any relevant messages
%
% Matthew Brett 20/10/00,2/6/01
%
% $Id$
  
[optstr mars cfg_fname] = mars_argfill(varargin, 0, ...
				       {'load', spm('getglobal','MARSBAR'),''});
msgstr = '';

% results fields in mars options structure
resfields = {'estim', 'contrasts', 'results'};

% editable fields, and descriptions of fields, in mars options structure
optfields = {'spacebase','structural','statistics'}; 
optlabs =  {'Base space for ROIs','Default structural','Statistics'};

switch lower(optstr)
  
 % --------------------------------------------------
 case 'put'
  maroi('classdata', 'spacebase', mars_space(mars.spacebase.fname));
  maroi('classdata', 'def_hold', mars.roidefs.spm_hold);
 
 % --------------------------------------------------
 case 'load'
  if isempty(cfg_fname)
    [fn, fn2] = marsbar('cfgfile');
    if isempty(fn), fn=fn2;end
    [p f e] = fileparts(fn);
    cfg_fname = spm_get([0 1],[f e], 'Configuration file to load',p);
  end
  if ~isempty(cfg_fname)
    tmp = load(cfg_fname);
    if ~isempty(tmp)
      if isfield(tmp, 'mars')
	mars = fillafromb(tmp.mars, mars);
      end
    end
  end
 
  % --------------------------------------------------
 case 'save'
  if nargin < 3
    [fn, fn2] = marsbar('cfgfile');
    if isempty(fn), fn=fn2;end
    [f p] = uiputfile(fn, 'Configuration file to save');
    cfg_fname = fullfile(p, f);
  end
  if ~isempty(cfg_fname)
    % don't save the default contrasts etc
    [mars mars_results] = splitstruct(mars, resfields);
    try
      save(cfg_fname, 'mars');
    catch
      warning(['Error saving config to file ' cfg_fname])
    end
    % restore the results stuff
    mars = fillafromb(mars, mars_results);    
  end
  
  % --------------------------------------------------
 case 'basedefaults'
  % hardcoded defaults

  % default structural image for display
  mars.structural.fname = fullfile(spm('Dir'), 'canonical', 'avg152T1.img');
  
  % default image specifying base space for ROIs
  mars.spacebase.fname = fullfile(spm('Dir'), 'templates', 'T1.img');
  
  % ROI defaults
  mars.roidefs.spm_hold = 1;
  
  % default summary function for ROI data
  mars.statistics.sumfunc = 'ask';
  
  % flag to indicate voxel data should be used to calculate filter
  mars.statistics.voxfilter = 0;
  
  % results stuff
  mars.estim = '';
  mars.contrasts = '';
  mars.region = [];
  
% --------------------------------------------------
 case 'edit'
  
  % Edit defaults.  See 'basedefaults' option for other defaults
  defarea = cfg_fname;  % third arg is defaults area, if specified
  if isempty(defarea)
    % get defaults area
    [Finter,Fgraph,CmdLine] = spm('FnUIsetup','MarsBar Defaults');
    % fields, and descriptions of fields, in mars options structure
    optfields = {'spacebase','roidefs', 'structural','statistics'};
    optlabs =  {'Base space for ROIs',...
		'Defaults for ROIs', 'Default structural',...
		'Statistics'};
    defarea = char(...
      spm_input('Defaults area', '+1', 'm',{optlabs{:} 'Quit'},...
		{optfields{:} 'quit'},length(optfields)+1));
  end
  
  oldmars = mars;
  switch defarea
   case 'quit'
    return
   
    % display stuff - default structural scan
   case 'structural'
    mars.structural.fname = spm_get(1, 'img', 'Default structural image', ...
			       fileparts(mars.structural.fname));

    % default ROI base space
   case 'roidefs'
    mars.roidefs.spm_hold = ...
	spm_input('ROI interpolation method?','+1','m',...
		  ['Nearest neighbour' ...
		  '|Trilinear Interpolation'...
		  '|Sinc Interpolation'],...
			     [0 1 -9],2,'batch',{},'reslice_method');
    
   % default ROI base space
   case 'spacebase'
    mars.spacebase.fname = spm_get(1, 'img', 'Default ROI image space', ...
			       fileparts(mars.spacebase.fname));
    
   % statistics 
   case 'statistics'
    mars = getdefs(mars,oldmars,...
			'statistics.sumfunc',...
			'Data summary function',...
			{'mean','wtmean','median','eigen1','ask'},...
			['Mean|Weighted mean|Median|1st eigenvector|Always ask']);
	   
    % - not currently used
% $$$     mars.statistics.voxfilt = spm_input('Accept these settings', '+1', ...
% $$$ 					 'b','Yes|No',[0 1], ...
% $$$ 					 mars.statistics.voxfilt);
     
   otherwise 
    error('Unknown defaults area')
  end

  % Offer a rollback
  if spm_input('Accept these settings', '+1', 'b','Yes|No',[0 1],1)
    mars = oldmars;
  end
  
  % --------------------------------------------------
 case 'defaults'                             %-get marsbar defaults
  pwdefs = [];
  msgstr = 'base defaults';
  cfgfile = marsbar('cfgfile');
  if ~isempty(cfgfile);
    tmp = load(cfgfile);
    if isfield(tmp, 'mars')
      pwdefs = tmp.mars;
      msgstr = cfgfile;
    else
      warning(...
	  ['File ' cfgfile ' does not contain valid config settings'],...
	  'Did not load marsbar config file');
    end
  end
  mars = fillafromb(pwdefs, mars_options('basedefaults'));
  
   % --------------------------------------------------
 case 'fill'                             %-fill from template
  mars = fillafromb(mars,cfg_fname);
  
 otherwise
  error('Don''t recognize options action string')
end
return


function s = getdefs(s, defval, fieldn, prompt, vals, labels)
% sets field in structure given values, labels, etc
    
if isstruct(defval)
  defval = getfield(defval, fieldn);  
end

if ischar(defval)
  defind = find(strcmp(defval,vals));
else
  defind = find(defval == vals);
end

v = spm_input(prompt, '+1', 'm', labels, vals, defind);
if iscell(v) & ischar(defval)
  v = char(v);
end
  
s = setfield(s,fieldn,v);

return