function [marsS, xCon] = mars_stat_table(marsDe, xCon, Ic, xConN)
% gets Mars statistics and displays to a table on the matlab console  
% FORMAT [marsS, xCon] = mars_stat_table(marsDe, xCon, Ic, xConN)
%
% $Id$
  
% check arguments, allowing empty args
if nargin < 1
  marsDe = [];
end
if isempty(marsDe)
  marsDe = spm_get(1,'mars_estimated.mat','Select Mars results');
end
if ischar(marsDe)
  marsDe = load(marsDe);
end
if nargin < 2
  xCon = [];
end
if isempty(xCon)
  xCon = spm_get(1,'mars_xcon.mat','Select Mars contrasts');
end
if ischar(xCon)
  xConN = xCon;
  load(xCon);
end
if nargin < 3
  Ic = [];
end
if isempty(Ic)
  [Ic,xCon] = spm_conman(marsDe.xX,xCon,'T|F',Inf,...
			 'Select contrasts ','',1);
end
if nargin < 4 
  xConN = '';
end

[marsS] = mars_stat_struct(marsDe, xCon, Ic);

% save xCon in case it has been changed
if ~isempty(xConN)
  save(xConN, 'xCon');
end

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