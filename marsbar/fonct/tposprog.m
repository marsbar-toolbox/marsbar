%*************** FONCTION Tpos ****************

if strcmp(action,'loadRes'),

affichevol(11,'show_Tpos');

%   Res_dir = spm_get(-1,'*','Select a directory',[result_path filesep '..']);
   Res_dir = result_path;

  if exist(fullfile(Res_dir,'xCon.mat'))

    [result_path, res_name,value] = rrr_cd_up(Res_dir);
     Volume(NumVol).result_path = result_path;

   dc = struct2cell(dir(result_path));dc(:,1)=[];

   load(fullfile(Res_dir,'xCon.mat'))
   load (fullfile(Res_dir,'SPM.mat'),'DIM');
   Volume(NumVol).Con_dir = Res_dir;
   str= {['(',xCon(1).STAT,') ',xCon(1).name ]};
   for k = 2:length(xCon)
   	str = {str{:},['(',xCon(k).STAT,') ',xCon(k).name ]};
   end
   set(hdl.tpos_hdl.listCon,'string',str,'value',1);

  else
   dc = struct2cell(dir(Res_dir));dc(:,1)=[];
   if (size(dc,2)==1),  value=1;
   else,  value=2 ;end 
  end
   set(hdl.tpos_hdl.result,'string',dc(1,:),'value',value)

elseif strcmp(action,'changeRes'),

  list_name = get(hdl.tpos_hdl.result,'string');
  name_select = list_name{get(hdl.tpos_hdl.result,'value')};
  rep = fullfile(result_path,name_select);

%  else
     Volume(NumVol).result_path = rep;
     result_path = rep;
     action = 'loadRes';tposprog
%  end

elseif strcmp(action,'loadCon'),

%   Con_dir = spm_get(-1,'*','Select a result directory',[result_path filesep '..']);

   load(fullfile(Con_dir,'xCon.mat'))
   load (fullfile(Con_dir,'SPM.mat'),'DIM');

   Volume(NumVol).Con_dir = Con_dir;

	p=Con_dir;
	a1=spm_str_manip(p,'t');
	p = spm_str_manip(p,['f',num2str(length(p)-length(a1)-1)]);
	a=spm_str_manip(p,'t');


   str= {['(',xCon(1).STAT,') ',xCon(1).name, ' ', a1 '/' a ]};
   for k = 2:length(xCon)
   	str = {str{:},['(',xCon(k).STAT,') ',xCon(k).name, ' ', a1 '/' a ]};
   end
   set(hdl.tpos_hdl.listCon,'string',str,'value',1);
   
   
elseif strcmp(action,'SPM2Tpos'),

   Ser_in = str2num(get(hdl.tpos_hdl.Series_in,'string'));
   Ser_disp = str2num(get(hdl.tpos_hdl.Series_disp,'string'));
  
   Ic = get(hdl.tpos_hdl.listCon,'value');
   Con_Dir = Volume(NumVol).Con_dir;

   Im=[];   pm=[];   Ex=[];
   corrected= get(hdl.tpos_hdl.corected,'value');
   p_thres =  str2num(get(hdl.tpos_hdl.u_Seuil,'string'));
   k_thres =  str2num(get(hdl.tpos_hdl.k_Seuil,'string'));
   
   [SPM VOL Tall oSPM]= rrr_getSPM(...
          Ic,p_thres,k_thres,corrected,Im,pm,Ex,Volume(NumVol).Con_dir);


   hdr.p_thre = p_thres;
   hdr.correc =  corrected;
   hdr.k_thre = k_thres;
   hdr.name =  get(hdl.tpos_hdl.listCon,'string');hdr.name = hdr.name{Ic};
   hdr.Con_dir = Volume(NumVol).Con_dir;

   Tpos_hdr{Ser_in} = hdr;
   
   s = struct('XYZ',SPM.XYZ,'mat',oSPM.M,'vals',SPM.Z);
   roi_o = maroi_pointlist(s,'vox');
   roi_o = label(roi_o,hdr.name);

   Tpos{Ser_in} = roi_o; %[ SPM.XYZ' SPM.Z'];

   if ~hdla.Tpos
         hold on
         %vvv = Volume(NumVol).Vol;
	 vvv = Volume(NumVol).Vr.box_space;

     	 	hdla.Tpos = affiche_tpos(Tpos,coupe,vvv,...
				       Volume(NumVol).M_rot,0,Ser_disp);
      	set(AxeNum,'UserData',hdla);
   end

   Volume(NumVol).Tpos  = Tpos;
   Volume(NumVol).Tpos_hdr = Tpos_hdr;

   tposplot
 
elseif strcmp(action,'Cluster_ini'),

   Ser  = str2num(get(hdl.tpos_hdl.Series_disp,'string'));
   pp = [];

   sp=mars_space(Volume(NumVol).Vol);
   for k = Ser ;
 	pp = cat(2,pp,voxpts(Tpos{k},sp));
   end
   
   Cluster = spm_clusters(pp);

   for i = 1:max(Cluster)
   	ind_c = find(Cluster == i);
                    %I do not remenber why x et y sont inverse ...
   	Clus_Pos{i} = pp([2 1 3],ind_c)';

		%sort in decreasing T value
   	%[tt ind] = sort(-Clus_Pos{i}(:,4));
   	%Clus_Pos{i} = Clus_Pos{i}(ind,:);
   	
	Clus_size(i)  = length(ind_c);
   end

   		%sort in decreasing cluster size
   [tt ind] = sort(-Clus_size);
   Clus_Pos = Clus_Pos(ind);

     nbroi = size(Clus_Pos,2);
     str = sprintf('%s\n/ %s','Roi ', num2str(nbroi) );
     set (hdl.Roi.txt,'string',str);

   Volume(NumVol).Pos = Clus_Pos ;

   if length(Clus_Pos)<28, size =num2str(length(Clus_Pos));
     else size = '28';
   end
   set(hdl.Roi.disp ,'string', ['1:' , size])

   realy_refresh = 1;

