%------------------------------------------------------------------
% SPM99 batch mfile to configure contrasts
%------------------------------------------------------------------
%
% $Id$ 

global SPM_BCH_VARS

con = SPM_BCH_VARS.contrasts;
contrasts(1).names = con.names;
contrasts(1).types = con.types;
contrasts(1).values = con.values;



