function [o, others] = mardo_2(params, others)
% mardo_2 - class constructor for SPM2 MarsBaR design object
% inputs [defaults]
% params  - structure,containing fields, or SPM/MarsBaR design
% others  - structure, containing other fields to define
%
% This object is called from the mardo object contructor
% with a mardo object as input.  mardo_2 checks to see
% if the contained design is an SPM2 design, returns
% the object unchanged if not.  If it is an SPM2
% design, it converts it to something passably like an
% SPM99 design, and claims ownership of the passed object
%
% $Id$
  
myclass = 'mardo_2';
defstruct = struct([]);

if nargin < 1
  params = [];
end
if nargin < 2
  others = [];
end

if isa(params, myclass)
  o = params;
  return
end

if isa(params, 'mardo')  
  % check if this is an SPM2 design, process if so
  des = des_struct(params);
  if ~isfield(des, 'SPM') % no, it's an SPM99 design
    o = params;
    return
  end
  
  % Process design
  des = des.SPM;
  
  % Transfer images, if present
  if isfield(des,'xY') 
    if isfield(des.xY, 'VY')
      des.VY = des.xY.VY;
    end
    des.xX.RT = des.xY.RT;
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
      nconds = length(S(s).U);
      S2{s} = S(s);
      S2{s}.BFstr = BFstr;
      [S2{s}.bf{1:nconds}] = deal(bf);
      S2{s}.DSstr = 'Variable SOA ';
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
  uo = des_struct(params, des);
  
  % pass other fields on to constructor
  params = others;
  
else % params not a mardo object, probably empty
  
  % make empty umbrella object
  [uo, params] = mardo([]);
  
end

% split required fields from others
[params, others] = mars_struct('fillsplit', defstruct, params);

% set the mardo object
o  = class(params, myclass, uo);

return