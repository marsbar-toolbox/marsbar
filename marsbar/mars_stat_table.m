function [marsS, xCon, changef] = mars_stat_table(marsDe, xCon, Ic)
% gets Mars statistics and displays to a table on the matlab console  
% FORMAT [marsS, xCon, changef] = mars_stat_table(marsDe, xCon, Ic)
%
% Inputs
% marsDe               - MarsBaR design structure
% xCon                 - contrast structure
% Ic                   - indices for contrasts to be displayed
% 
% Outputs
% marsS                - MarsBaR statistics structure
% xCon                 - contrast structure (which might have changed)
% changef              - flag to indicate if xCon has changed
%
% $Id$
  
% check arguments, allowing empty args
if nargin < 1
  marsDe = [];
end
if isempty(marsDe)
  marsDe = spm_get(1,'mres.mat',...
		   'Select MarsBaR estimated results');
end
if ischar(marsDe)
  marsDe = load(marsDe);
end
if nargin < 2
  xCon = [];
end
if isempty(xCon) & ~is_there(marsDe, 'xCon')
  xCon = spm_get(1,'x?on.mat','Select contrast file');
end
if ischar(xCon)
  load(xCon);
end
if nargin < 3
  Ic = [];
end
changef = 0;
if isempty(Ic)
  [Ic,xCon, changef] = mars_conman(marsDe.xX,xCon,'T|F',Inf,...
			 'Select contrasts ','',1);
end

% Do statistics work
[marsS] = mars_stat_struct(marsDe, xCon, Ic);

% output to text table
if isempty(marsS), return, end
% output column headings
if xCon(Ic(1)).STAT == 'T'
  numstr = 'Contrast value';
  statstr = 't statistic';
else
  numstr = 'Extra SS';
  statstr = 'F statistic';
end
str = sprintf('%-20s%20s:%15s:%15s:%15s:%15s',...
	      'Contrast name',...
	      'ROI name',...
	      numstr,...
	      statstr,...
	      'Uncorrected P',...
	      'Corrected P');
fprintf('\n%s\n%s\n',str, repmat('-',1,length(str)));

for con = 1:length(marsS.rows)
  fprintf('%s\n%s\n', ...
	  marsS.rows{con}.name,...
	  repmat('-',1,42));
  for roi = 1:length(marsS.columns)
    fprintf('%40s:%15.2f:%15.2f:%15.6f:%15.6f\n', ...
	    marsS.columns{roi},...
	    marsS.con(con,roi),...
	    marsS.stat(con,roi),...
	    marsS.P(con,roi),...
	    marsS.Pc(con,roi))
  end
end