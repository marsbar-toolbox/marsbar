%*************** FONCTION ROI Pos ****************

M_rot = Volume(NumVol).M_rot;
M_rot_for_Pos = inv(M_rot(1:3,1:3));


if strcmp(action,'ROI_draw')

   if get(hdl.Roi.draw,'value')
	
	   set(gcf,'WindowButtonDownFcn','set(gcf,''WindowButtonMotionFcn'',''draw'')')
	   set(gcf,'WindowButtonUpFcn','affichevol(3,''ROI_draw_end'')')
   else
	   set(gcf,'WindowButtonUpFcn','')
	   set(gcf,'WindowButtonDownFcn','')
	   zoom;zoom;
   end
	realy_refresh = 1;

elseif strcmp(action,'ROI_draw_end'),

   set(gcf,'WindowButtonMotionFcn','');

   hdl_poly = draw(0);

 if ~isempty(hdl_poly)
   xp = get(hdl_poly,'XData'); yp = get(hdl_poly,'YData'); 

   delete(hdl_poly) ; clear draw;

   dim =  Volume(NumVol).Vr.dim;
   Bw1 = remplie(yp',xp',dim(1),dim(2));

   [x,y] = find(Bw1);
 
   k = size(pPos,1) ;
   l = length(x);
   for m=1:l
      pPos(k+m,:) = [ x(m) y(m) coupe] * M_rot_for_Pos;
   end

 else 
   realy_refresh = 1;
 end
   
elseif strcmp(action,'ChoisiPos'),

   if get(hdl.Roi.draw,'value')
	set(hdl.Roi.draw,'value',0)
	set(gcf,'WindowButtonUpFcn','');
	set(gcf,'WindowButtonDownFcn','')
	   zoom;zoom;
   end

   if strcmp( get(gcf,'WindowButtonDownFcn') , 'zoom down')
	zzz=2	;
	zoom
   end

    hold on
    k = size(pPos,1)+1;
    
    while (1==1) 
       [x,y,buton] = ginput(1);
       
       if buton==1
          l = 1; go = 1;
          while (l<k & go )
             comp = ( pPos(l,:) == [round(x) round(y) coupe]*M_rot_for_Pos );
             if ( (comp(1)==1 & comp(2)==1) & comp(3)==1)
                go = 0;
             end
             l = l+1;
          end
          if go
             pPos(k,:) = [round(x) round(y) coupe]*M_rot_for_Pos;
             k=k+1;
          end
             
       elseif buton==3
          l = 1; go = 1; 
          while (l<k & go )
             comp = ( pPos(l,:) == [round(x) round(y) coupe]*M_rot_for_Pos);
             if ( (comp(1)==1 & comp(2)==1) & comp(3)==1)
                go = 0;
             end
             l = l+1;
          end
          if go

       Pos{workin_pos} = pPos;Volume(NumVol).Pos = Pos;

	     realy_refresh = 1;
		if exist('zzz'), zoom; end
             return
          else
             realy_refresh = 1;
	     pPos(l-1,:) = [];
             k=k-1;
          end
       end;

       Pos{workin_pos} = pPos;Volume(NumVol).Pos = Pos;
     
       coupeprog
    end
    

elseif strcmp(action,'ROItomask');
%no more use for the object

  M = Volume(NumVol).M;
  DIM = Volume(NumVol).Vol.dim(1:3);

  workdir=pwd;
  cd (result_path)
  
  [Fname, Pname] = uiputfile('*', 'where');
  if Fname
    Fname = cat(2,Pname,Fname)
    
    mask =  deal(struct(...
		      'fname',	[Fname '.img'],...
		      'dim',		[DIM,spm_type('uint8')],...
		      'mat',		M,...
		      'pinfo',	[1 0 0]',...
		      'descrip',	'mask from ROI')); 
  
    mask = spm_create_image(mask);

    Bw=zeros(DIM); n = 1;
    for k=1:size(Pos{n},1)
      Bw(Pos{n}(k,1),Pos{n}(k,2),Pos{n}(k,3))=1;
    end
    
    mask = spm_write_vol(mask,Bw);
  
  end
  cd (workdir)


elseif strcmp(action,'clean_SelectPos');
	
	   set(gcf,'WindowButtonDownFcn','set(gcf,''WindowButtonMotionFcn'',''draw'')')
	   set(gcf,'WindowButtonUpFcn','affichevol(3,''clean_SelectPos_end'')')
	realy_refresh = 1;

elseif strcmp(action,'clean_SelectPos_end');

	   set(gcf,'WindowButtonUpFcn','')
	   set(gcf,'WindowButtonDownFcn','')
	   zoom;zoom;
	realy_refresh = 1;


   set(gcf,'WindowButtonMotionFcn','');

   hdl_poly = draw(0);

 if ~isempty(hdl_poly)
   xp = get(hdl_poly,'XData'); yp = get(hdl_poly,'YData'); 

   delete(hdl_poly) ; clear draw;

   dim =  Volume(NumVol).Vr.dim;
   Bw = remplie(yp',xp',dim(1),dim(2));

   [x,y] = find(Bw);

   tmp_pos = pPos*(M_rot(1:3,1:3));
 
   ind = find(tmp_pos(:,3)==coupe);
   l = length(ind);
   m=1;
   for k = 1:l
      p = ind(k);
      if Bw(tmp_pos(p,1),tmp_pos(p,2))==1
         sup(m) = ind(k);
         m = m+1;
       else
      end

   end
   if exist('sup')
     tmp_pos(sup,:) = [];
     pPos = tmp_pos*inv(M_rot(1:3,1:3));
   end
