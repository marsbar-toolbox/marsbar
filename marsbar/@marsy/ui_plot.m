function ui_plot(o)
% method plots ROI data to SPM graphics window
% 
% This is a placeholder waiting for someone to do a better job
% 
% $Id$ 
  
%-Get graphics window 
Fgraph = spm_figure('GetWin','Graphics');
spm_results_ui('Clear',Fgraph,0)

[T R] = summary_size(o);
Y = summary_data(o);
N = region_name(o);
S = sumfunc(o);
for r = 1:R
  subplot(R, 1, r);
  plot(Y(:,r));
  a = axis;
  axis([0 T+1 a(3:4)]);
  ylabel(['Summary - ' S]);
  title(N{r});  
end
xlabel('Time points');