elseif strcmp(action,'find_clus'),
rrr
	Ser  = str2num(get(hdl.tpos_hdl.Roi.disp,'string'));
	if ~isempty(Ser) & length(Ser)==1
		coupe = Clus_Pos{Ser}(1,3);
		Volume(NumVol).coupe = coupe;
	end
		

   
elseif strcmp(action,'Tpos2Pos'),
   sp = mars_space(Volume(NumVol).Vol);
   Volume(NumVol).Pos = [ voxpts(Tpos{1},sp)']	;

      
elseif strcmp(action,'SaveTpos'),
   create_rep({repDataLog},{repDataLog,'volume/','TPos/'})

   workdir=pwd;
   cd ([repDataLog,'volume',filesep,'TPos'])
   [Fname, Pname] = mars_uifile('put', '*.mat', 'where');
   if Fname
	   Fname = cat(2,Pname,Fname)
   	Fname = cat(2,'save ',Fname,' Tpos Tpos_hdr ');
   	eval(Fname);
   end
   cd (workdir)


elseif strcmp(action,'ClearTpos'),
   delete(hdla.Tpos)
   hdla.Tpos = 0;
   set(AxeNum,'UserData',hdla);

   Tpos = []
   Volume(NumVol).Tpos  = Tpos;
   
   
elseif strcmp(action,'inter_T'),


Clus_Pos={};

nbT = size(Tpos,2);
res = Tpos(1,1);
name{1} = ['T1'];
T = [];

for i = 2:nbT
	T1 = Tpos{1,i};
	for j = 1:length(res)
	   if ~isempty(res{j})
		T2 = res{j};
		nbval = size(T2,2);
		c = 1;
		for k = 1:size(T1,1)
			aa = T2(:,3)==T1(k,3) & T2(:,2)==T1(k,2) &  T2(:,1)==T1(k,1) ;
			ind(k) = any(aa);			
			if( ind(k) )
				T(c,1:nbval) = T2(find(aa),:);
				T(c,nbval+1) = T1(k,4);
				T2(find(aa),:) = [];
				c=c+1;
			end
		end	
		res{j} = T2;
		T1 = T1(~ind,:);	clear ind
	  end
		if ~isempty(T)
		res(length(res)+1) = {T};  T=[]; 
		name(length(name)+1) = {[name{j},'T',num2str(i)]};
		end

	end
	if ~isempty(T1)
	res(length(res)+1) = {T1};
	name(length(name)+1) = {['T',num2str(i)]};
	end
end

   set(hdl.tpos_hdl.nb_clust,'string',num2str(size(Clus_Pos,2)))

Clus_Pos = res ;


for k = 1:length(Clus_Pos)
   nb(k,:) = size(Clus_Pos{k});
end
   [tt ind] = sort(-nb(:,1));
   Clus_Pos = Clus_Pos(ind);
   name =  name(ind);
   nb = nb(ind,:);

   [tt ind] = sort(-nb(:,2));
   Clus_Pos = Clus_Pos(ind);
   name =  name(ind);
   nb = nb(ind,:);

   Volume(NumVol).Pos =Clus_Pos ;
   Volume(NumVol).Clus_name = name

end;

   
	
return

p_thres = logspace(-1,-5,20);
k_thres=4;

 for k=1:20
   [SPM VOL Tall ]= rrr_getSPM(Ic,p_thres(k),k_thres,corrected,Im,pm,Ex,Volume(NumVol).Con_dir);
   Cluster = spm_clusters(SPM.XYZ);
   c_pos='';c_size='';c_Z='';z_max=[];

   for i = unique(Cluster)
     ind_c = find(Cluster == i);
     ppp = SPM.XYZ(:,ind_c); pppz = SPM.Z(ind_c);
     [tt ind] = sort(-pppz);
     c_pos{i} = ppp(:,ind);
     c_size{i} = length(ind);
     c_Z{i} = pppz(ind);
     z_max(i) = pppz(ind(1));
   end
   [tt ind] = sort(-z_max);
   Clus(k).pos = c_pos(ind);
   Clus(k).size = c_size(ind);
   Clus(k).Z = c_Z(ind);
 end



%elseif strcmp(action,'LoadTpos')

   Ser = str2num(get(hdl.tpos_hdl.Series_disp,'string'));

   if ~exist([repDataLog,'volume',filesep,'TPos']), return; end;
   workdir=pwd;
   cd ([repDataLog,'volume',filesep,'TPos'])
   [Fname, Pname] = mars_uifile('get', '*.mat', 'where');
   cd (workdir)
   
   if Fname
      load(fullfile(Pname,Fname));



      Volume(NumVol).Tpos  = Tpos;
      Volume(NumVol).Tpos_hdr = Tpos_hdr;

	for i = 1:length(Tpos_hdr)
		str{i} = Tpos_hdr{i}.name;
	end

      set(hdl.tpos_hdl.listCon,'string', str);

      if ~hdla.Tpos
         hold on   
     	 	hdla.Tpos = affiche_tpos(Tpos,coupe,Volume(NumVol).Vol,...
				       Volume(NumVol).M_rot,0,Ser_disp);
     
      	set(AxeNum,'UserData',hdla);
      end      
   end
   