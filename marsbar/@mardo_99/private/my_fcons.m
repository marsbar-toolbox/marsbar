function des = my_fcons(des, trialf)
% takes design, adds F contrasts
% FORMAT des = my_fcons(des, trialf)
% 
% des     - design structure
% trialf  - flag, if 1, tries to do trial specific contrasts
%
% $Id$

%-Effects designated "of interest" - constuct F-contrast structure array
%-----------------------------------------------------------------------
if length(des.xX.iC)
  F_iX0  = struct(	'iX0',		des.xX.iB,...
			'name',		'effects of interest');
else
  F_iX0  = [];
end

%-Trial-specific effects specified by Sess
%-----------------------------------------------------------------------
%-NB: With many sessions, these default F-contrasts can make xCon huge!
if trialf & isfield(des,'Sess')
  Sess = des.Sess;
  i      = length(F_iX0) + 1;
  if (Sess{1}.rep)
    for t = 1:length(Sess{1}.name)
      u     = [];
      for s = 1:length(Sess)
	u = [u Sess{s}.col(Sess{s}.ind{t})];
      end
      q             = 1:size(des.xX.X,2);
      q(u)          = [];
      F_iX0(i).iX0  = q;
      F_iX0(i).name = Sess{s}.name{t};
      i             = i + 1;
    end
  else
    for s = 1:length(Sess)
      str   = sprintf('Session %d: ',s);
	for t = 1:length(Sess{s}.name)
	  q             = 1:size(des.xX.X,2);
	  q(Sess{s}.col(Sess{s}.ind{t})) = [];
	  F_iX0(i).iX0  = q;
	  F_iX0(i).name = [str Sess{s}.name{t}];
	  i             = i + 1;
	end
      end
  end
end
des.F_iX0 = F_iX0;  
