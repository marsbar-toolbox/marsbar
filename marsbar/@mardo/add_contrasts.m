function [D,Ic] = add_contrasts(D, varargin)
% method to add contrast definitions to design
% FORMAT [D Ic] = add_contrasts(D, stat_struct)
% where stat_struct has fields 
%      'names',      string, or cell array of strings
%      'stat_types', string ('T' or 'F'), or cell array
%      'value_types',string ('c', 'X0' or 'iX0') or array
%      'values',     matrix of values 
%      where 'value_types', is optional ('c' assumed)
% OR
% [D Ic] = add_contrasts(D, names, stat_types, values)
% OR
% [D Ic] = add_contrasts(D, names, stat_types, value_types, values)
%
% $Id$
  
if nargin < 2
  error('Need contrasts to add');
end
if nargin < 3 % structure form of call
  if ~isstruct(varargin{1})
    error('If only one argument, must be a structure');
  end
  con_struct = varargin{1};
  if ~isfield(con_struct, 'value_types') 
    con_struct.value_types = 'c';
  end
else % cell array form of call
  if nargin < 5
    error('Need at least names, stat types and values');
  end
  names = varargin{2};
  stat_types = varargin{3};
  if nargin < 6 % values call
    value_types = repmat({'c'},size(names));
    values = varargin{4};
  else % contrast types, values call
    value_types = varargin{4};
    values = varargin{5};
  end
  con_struct = struct(...
      'names', names,...
      'stat_types', stat_types,...
      'value_types', value_types,...
      'values', values);
end

SPM = des_struct(D);
sX = SPM.xX.xKXs;
n_e = size(sX, 2);
xCon = SPM.xCon;

xC_e = length(xCon);
Ic = [];
for c = 1:length(con_struct)
  con = con_struct(c);
  if size(con.values, 2) == n_e
    con.values == con.values';
  end
  contrast = spm_FcUtil('Set',...
			con.names,...
			con.stat_types,...
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
      fprintf('\ncontrast %s (type %s) already in xCon', ...
	      con.names, con.types);
      Ic(c) = iFc2;
    end
  end
end
SPM.xCon = xCon;
D = des_struct(D, SPM);

