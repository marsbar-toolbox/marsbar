%%*************     AFFICHAGE     *****************

    hold on

    set(hdl.space.txt_editcoupe,'string',num2str(coupe));
    get_slice

    try
      set(hdla.Im,'CData',slice);
    catch
      if ~(hdla.Im==0), fprintf('%s','handel problem; new color map ...');end

      hdla.Im = imagesc(slice); set(gca,'ydir','normal','xdir','reverse')
     hold on
     set(AxeNum,'UserData',hdla)
    end

%set the x axes dimention to get a scaled image
   if exist('set_axis')
     set(gca,'Xlim',[0 Vr.dim(1)]);   set(gca,'Ylim',[0 Vr.dim(2)])
     fov = Vr.vox.*Vr.dim;
     
     max_axes = hdl.view.max;
     pos_axe  = get(gca,'position');   

     ylength = max_axes(2);   xlength = max_axes(2) * fov(1)/fov(2);
     if xlength > max_axes(1);
       xlength = max_axes(1);    ylength = max_axes(1) * fov(2)/fov(1);
     end
     pos_axe(3) =xlength ; pos_axe(4) = ylength;

     hdla.cur_pos(3:4) = pos_axe(3:4);
     set(AxeNum,'position',pos_axe,'userdata',hdla,'visible','on');   
   end

   str = ['/' num2str(Vr.dim(3))];
   set (hdl.space.txtcoupe,'string',str);

   if ~isempty(Pos{1})
     Ser  = str2num(get(hdl.Roi.disp,'string'));

     if exist('refreshbug');  return;end
     affiche_mpos;
     nbroi = length(Pos);
     str = sprintf('%s\n/ %s','Roi ', num2str(nbroi) );
     set (hdl.Roi.txt,'string',str);
   else, nbroi=0; 
   end
     str = sprintf('%s\n/ %s','Roi ', num2str(nbroi) );
     set (hdl.Roi.txt,'string',str);
    
   if ~isempty(Tpos)
     Ser  = str2num(get(hdl.tpos_hdl.Series_disp,'string'));
     vvv = Volume(NumVol).Vr.box_space;
     affiche_tpos(Tpos,coupe,vvv,...
		 Volume(hdla.Num).M_rot,hdla.Tpos,Ser)
   end
        

    if hdla.Bw
       figure(hdla.Bw);
       hold off
       imagesc(Bw(:,:,coupe));
    end
    
    if ~isempty(Cont)
       Cont = contourc(Bw(:,:,coupe),1);  Cont(:,1)=[];
       set(hdla.Cont,'Xdata',Cont(1,:),'Ydata',Cont(2,:));
    end
    if hdla.grill(1)
       set(hdla.grill,'visible','off')
       set(hdla.grill,'visible','on')
    end
   
 
if exist('realy_refresh')

  set(hdla.Im ,'visible','off');
%	set(hdl.Pos ,'visible','off');
%	set(hdl.grill,'visible','off');
   set(hdla.Im ,'visible','on');
%	set(hdl.Pos ,'visible','on');
%	set(hdl.grill,'visible','on');
end



return
if(0)
%old version
    hold on
    set(hdl.space.txt_editcoupe,'string',num2str(coupe));
    
    set(hdl.Im,'CData',Volume(NumVol).data(:,:,coupe));
    
    if ~isempty(Pos)
       set(hdl.Pos,'Xdata',Pos(Pos(:,3)==coupe,2),'Ydata',Pos(Pos(:,3)==coupe,1),'visible','on' );
      
    end
    if ~isempty(P64)
      scale = NbLigne/DimFonc;

      set(hdl.Pos64,'Xdata',(P64(P64(:,3)==coupe,2)-0.5)*scale,'Ydata',(P64(P64(:,3)==coupe,1)-0.5)*scale);
    end
end
