function [s u] = get_event_ui(D)
% method to select an event 
%
% D    - design
% 
% Returns
% s    - session number
% u    - event number in session
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
