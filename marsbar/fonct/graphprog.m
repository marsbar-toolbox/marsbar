%*************** Fonctions Graphique ***************
 
if strcmp(action,'Plus')
  coupe = coupe+1;
     
elseif strcmp(action,'Moins'),
  coupe = coupe-1;
        
elseif strcmp(action,'go2coupe'),
    coupe = str2num(get(hdl.space.txt_editcoupe,'string'));
   
elseif strcmp(action,'start')

    set(hdl.space.start,'visible','off','UserData',1);
    set(hdl.space.stop ,'visible','on');
    
%    set(gca, 'visible','off');
    
    tmpP = str2num(get(hdl.space.pause,'string'));

    while (get(hdl.space.start,'UserData')==1 )
      dim = Volume(NumVol).Vr.dim;       
      Volume(NumVol).coupe = Volume(NumVol).coupe +1;
      if Volume(NumVol).coupe>dim(3) ,Volume(NumVol).coupe=1;end
      coupe = Volume(NumVol).coupe;

       coupeprog   
       pause(tmpP);
    end;    
    
    set(hdl.space.start,'visible','on');
    set(hdl.space.stop ,'visible','off');

elseif strcmp(action,'start_cine')

    set(hdl.space.start,'visible','off','UserData',1);
    set(hdl.space.stop ,'visible','on');
    
    set(gca, 'visible','off');
    
    tmpP = str2num(get(hdl.space.pause,'string'));

    ser = Exam(1).Series(Volume(NumVol).nser) ;

    nr_vol = Volume(NumVol).nr_time_vol;
    set(hdl.space.txt_nbvol,'string',num2str(ser.nbvol));

    while (get(hdl.space.start,'UserData')==1 )

       nr_vol = nr_vol+1; 
       if (nr_vol> ser.nbvol), nr_vol=1; end

       P = [ser.name ser.vol_list(nr_vol,:)];
       Volume(NumVol).Vol =  spm_vol(P);

       set(hdl.space.txt_edit_nbvol,'string',num2str(nr_vol));

       coupeprog   
       pause(tmpP);
    end;    
 
   Volume(NumVol).nr_time_vol;

    set(hdl.space.start,'visible','on');
    set(hdl.space.stop ,'visible','off');

elseif strcmp(action,'time_slider')

elseif strcmp(action,'go2nbvol')

    nr_vol =  str2num(get(hdl.space.txt_edit_nbvol,'string'));

    ser = Exam(1).Series(Volume(NumVol).nser) ;

    P = [ser.name ser.vol_list(nr_vol,:)];
    Volume(NumVol).Vol =  spm_vol(P);

elseif strncmp(action,'orient',6)
  Vr = Volume(NumVol).Vr;
  Vr.mat = Vr.mat * inv(Volume(NumVol).M_rot);
  Vr.dim = Vr.dim*inv(Volume(NumVol).M_rot(1:3,1:3));   
  Vr.vox = Vr.vox*inv(Volume(NumVol).M_rot(1:3,1:3));

M_rot = Volume(NumVol).M_rot;
M_rot_for_Pos = inv(M_rot(1:3,1:3)); %bizarre 
%strange only for sagital M_rot differ from inv(M_rot)

  [x,y] = ginput(1);
  pa = [x y 0]*M_rot_for_Pos;

action  = get(hdl.space.orient,'value');
Vr.numrot = action;
  switch action

    case 1 %'orient_axial'
      Volume(NumVol).M_rot  =  eye(4);
      
    case 2 %'orient_sagittal'
      Volume(NumVol).M_rot  = [0 0 1 0;
				1 0 0 0;
				0 1 0 0;
				0 0 0 1];
    case 3 %'orient_coronal'
      Volume(NumVol).M_rot  = [1 0 0 0;
				0 0 1 0;
				0 1 0 0; 
				0 0 0 1]  ;
      
  end
  Vr.mat = Vr.mat * Volume(NumVol).M_rot;
  Vr.dim = Vr.dim * Volume(NumVol).M_rot(1:3,1:3);   
  Vr.vox = Vr.vox * Volume(NumVol).M_rot(1:3,1:3);

  M_rot = Volume(NumVol).M_rot(1:3,1:3);
  pr = pa * M_rot;
  coupe = fix(pr(3));

  Volume(NumVol).Vr=Vr;
  set_axis = 'true';
      
