function ui_plot(o, p_type, rno)
% method plots ROI data to SPM graphics window
%
% Input
% o         - marsy object
% p_type    - string specifying plot type
%             one of 'basic' (to be expanded)
%             default is 'basic'
% rno       - region number (optional)
%             (ignored for basic type)
% 
% This is a placeholder waiting for someone to do a better job
% 
% $Id$ 
  
if nargin < 2
  p_type = 'basic';
end
if nargin < 3
  rno = [];
end

%-Get graphics window 
Fgraph = spm_figure('GetWin','Graphics');
spm_results_ui('Clear',Fgraph,0)

[T R] = summary_size(o);
Y = summary_data(o);
N = region_name(o);
S = sumfunc(o);

switch lower(p_type)
  case 'basic'
   for r = 1:R
     subplot(R, 1, r);
     plot(Y(:,r));
     a = axis;
     axis([0 T+1 a(3:4)]);
     ylabel(['Summary - ' S]);
     title(N{r});  
   end
   xlabel('Time points');
 otherwise
  error(['Unrecgnized plot type: ' p_type]);
end