function [marsS, marsD, changef] = stat_table(marsD, Ic)
% gets Mars statistics and displays to a table on the matlab console  
% FORMAT [marsS, marsD, changef] = stat_table(marsD, Ic)
%
% Inputs
% marsD               - MarsBaR design structure
% Ic                   - indices for contrasts to be displayed
% 
% Outputs
% marsS                - MarsBaR statistics structure
% marsD               - design, including contrast structure (which
%                                might have changed)  
% changef              - flag to indicate if design has changed
%
% $Id$

if nargin < 2
  Ic = [];
end

changef = 0;
if isempty(Ic)
  [Ic marsD changef] = ui_get_contrast(marsD,'T|F',Inf,...
			 'Select contrasts ','',1);
end

% Do statistics work
[marsS] = compute_contrast(marsD, Ic);

% output to text table
if isempty(marsS), return, end
% output column headings
if marsS.rows{1}.stat == 'T'
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