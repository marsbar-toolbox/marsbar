%------------------------------------------------------------------
% SPM99 batch mfile to configure contrasts
%------------------------------------------------------------------
%
% $Id: er_contrast_spm99.m,v 1.1.1.1 2004/08/14 00:07:52 matthewbrett Exp $ 

global SPM_BCH_VARS

con = SPM_BCH_VARS.contrasts;
contrasts(1).names = con.names;
contrasts(1).types = con.types;
contrasts(1).values = con.values;



