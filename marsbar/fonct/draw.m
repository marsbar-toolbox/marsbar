function varargout = draw(varargin)
% draw function for ROI drawing tool
%
% $Id$
  
persistent h_poly

if  ~isempty(varargin) 
   varargout = {h_poly};
   return
end

a = round( get(gca, 'CurrentPoint') );

if isempty(h_poly)
	h_poly = plot(a(1,1),a(1,2),'r','EraseMode','none');
	drawnow
else

	xdata = get(h_poly,'XData');	ydata = get(h_poly,'YData');

	lastpoint = [ xdata(length(xdata)) ; ydata(length(xdata))];
	
	if ( a(1,1) == lastpoint(1)  & a(1,2)==lastpoint(2) )
	else
		xdata = [ xdata, a(1,1)]; ydata = [ ydata, a(1,2)];
		set (h_poly,'XData',xdata,'YData',ydata)

	end


end