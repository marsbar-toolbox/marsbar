function [e_specs, e_names] = event_specs(D)
% method to return event specifications for all event in model
% FORMAT [e_specs e_names] = event_specs(D)
%
% D          - design object
% 
% Returns
% e_specs    - event specification 2 by N matrix where row 1 is the
%              session number of the event, row 2 is the event number in
%              the session 
% 
% e_names    - names of each event 
% 
% $Id$
  
if ~is_fmri(D)
  error('Needs FMRI design');
end

SPM   = des_struct(D);
Sess  = SPM.Sess;
nsess = length(Sess);

e_specs = [];
e_names = {};
e_ctr = 1;
for ss = 1:nsess
  nevs = length(Sess{ss}.name);
  e_specs = [e_specs [ones(1, nevs) * ss; 1:nevs]];
  e_names = [e_names Sess{ss}.name];
end
  
  