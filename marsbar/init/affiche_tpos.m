function [varargout] = affiche_tpos(TPos,coupe,sp,M_rot,TPoshdl,Ser)
% affiche_tpos function for ROI drawing tool
%
% $Id$
  
NbSerie = prod(size(TPos));

Pdec = [ 1 0 -1 1 0 -1  1  0 -1
         1 1  1 0 0  0 -1 -1 -1 ]*1/4;


if TPoshdl==0
   Mark = ['xr';'xg';'xm';'xb';'+b';'+g';'+m';'+r';'or'];
   hold on
   for k =1:9
      TPoshdl(k) = plot(-1,-1,Mark(k,:),'erasemode','none');
   end
   set(TPoshdl(9),'markersize',2);
   varargout(1) = { TPoshdl };
else
	for k=1:NbSerie
   	set(TPoshdl(k),'Xdata',0,'Ydata',0,'visible','on' );
	end
end

%   sp = mars_space(vol);


for k = Ser

   Pos = [ voxpts(TPos{k},sp)']	;
   M_rot = M_rot(1:3,1:3);
   pp = Pos*(M_rot);

   if ~isempty(pp)
   ind_pp = (round(pp(:,3)) == coupe);
   else
     display('no voxel at all !!')
   end

%   set(TPoshdl(k),'Xdata',pp(ind_pp,2)-Pdec(1,k),'Ydata',pp(ind_pp,1)-Pdec(2,k),'visible','on' );
   set(TPoshdl(k),'Xdata',pp(ind_pp,1)-Pdec(1,k),'Ydata',pp(ind_pp,2)-Pdec(2,k),'visible','on' );
end

return



   TcoupeSer = TPos{k};
   TcoupeSer = TcoupeSer(TcoupeSer(:,3) == coupe,:);
   
   if isempty(TcoupeSer)
  	x = []; y = [];
   else
	x = TcoupeSer(:,1);
	y =  DimFonc+1-TcoupeSer(:,2);
   end

   scale = dim/DimFonc;

   set(TPoshdl(k),'Xdata',(x-Pdec(1,k))*scale-(0.5*(scale-1)),'Ydata',(y-Pdec(2,k))*scale-(0.5*(scale-1)),'visible','on' );

%	if dim == 256;
%      set(TPoshdl(k),'Xdata',(x-Pdec(1,k))*4,'Ydata',(y-Pdec(2,k))*4,'visible','on' );
%      	end
	
%	if dim == 512;
%      set(TPoshdl(k),'Xdata',(x-Pdec(1,k))*8,'Ydata',(y-Pdec(2,k))*8,'visible','on' );
%	end
	
%	if dim == DimFonc
%   	set(TPoshdl(k),'Xdata',x-Pdec(1,k),'Ydata',y-Pdec(2,k),'visible','on' );%
%	end

%end