elseif strcmp(action,'change_space');

  num  = get(hdl.space.space,'value');
  name  = get(hdl.space.space,'string');

  Volume(NumVol).Vr = set_box_view(Volume(NumVol),name{num});

  set_axis='ouaip';

  affichevol(3,'Change_roi_space');
  refreshbug=1;


elseif strcmp(action,'print_orient_info');
  Vr = Volume(NumVol).Vr;
  Vr_mat = Vr.mat * inv(Volume(NumVol).M_rot);
  Vr_dim = Vr.dim*inv(Volume(NumVol).M_rot(1:3,1:3));   
  Vr_vox = Vr.vox*inv(Volume(NumVol).M_rot(1:3,1:3));

  fov = Vr_vox.*Vr_dim;


  fprintf('Represented Volume \n')
  fprintf('dim = [%d %d %d]   Vox = [%3.3f %3.3f %3.3f]   ',...
		   Vr_dim,Vr_vox);
  fprintf('Fov (cm) = [%3.3f %3.3f %3.3f]\n',fov/10);

  fprintf('Mat = [%3.2f  %3.2f  %3.2f  %3.2f\n       %3.2f  %3.2f  %3.2f  %3.2f\n       %3.2f  %3.2f  %3.2f  %3.2f\n       %3.2f  %3.2f  %3.2f  %3.2f\n',Vr_mat');

elseif strcmp(action,'grille');
   if hdl.grill(1) == 0
      scale = 1;
      dim = Volume(NumVol).Vr.dim;

      x = [1:scale:dim(1)]-0.5 ; x = [x;x];
      y = [1 dim(2)-1]' ;
      hold on
      hh(:,1) = plot(x,y,'g:','markersize',1);
      hh(:,2) = plot(y,x,'g:','markersize',1);
%      hdl.grill = hh; set(gcf,'UserData',hdl);
   else
      delete(hdl.grill)
      hdl.grill = 0;
%      set(gcf,'UserData',hdl);
   end
   
   %set(gca,'xtick',[1:4:256]-0.5);
   %set(gca,'ytick',[1:4:256]-0.5);
   %grid;
   
elseif strcmp(action,'colorbar');
	mycolorbar;

elseif strcmp(action,'colorlim_init');
  
       slice = get(hdla.Im,'CData');
       slice =slice(:);
       slice(isnan(slice))=[];
       if isempty(slice),  mi=0;ma=1; 
       else 
 	ma = max(slice);
 	mi = min(slice);
       end
	  if mi==ma, ma=1;mi=0; end

 	set(hdl.color.edit_min,'string',num2str(mi))
 	set(hdl.color.edit_max,'string',num2str(ma))

 	maa = ma+(ma-mi)/4;
	mii = mi-(ma-mi)/4;

	Sst = 0.01;
 	set(hdl.color.slide_max,'value',ma,'Min',mii,'Max',maa,'SliderStep',[Sst Sst*10]);
 	set(hdl.color.slide_mean,'value',(ma+mi)/2,'Min',mii,'Max',maa,'SliderStep',[Sst Sst*10]);
 	set(hdl.color.slide_min,'value',mi,'Min',mii,'Max',maa,'SliderStep',[Sst Sst*10]);


   set(AxeNum,'visible','on')
if isnumeric([mi ma])
       set(AxeNum,'clim',[mi ma])
else
	  fprintf('%s\n','hmm I thougth it was ok ...');
	  keyboard
end
   set_axis='true';

elseif strcmp(action,'slide');   

   ma = get(hdl.color.slide_max,'value'); 
   mi = get(hdl.color.slide_min,'value'); 
 	
   set(hdl.color.slide_mean,'value',(ma+mi)/2);

   set(AxeNum,'visible','on','clim',[mi ma])

elseif strcmp(action,'slide_mean');   

   ma = get(hdl.color.slide_max,'value'); 
   mi = get(hdl.color.slide_min,'value');
   me = (ma + mi)/2; 
   diff = get(hdl.color.slide_mean,'value') - me;
   mama = get(hdl.color.slide_max,'Max');
   mimi = get(hdl.color.slide_max,'Min');   
   ma = ma + diff;
   mi = mi + diff;   
   if ma > mama
   	ma = mama;
   	mi = 2*me - ma;
   end   
   if mi < mimi
   	mi = mimi;
   	ma = 2*me-mi;
   end

   set(hdl.color.slide_max,'value',ma);
   set(hdl.color.slide_min,'value',mi);
   set(AxeNum,'visible','on','clim',[mi ma])
   
elseif strcmp(action,'Autolim');   
   set(AxeNum,'clim',[10 30]); %il faut tricher un peu avec matlab mais bon c'est du d‰tail
   set(AxeNum,'CLimMode','auto');
   

elseif strcmp(action,'print')

   name = fieldnames(hdl.tpos_hdl);
   for kk=1:length(name),set(getfield(hdl.tpos_hdl,name{kk}),'visible','off');
   end
   name = fieldnames(hdl.Roi);
   for kk=1:length(name),set(getfield(hdl.Roi,name{kk}),'visible','off');
   end
   name = fieldnames(hdl.space);
   for kk=1:length(name),set(getfield(hdl.space,name{kk}),'visible','off');
   end
   name = fieldnames(hdl.color);
   for kk=1:length(name),set(getfield(hdl.color,name{kk}),'visible','off');
   end

   set(hdl.vol_list,'visible','off');
   set(hdl.view.close,'visible','off');
  
   uuu=get(gca,'unit');
   set(gca,'unit','normalized')

   [Fname, Pname] = mars_uifile('put', '*.tif', 'where'); Fname = cat(2,Pname,Fname);
   print(gcf,'-dtiff',Fname);

   set(gca,'unit',uuu)

   name = fieldnames(hdl.Roi);
   for kk=1:length(name),set(getfield(hdl.Roi,name{kk}),'visible','on');
   end
   name = fieldnames(hdl.space);
   for kk=1:length(name),set(getfield(hdl.space,name{kk}),'visible','on');
   end
	  set(hdl.space.time_slider,'visible','off')
	  set(hdl.space.txt_nbvol,'visible','off')  
	  set(hdl.space.txt_edit_nbvol,'visible','off')

   set(hdl.space.axes,'visible','off')


   name = fieldnames(hdl.color);
   for kk=1:length(name),set(getfield(hdl.color,name{kk}),'visible','on');
   end

   set(hdl.vol_list,'visible','on');
   set(hdl.view.close,'visible','on');
  
elseif strcmp(action,'fermer'),

   close(gcf);   

   hh = findobj('tag','affichevol');
   if isempty(hh)
      clear affichevol
   else
      figure(hh(1))
   end
    
   byby =1;
   return
   
elseif strcmp(action,'remember'),
   Volume(NumVol).stackofmaps = [colormap; Volume(NumVol).stackofmaps];
   
elseif strcmp(action,'restore'),
   
   stac = Volume(NumVol).stackofmaps;
   lenm = Volume(NumVol).lengthofmap;

   colormap(stac(1:lenm,:));
   
   if size(stac,1)>lenm,
      stac(1:lenm,:)=[]; 
   end
   
elseif strcmp(action,'Voyons'),
    keyboard;
    return
    
   
elseif strcmp(action,'invertY'),
   aaa = get(gca,'ydir');
   
   switch lower(aaa)
   case 'reverse'
   	set(gca,'ydir','normal')
   case 'normal'
   	set(gca,'ydir','reverse')
   end
   
   

elseif strcmp(action,'load_free_s'),

%Res_dir = spm_get(-1,'*','Select a directory',[result_path filesep '..'])

Res_dir ='/home/romain/data/acquisition/frees_mri/brain';

list_f = dir(Res_dir);
list_f(1:3) = [];
for nnn = 1:length(list_f)
   ImgName = fullfile(Res_dir,list_f(nnn).name);
   fid = fopen(ImgName,'rb','n');
   Data(:,:,nnn) = fread(fid,[256 256],'uint8');
end

  Num_vol = length(Volume)+1;
  Volume(Num_vol).data  = Data;

  [rep sub]=rrr_cd_up(Res_dir);
  titre = get(hdl.vol_list,'string');
  titre{Num_vol} =   ['freesurfer ' sub];
  Volume(Num_vol).titre = titre{Num_vol};
  set(hdl.vol_list,'string',titre)

  Volume(Num_vol).coupe = 1;
  Volume(Num_vol).Pos ={[]};
  Vr.numrot = 1 ;  Vr.num = 1;
  Vr.dim = [256 256 256];
  Vr.vox = [1 1 1];
  Volume(Num_vol).Vr = Vr;

elseif strcmp(action,'splatch'),
%very quick and badly done (just to test)

   Vr = Volume(NumVol).Vr ;

if isempty (Volume(NumVol).data)
   for cc = 1:Vr.dim(3)
       Volume(NumVol).coupe = cc;
       get_slice;
       data(:,:,cc) = slice;
   end
else
   data = Volume(NumVol).data;
end
   fff = gcf;

   [img, vol] = splatch_vol(data);


  Num_vol = length(Volume)+1;
  Volume(Num_vol).data  = vol;

  titre = get(hdl.vol_list,'string');
  titre{Num_vol} =   ['Splatch'];
  Volume(Num_vol).titre = titre{Num_vol};
  set(hdl.vol_list,'string',titre)

  Volume(Num_vol).coupe = 1;
  Volume(Num_vol).Pos ={[]};
  Vr.numrot = 1 ;  Vr.num = 1;
  Vr.dim = size(vol);
  Vr.vox = [1 1 1];
  Volume(Num_vol).Vr = Vr;

keyboard


elseif strcmp(action,'project')
%very quick and badly done (just to test) like splatch

   Vr = Volume(NumVol).Vr;
   max_c = coupe;
   img = zeros(Vr.dim(1:2));

   for coupe=42:80 %max_c;
      Volume(NumVol).coupe = coupe;
      get_slice;
      max_sli = max(max(slice));
      t = slice./max_sli;
      t(t<0.3) = 0;
      t = (t+0.00001).^6;

      img = (img.*(1-t) + t.*slice ) ;%* (1+coupe/max_c)/2 ;
      img = img+slice * (7 + coupe/max_c)/8 ;  
   end

  Num_vol = length(Volume)+1;
  Volume(Num_vol).data  = img;

  titre = get(hdl.vol_list,'string');  titre{Num_vol} =   ['proj'];
  Volume(Num_vol).titre = titre{Num_vol};  set(hdl.vol_list,'string',titre)

  Volume(Num_vol).coupe = 1;  Volume(Num_vol).Pos ={[]};
  Vr.numrot = 1 ;  Vr.num = 1;  Vr.dim = [ size(img) 1];
  Vr.vox = [1 1 1];  Volume(Num_vol).Vr = Vr;


keyboard

elseif strcmp(action,'singleV'),

   for na = 1:length(hdl.axe)
     set(hdl.axe(na),'Position',[1 1 1 1],'visible','off');
   end

   hdl.view.max=hdl.view.max_ini;
   hdl.view.mode = 1;  
   set_axis='true';
   mmm=hdl.view.max;

   set(gca,'Position',[29  80  mmm(1) mmm(2)],'visible','on');   
   set(FigNum,'userdata',hdl);


elseif strcmp(action,'multiV4'),

   mmm=hdl.view.max_ini /2;
   hdl.view.max=mmm;
   hdl.view.mode = 2;  

   for na = 1:length(hdl.axe)
     hddl = get(hdl.axe(na),'UserData');
     a_pos = hddl.cur_pos;
     set(hdl.axe(na),'Position',a_pos,'visible','on')
   end

   set(FigNum,'userdata',hdl);
   set_axis='true';

elseif strcmp(action,'check_reg'),

  lihdl = get(hdl.vol_list,'string');
  [chdl ok] = listdlg('ListString',lihdl);

  for kk=1:length(chdl)
      Vol{kk} = Volume(chdl(kk)).Vol.fname;
  end

  spm_check_registration(Vol)
  spm_orthviews('MaxBB')    


elseif strcmp(action,'diff'),

  M_rot   = Volume(NumVol).M_rot;
  dim = Volume(NumVol).Vol.dim(1:3);
  dim = dim*M_rot(1:3,1:3);

  fprintf('\nVolume %s  MOINS Volume %s \n',Volume(1).Vol.descrip,Volume(2).Vol.descrip)

  for num_slice=1:dim(3)

    M_slice = spm_matrix([0 0 num_slice]);
    mmm = M_rot*M_slice;
    
    slice1 = (spm_slice_vol(Volume(1).Vol,mmm,dim(1:2),0));
    slice2 = (spm_slice_vol(Volume(2).Vol,mmm,dim(1:2),0));
    
    diff(:,:,num_slice) = slice1-slice2;
    if(any(any(diff(:,:,num_slice)))==0)
      disp (['Volume ' num2str(2) ' :slice ' num2str(num_slice) ' equal'])
    else
      diffslice = max(max(diff(:,:,num_slice)));
      fprintf('slice %d  diff %f \n',num_slice,diffslice);
    end
  end

  affichevol(0,diff,'diff');


%plus besoin
elseif strcmp(action,'visu'),
   
  lihdl = {'Pos','P64','Tpos','Cont','Clus'};
  [chdl ok] = listdlg('ListString',lihdl);
  if ok
    switch chdl
      case 1
	hdlP = hdl.Pos;
      case 2
	hdlP = hdl.Pos64;
      case 3
	Ser_in = str2num(get(hdl.tpos_hdl.Series_in,'string'));
	hdlP = hdl.Tpos(Ser_in) ;  
      case 4
	hdlP = hdl.Cont ;   
      case 4
	hdlP = hdl.Clus ;   
    end
    
    choix = questdlg('une chose a la fois', ...
                     'the choice', ...
                     'color','size','size');
    %keyboard;
                        
    switch choix
      case 'color'
	uisetcolor(hdlP,'choose a nice color');
      case 'size'
	
	tmp1 = get(hdlP,'MarkerSize');
	tmp2 = get(hdlP,'Marker');
	
	a = inputdlg({'size','type'},'bloups',1,{num2str(tmp1),tmp2});
	
	set(hdlP,'MarkerSize',str2num(a{1}))
	set(hdlP,'Marker',a{2})
    end

  end

end;

return

%color dans une autre fenetre : c'est pas pratique

 if ~isfield(hdl,'color')
	hdl.color = fig_col(FigNum);
 	set(FigNum,'UserData',hdl);
 	
 	hdlC = get(hdl.color,'userdata')
 	
 	ma = max(max(Volume(NumVol).data(:,:,coupe)))
 	mi = min(min(Volume(NumVol).data(:,:,coupe)))
 	set(hdlC.edit_min,'string',num2str(mi))
 	set(hdlC.edit_max,'string',num2str(ma))
 	
	Sst = 0.01;
 	set(hdlC.slide_max,'value',ma,'Min',mi,'Max',ma,'SliderStep',[Sst Sst*10]);
 	set(hdlC.slide_min,'value',mi,'Min',mi,'Max',ma,'SliderStep',[Sst Sst*10]);

 end
 
 C = get(FigNum,'colormap');
 Clim = get(FigNum,'Clim');
 
 set(hdl.color,'colormap',C)
 set(get(hdl.color,'CurrentAxes'),'Clim',Clim)
 
 figure(hdl.color)
 rgbplot(C);
 colorbar;





    if coupe> dim(3)
      coupe = dim(3);
    end
%    set(hdl.txt_editcoupe,'string',num2str(Volume(NumVol).coupe));

    x = get(gca,'Xlim')
    y = get(gca,'Ylim')

    if dim(1) > x(2)
      set(gca,'Xlim',[0.5 (dim(1)+0.5)])
    end
    if dim(2) > y(2)
      set(gca,'Ylim',[0.5 (dim(2)+0.5)])
    end

    realy_refresh=1;
	
%spm_matrix([0 0 0  pi/2 0 -pi/2 -1 1 1]);


