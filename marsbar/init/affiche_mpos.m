% affiche_mpos script for ROI drawing tool
%
% $Id$

Mark = ['or';'og';'ob';'om';...
           'xr';'xg';'xb';'xm';...
	   'vr';'vg';'vb';'vm';...
	   '^r';'^g';'^b';'^m';...
	   '<r';'<g';'<b';'<m';...
	   '>r';'>g';'>b';'>m';...
	   'hr';'hg';'hb';'hm'];
 
Pdec = [3 2 1 0 -1 -2 -3 3 2 1 0 -1 -2 -3 3 2 1 0 -1 -2 -3 3 2 1 0 -1 -2 -3 ...
	  3 2 1 0 -1 -2 -3 3 2 1 0 -1 -2 -3 3 2 1 0 -1 -2 -3 ;... 
        3 3 3 3 3 3 3 2 2 2 2 2 2 2 1 1 1 1 1 1 1 0 0 0 0 0 0 0 -1 -1 -1 ...
        -1 -1 -1 -1 -2 -2 -2 -2 -2 -2 -2 -3 -3 -3 -3 -3 -3 -3].*1/12;

maxPos = 28;


	for kk=1:maxPos
   	set(hdla.MPoshdl(kk),'Xdata',0,'Ydata',0,'visible','on' );
	end


M_rot = Volume(NumVol).M_rot;
M_rot = M_rot(1:3,1:3);

if max(Ser)>length(Pos)
  Ser = 1:length(Pos);
  set(hdl.Roi.disp,'string',['1:' num2str(length(Pos))]);
end

for kk = Ser

   pp = Pos{kk}*(M_rot);
   ind_pp = (round(pp(:,3)) == coupe);

   set(hdla.MPoshdl(kk),'Xdata',pp(ind_pp,1)-Pdec(1,kk),'Ydata',pp(ind_pp,2)-Pdec(2,kk),'visible','on' );
end





