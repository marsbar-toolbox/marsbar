function [img, vol] = splatch_vol(V)
% splatch_vol function for ROI drawing tool
%
% $Id$
  
dim = size(V);
o = dim/2;  %origine
R = 100;
img = zeros(2*R,2*R);

rmax = sqrt(2)*dim(1)/2;
rmax = dim(1)/2;

maxvol = max(max(max(V)))

figure
h  = imagesc(img);
colormap(gray);

deltar =1;

for r=deltar:deltar:rmax
  slice =  zeros(2*R,2*R);

  for a = (-pi+pi/R): pi/R : pi
    for b = (-pi+pi/R) : pi/R : pi

      if(a*a+b*b<=pi*pi)
	phi=sqrt(a*a+b*b);
	if(phi>0)
	  x=a*sin(phi)/phi;  y=b*sin(phi)/phi;  z=cos(phi);
	else
	  x=a;y=b;z=1;
	end
	x=x*r+o(1);	y=y*r+o(2);	z=z*r+o(3);
	x = round(x); y = round(y); z = round(z); 

	if( x>0 & x<=dim(1) &  y>0 & y<=dim(2) &  z>0 & z<=dim(3) )
			
	  X = round( R*(1+a/pi) );
	  Y = round( R*(1+b/pi) );

	  g0 = img(X,Y);

	  g1 = V(x,y,z);

	  slice(X,Y) = g1;

	  t=g1/maxvol;
	  g1=(  g0*(1-t) + g1*t ) * (1 + r/rmax)/2;

	  img(X,Y) = g1;
	end
      end

    end
  end

  set(h,'CData',img);
  set(gca,'clim',[10 30]);
  set(gca,'CLimMode','auto');
drawnow
  vol(:,:,r) = slice;
end