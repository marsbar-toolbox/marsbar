function o = mardo_99(o)
% method to convert SPM2 design to SPM99 design
% 
% The conversion is crude, and only transfers those fields
% known to be of use in MarsBaR estimation
%
% $Id$
  
% Process design
params = paramfields(o);
des = params.des_struct;
  
% Transfer images, if present
if isfield(des,'xY') 
  des = mars_struct('merge', des, ...
		    mars_struct('split', des.xY, {'VY', 'RT'})); 
  des = rmfield(des, 'xY');
end

% move names 
des.xX.Xnames = des.xX.name;

% Strip unused fields
des.xX = mars_struct('strip', des.xX, {'W', 'name'});

% convert sessions (sort of)
if isfield(des, 'Sess')
  S = des.Sess;
  % get basis function stuff
  BFstr = des.xBF.name;
  bf = des.xBF.bf;
  des.xX.dt = des.xBF.dt;
  for s = 1:length(S)
    Ss = S(s);
    nconds = length(Ss.U);
    % Rows, cols
    S2{s}.row   = Ss.row;
    S2{s}.col   = Ss.col;
    % Set basis functions
    S2{s}.BFstr = BFstr;
    S2{s}.DSstr = 'Variable SOA ';
    % Other comparable stuff
    for t = 1:nconds
      S2{s}.name(t) = Ss.U(t).name;
      S2{s}.ons{t}  = Ss.U(t).ons;
      S2{s}.pst{t}  = Ss.U(t).pst;
      S2{s}.sf{t}   = Ss.U(t).u(33:end,:);
      S2{s}.ind{t}  = Ss.Fc(t).i;
      S2{s}.bf{t}   = bf;
      % Parametric modulation
      if Ss.U(t).P.h 
	S2{s}.Pname{t} = Ss.U(t).P.name;
	S2{s}.Pv{t}    = Ss.U(t).P.P; 
      else
	S2{s}.Pname{t} = '';
	S2{s}.Pv{t}    = [];
      end
    end
    % Not sensibly set stuff
    S2{s}.rep = 0;    
  end
  des.Sess = S2;
end

% Remove basis function field
des = mars_struct('strip', des, {'xBF'});

% covariance priors
if isfield(des,'xVi')
  fprintf('Removing SPM2 non-sphericity information\n');
  rmfield(des,'xVi');
end

% convert filter structure
if isfield(des.xX, 'K')
  K = des.xX.K;
  if isstruct(K)
    def_filt = struct('RT',0,...
		      'row',[],...
		      'LChoice','none',...
		      'LParam', 0,...
		      'HChoice','specify',...
		      'HParam',0);
    for k = 1:length(K)
      % split off useful fields
      K2{k} = mars_struct('splitmerge',K(k),def_filt);
    end
  elseif K == 1
    K2 = eye(size(des.xX,1));
  else
    K2 = K;
  end
  des.xX.K = K2;
end

% Default F contrast field
des.F_iX0 = struct('iX0', [des.xX.iB des.xX.iG], ...
		   'name', 'effects of interest');

% Need to identify as SPM99 design
des.SPMid = ['SPM99: Results imported from SPM2 design: ' des.SPMid];

% put into parent object
params.des_struct = des;
o = mardo_99(params);