end
   
   
elseif strcmp(action,'SavePos');

  Pos_mat = Volume(NumVol).Pos_space.mat;

  s = struct('XYZ',pPos','mat',Pos_mat);
  roi_o = maroi_pointlist(s,'vox');
  marsbar('saveroi',roi_o);
  realy_refresh = 1;

elseif strcmp(action,'buildROI');

   workdir=pwd;
   cd (result_path)
   roi_o = mars_build_roi;
   cd (workdir)  

  if ~isempty(roi_o)
    box_space = Volume(NumVol).Vr.box_space;
    if isempty(Pos{1}),num_pos=0;else num_pos=length(Pos);end
    pPos =  voxpts(roi_o,box_space)';
    Pos{num_pos+1} =  pPos;
    workin_pos = length(Pos);
    set(hdl.Roi.disp,'string',['1:',num2str(workin_pos)]);
  end

  if isfield(Volume(NumVol),'Roi')
    Roi = Volume(NumVol).Roi
    Roi{end+1} = roi_o;
  else
    Volume(NumVol).Roi{1} = roi_o;
  end

elseif strcmp(action,'loadPos');

   workdir=pwd;
   cd (result_path)
   %[Fname, Pname] = uigetfile('*.mat,*.img', 'where'); Fname = cat(2,Pname,Fname);   
   roilist = spm_get([0 6],'roi.mat','Select ROI(s) to view');
   cd (workdir)  

   if ~isempty(roilist)
     rlen = size(roilist,1);
     rcell = cell(1, rlen);

     box_space = Volume(NumVol).Vr.box_space;

      if isempty(Pos{1}),num_pos=0;else num_pos=length(Pos);end
     for i = 1:rlen
       roi_o = maroi('load', deblank(roilist(i,:)));
       pPos =  voxpts(roi_o,box_space)';
       Pos{num_pos+i} =  pPos;
     end
     workin_pos = length(Pos);
     set(hdl.Roi.disp,'string',['1:',num2str(workin_pos)]);
   else 
     return;
   end

%   if ~isempty(Pos)
%      choix = questdlg('keep the existing ROI', ...
%                         'the choice', ...
%                         'yes','no','no');
%      switch choix
%	case 'yes'
%   	case 'no'
%   		Pos =  []; 
%	end
%   end
%   sp = mars_space(Volume(NumVol).Vol);
%   Pos = [Pos ; voxpts(roi_o,sp)']	;
 

elseif strcmp(action,'Change_roi_space');

  box_space = Volume(NumVol).Vr.box_space;
  Pos_space = Volume(NumVol).Pos_space;

  if ~isempty(Pos{1})
    for kk=1:length(Pos)
      pPos = Pos{kk};
      s = struct('XYZ',pPos','mat',Pos_space.mat);
      roi_o = maroi_pointlist(s,'vox');
      
      pPos =  voxpts(roi_o,box_space)';
      Pos{kk} = pPos ;
      set(hdla.MPoshdl(kk),'Xdata',0,'Ydata',0);
    end
    pPos = [];
  end

  Volume(NumVol).Pos_space = box_space;
   
elseif strcmp(action,'CleanPos');

  ind = 1:(workin_pos-1); 
  if workin_pos<length(Pos),ind = [ind ,(workin_pos+1):length(Pos)];end
  Pos = Pos(ind);

  pPos=[];
  
  if isempty(Pos); Pos={[]};end

  set(hdla.MPoshdl(workin_pos),'Xdata',0,'Ydata',0);
   realy_refresh = 1;

elseif strcmp(action,'CleanAllPos');
  pPos=[];
  Pos={[]};

  set(hdla.MPoshdl(:),'Xdata',0,'Ydata',0);

elseif strcmp(action,'visu_Pos_size'),

   hdlP = hdla.MPoshdl(workin_pos);

   tmp1 = get(hdlP,'MarkerSize');
   tmp2 = get(hdlP,'Marker');
 
   a = inputdlg({'size','type'},'bloups',1,{num2str(tmp1),tmp2});
   set(hdlP,'MarkerSize',str2num(a{1}))
   set(hdlP,'Marker',a{2})
   realy_refresh=1;

elseif strcmp(action,'visu_Pos_color'),

   hdlP = hdla.MPoshdl(workin_pos);

   uisetcolor(hdlP,'sometimes it works ...');
   realy_refresh=1;

elseif strcmp(action,'visu_Pos_legende'),

  cur_axe=gca;

  if isfield(hdl,'col_legende')
    axes(hdl.col_legende)
  else
     hdl.col_legende = axes('Units','normalized','Position',[0.85 0.1 0.05 0.5])
   end

     hold on
   for kk =1:length(hdla.MPoshdl)
     col = get(hdla.MPoshdl(kk),'color');
     size = get(hdla.MPoshdl(kk),'markersize');
     mark = get(hdla.MPoshdl(kk),'marker');

       plot(1,kk,'marker',mark,'erasemode','none','markersize',size,'color',col);
   end
     zoom
     axes(cur_axe)

end;











