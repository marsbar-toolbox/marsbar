function status = spm_bch_GetCont
% SPM batch system: Contrast structure creation - MarsBaR version
% FORMAT status = spm_bch_GetCont
%_______________________________________________________________________
%
% The BCH gobal variable is used for spm_input in batch mode : 
%    BCH.bch_mat 
%    BCH.index0  = {'contrasts',index_of_Analysis};
%
% Update results xCon from contrasts described in the mfile, 
% append to previous xCon if xCon already exists.
%_______________________________________________________________________
% @(#)spm_bch_GetCont.m	2.5 Jean-Baptiste Poline & Stephanie Rouquette 99/10/27
%
% $Id$

%- initialise status
status.str = '';
status.err = 0;

%-----------------------------------------------------------------------
marsRes = mars_armoire('get', 'est_design');
if isempty(marsRes)
  status.str = 'No current MarsBaR results loaded';
  status.err = 1;
  return
end
xCon = marsRes.xCon;
lxCon = length(marsRes.xCon);

%- get contrast to create from mat file (in global BCH) 
%-----------------------------------------------------------------------
names  = spm_input('batch',{},'names');
types  = spm_input('batch',{},'types');
values = spm_input('batch',{},'values');

%- check that the lengths are identical ? 
%- NO, this should be done in spm_bch_bchmat

len = [length(names) length(types) length(values)];
sX = marsRes.xX.xKXs;

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
if length(xCon) ~= lxCon
  % set contrasts into marsbar results
  marsRes.xCon = xCon;
  mars_armoire('update', 'est_design', marsRes);
end