function strs = descrip(D)
% method gets cell string description of design
%
% $Id$ 
  
SPM = des_struct(D);
strs = {'Not specified'};
if ~isfield(SPM, 'xsDes');
  return
end
strs = mars_struct('celldisp', SPM.xsDes);  