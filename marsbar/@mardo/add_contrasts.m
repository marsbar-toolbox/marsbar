function [D,Ic] = add_contrasts(D, varargin)
% method to add contrast definitions to design
% FORMAT [D Ic] = add_contrasts(D, stat_struct)
% where stat_struct has fields 
%      'names',       string, or cell array of strings
%      'types',       string ('T' or 'F'), or cell array
%      'set_actions', string ('c', 'X0' or 'iX0') or array
%                     (see spm_FcUtil)
%                     (field is optional, defaults to 'c')
%      'values',      matrix of values 
%
% OR
% [D Ic] = add_contrasts(D, names, types, values)
% OR
% [D Ic] = add_contrasts(D, names, types, set_actions, values)
%
% Returns
% D      - possibly modified SPM design 
% Ic     - indices of specified contrasts
% 
% Contrast will not be added if it is already present, but the correct
% index will be returned in Ic
% 
% $Id$
  
if nargin < 2
  error('Need contrasts to add');
end

% default set_action
set_actions = 'c';

if nargin < 3 % structure form of call
  if ~isstruct(varargin{1})
    error('If only one argument, must be a structure');
  end
  con_struct = varargin{1};
else % cell array form of call
  if nargin < 4
    error('Need at least names, statistic types and values');
  end
  names = varargin{1};
  types = varargin{2};
  if nargin < 5 % values call
    values = varargin{3};
  else % contrast types, values call
    set_actions = varargin{3};
    values = varargin{4};
  end
  con_struct = struct(...
      'names', names,...
      'types', types,...
      'values', values);
end

% set the set action, if not set already
if ~isfield(con_struct, 'set_actions') 
  [con_struct.set_actions] = deal(set_actions);
end

SPM = des_struct(D);
sX = SPM.xX.xKXs;
n_e = size(sX.X, 2);
xCon = SPM.xCon;

xC_e = length(xCon);
Ic = [];
for c = 1:length(con_struct)
  con = con_struct(c);
  if size(con.values, 2) == n_e
    con.values = con.values';
  end
  contrast = spm_FcUtil('Set',...
			con.names,...
			con.types,...
			con.set_actions,...
			con.values,...
			sX);
  if isempty(xCon)
    xCon = contrast; 
    xC_e = 1;
  else
    iFc2 = spm_FcUtil('In', contrast, sX, xCon);
    if ~iFc2, 
      xC_e = xC_e + 1;
      xCon(xC_e) = contrast;
      Ic(c) = xC_e;
    else 
      fprintf('\ncontrast %s (type %s) already in design', ...
	      con.names, con.types);
      Ic(c) = iFc2;
    end
  end
end
SPM.xCon = xCon;
D = des_struct(D, SPM);

