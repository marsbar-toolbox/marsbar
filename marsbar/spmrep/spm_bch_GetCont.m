function status = spm_bch_GetCont
% SPM batch system: Contrast structure creation - MarsBar version
% FORMAT status = spm_bch_GetCont
%_______________________________________________________________________
%
% The BCH gobal variable is used for spm_input in batch mode : 
%    BCH.bch_mat 
%    BCH.index0  = {'contrasts',index_of_Analysis};
%
% Create an mars_xcon.mat file from contrasts described in the mfile, 
% append to previous xCon if xCon already exists.
% Working directory where the xCon structure will be saved
% is specified in the top level m-file. 
%_______________________________________________________________________
% @(#)spm_bch_GetCont.m	2.5 Jean-Baptiste Poline & Stephanie Rouquette 99/10/27
%
% $Id$

%- initialise status
status.str = '';
status.err = 0;

swd = pwd;

% results and contrast files
res_file = 'mars_estimated.mat';
con_file = 'mars_xcon.mat';

%-----------------------------------------------------------------------
if exist(fullfile('.',con_file),'file'), 
	load(con_file), 
	lxCon = length(xCon);
else, 
%	xCon = spm_FcUtil('FconFields');
        xCon = [];
	lxCon = 0;
end

%-----------------------------------------------------------------------
if exist(fullfile('.',res_file),'file'), 
	try 
	   load(fullfile('.',res_file),'xX');	
	catch 
	   str = ['cannot open ' fullfile('.',res_file) ...
                  ' file in spm_bch_GetCont ' swd];
	   warning(str);
	   status.str = str;
	   status.err = 1;
	   return;
	end
else 
	str = ['cannot find ' fullfile('.',res_file) ...
               ' file in spm_bch_GetCont ' swd];
	warning(str);
	status.str = str;
	status.err = 2;
	return;
end

%- get contrast to create from mat file (in global BCH) 
%-----------------------------------------------------------------------

names  = spm_input('batch',{},'names');
types  = spm_input('batch',{},'types');
values = spm_input('batch',{},'values');

%- check that the lengths are identical ? 
%- NO, this should be done in spm_bch_bchmat

len = [length(names) length(types) length(values)];
sX = xX.xKXs;

for n=1:min(len)
   contrast = spm_FcUtil('Set',names{n}, types{n}, 'c', values{n}', sX);
   if isempty(xCon),xCon = contrast;
   else
     iFc2 = spm_FcUtil('In', contrast, sX, xCon);
     if ~iFc2, 
       xCon(length(xCon)+1) = contrast;
     else 
       %- 
       fprintf('\ncontrast %s (type %s) already in xCon', names{n}, types{n});
     end
   end
end
try
	save(con_file,'xCon')
catch
	str = ['Can''t write ' con_file ' to the results directory: ' swd];
	warning(str);
	status.str = str;
	status.err = 3;
end

% set contrasts into marsbar results
marsbar('set_contrasts', con_file);