function [e_spec, e_name] = ui_get_event(D)
% method to select an event 
% FORMAT [e_spec, e_name] = ui_get_event(D)
% D      - design
% 
% Returns
% e_spec - 2 by 1 matrix with 
%          e_epec(1) - session number
%          e_spec(2) - event number in session
% e_name - name of event
%
% $Id$
  
if ~is_fmri(D)
  error('Need FMRI design');
end
SPM  = des_struct(D);
Sess = SPM.Sess;

% get session
%--------------------------------------------------------------
s     = length(Sess);
if  s > 1
  s   = spm_input('which session','+1','n1',1,s);
end
  
u = length(Sess(s).U);
Uname = {};
for i = 1:u
  Uname{i} = Sess(s).Fc(i).name;
end

% get effect
%--------------------------------------------------------------
str   = sprintf('which effect');
u     = spm_input(str,'+1','m',Uname);

e_spec = [s u]';
e_name = Uname{u};