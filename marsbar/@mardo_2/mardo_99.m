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
  if isfield(des.xY, 'VY')
    des.VY = des.xY.VY;
  end
  if isfield(des.xY, 'RT')
    des.xX.RT = des.xY.RT;
  end
  des = rmfield(des, 'xY');
end

% move names 
des.xX.Xnames = des.xX.name;

% convert sessions (sort of)
if isfield(des, 'Sess')
  S = des.Sess;
  % get basis function stuff
  BFstr = des.xBF.name;
  bf = des.xBF.bf;
  for s = 1:length(S)
    Ss = S(s);
    nconds = length(Ss.U);
    S2{s} = Ss;
    % Set basis functions
    S2{s}.BFstr = BFstr;
    [S2{s}.bf{1:nconds}] = deal(bf);
    S2{s}.DSstr = 'Variable SOA ';
    % Other comparable stuff
    [S2{s}.pst{1:nconds}]=deal(Ss.U(:).pst);
    [S2{s}.name{1:nconds}]=deal(Ss.Fc(:).name);
    [S2{s}.ind{1:nconds}]=deal(Ss.Fc(:).i);
    % Not sensibly set stuff
    S2{s}.rep = 1;    
  end
  des.Sess = S2;
end

% covariance priors
if isfield(des,'xVi')
  fprintf('Removing SPM2 non-sphericity information\n');
  rmfield(des,'xVi');
end

% convert filter structure
def_filt = struct('RT',0,...
		  'row',[],...
		  'LChoice','none',...
		  'LParam', 0,...
		  'HChoice','specify',...
		  'HParam',0);
if isfield(des.xX, 'K')
  K = des.xX.K;
  for k = 1:length(K)
    % split off useful fields
    K2{k} = mars_struct('splitmerge',K(k),def_filt);
  end
  des.xX.K = K2;
end

% put into parent object
params.des_struct = des;
o = mardo_99(params);



