function [D,Ic,changef] = add_contrasts(D, C, varargin)
% method to add contrast definitions to design
% 
% The function has many different formats
% 
% FORMAT [D Ic changef] = add_contrasts(D, D2 [,Ic])
%
% where D2 is a design. If there is no third argument, all the contrasts in
% D2 will be added.  If third argument (Ic) is passed, specifies which
% contrasts in D2 to add. If Ic passed, and empty, or contains the string
% 'ui', contrasts to add are fetched using the GUI
%
% OR
% FORMAT [D Ic changef] = add_contrasts(D, xCon)
% 
% where xCon is a structure in SPM contrast format containing contrasts to
% add.  If there is no third argument, all the contrasts in xCon will be
% added.  If third argument (Ic) is passed, specifies which contrasts in xCon
% to add. If Ic passed, and empty, or contains the string 'ui', contrasts to
% add are fetched using the GUI
% 
% OR
% FORMAT [D Ic changef] = add_contrasts(D, stat_struct)
% where stat_struct has fields 
%      'names',       string, or cell array of strings
%      'types',       string ('T' or 'F'), or cell array
%      'set_actions', string ('c', 'X0' or 'iX0') or array
%                     (see spm_FcUtil)
%                     (field is optional, defaults to 'c')
%      'values',      matrix of values 
%
% OR
% FORMAT [D Ic changef] = add_contrasts(D, names, types, values)
% where names, types, values are cell arrays of values, or values
% (defined as above)
% 
% OR
% FORMAT [D Ic  changef] = add_contrasts(D, names, types, set_actions, values)
% where names, types, set_actions, values are cell arrays of values, or
% values (defined as above)
%
% Returns
% D       - possibly modified SPM design 
% Ic      - indices of specified contrasts as stored in D
% changef - 1 if D has changed during call else 0 
%   
% Contrast will not be added if it is already present, but the correct
% index will be returned in Ic
% 
% $Id$
  
if nargin < 2
  error('Need contrasts to add');
end

% Get parameters from current design
SPM  = des_struct(D);
sX   = SPM.xX.xKXs;
xCon = SPM.xCon;
v_f  = verbose(D);

% process inputs
if isa(C, 'mardo')        % design
  C = des_struct(C);
end
if isfield(C, 'xCon')     % design structure
  C = C.xCon;
end
if isfield(C, 'STAT')     % xCon structure
  % parse Ic input
  if nargin > 2 
    Ic = varargin{1};
    if isempty(Ic) | strcmp(Ic,'ui')
      D2 = set_contrasts(D, C);
      Ic = ui_get_contrasts(D2,'T&F',Inf,...
			   'Select contrasts to merge','',1);
    end
    C = C(Ic);
  end
else                      % contrast setting structure or values or cells
  if ~isstruct(C)
    C = sf_cell_to_conset(C, varargin{:});
  end
  % make xCon structure
  C = sf_conset_to_xcon(C, sX);
end

xc_len = length(xCon);
old_xc_len = xc_len;
for i=1:length(C)
  if ~xc_len, xCon = C(i); Ic(i) = 1; xc_len = 1; break, end
  % Clear any vol fields, as they will not match this design
  [C(i).Vcon C(i).Vspm] = deal([]); 
  Ic(i) = spm_FcUtil('In', C(i), sX, xCon);
  if ~Ic(i)
    xc_len = xc_len+1;
    xCon(xc_len) = C(i);
    Ic(i) = xc_len;
  elseif v_f 
    fprintf('\nContrast %s (type %s) already in xCon\n', ...
	    C(i).name, C(i).STAT);
  end
end
changef =  xc_len ~= old_xc_len;
if changef
  SPM.xCon = xCon;
  D = des_struct(D, SPM);
end
return

function C = sf_cell_to_conset(names, types, varargin)
% makes contrast setting structure from cell input
if nargin < 3
  error('Need at least names, statistic types and values');
end
C = struct(...
    'names', names,...
    'types', types);
if nargin < 4 % values call
  values = varargin{1};
  set_actions = 'c';
else % contrast types, values call
  set_actions = deal(varargin{1});
  values      = deal(varargin{2});
end
C = struct(...
    'names', names,...
    'types', types,...
    'set_actions', set_actions,...
    'values', values);
return

function C = sf_conset_to_xcon(con_set, sX)
% make xCon structure from cell or struct setting parameters
if ~isfield(con_set, 'set_actions')
  [con_set.set_actions] = deal('c');
end
n_e = size(sX.X, 2);
for c = 1:length(con_set)
  c1 = con_set(c);
  if size(c1.values, 1) ~= n_e & ... 
	size(c1.values, 2) == n_e
    c1.values = c1.values';
  end
  C(c) = spm_FcUtil('Set',...
		    c1.names,...
		    c1.types,...
		    c1.set_actions,...
		    c1.values,...
		    sX);
end
return