function affichevol(action,varargin)
% main ROI drawing function with all callbacks from the interface
% the code is split in different files
% coupeprog (always call to update the rigth display
% graphprog  (basic graph fonction 
% setbox view  orientation info of the volume
% posprog (handle of ROI)
% initfigvol is the gui setup
% draw remplie are subfonction for drawing roi
%
% decoursprog and segprog (in construction) and other home made
% fonction are curently discarded (minimun=1 in initfigvol)
% 
% romain.valabregue@snv.jussieu.fr 
% romain valabregue le 01/10/2001 and the 12/02/2003
%
% $Id$

         
persistent  Volume 

fff = findobj('tag','affichevol');
if ~isempty(fff)
  if length(fff)==1  figure(fff);end
  hdl = get(gcf,'UserData');
  hdla = get(gca,'UserData');

  FigNum = gcf;
  AxeNum = gca;
  NumVol = hdla.Num;
end  

nnnargin = nargin;

if nargin==1 & ischar(action)

if strcmp(action,'all')
  action='all_anat'; tempo_also=1;
end

   switch action
      case 'all_anat'
	P={};
	global Exams

	Num_vol = length(Volume)+1;
	Last_num_vol = Num_vol;

	for nexa=1:length(Exams)
	  Series = Exams(nexa).Series;
          for nser = 1 : length(Series)
            P{end+1} = [Series(nser).name Series(nser).vol_list(1,:)];
	    Volume(Num_vol).nser=nser;
	    Volume(Num_vol).nr_time_vol=1;
            Volume(Num_vol).result_path= Exams(nexa).res_path;
            Volume(Num_vol).data_path= Exams(nexa).name;
	    Volume(Num_vol).Exam =Exams(nexa); 

	    Num_vol = Num_vol +1;
          end
	end
	all_anat=1;
        action='';     nnnargin=0;

      otherwise
         data_path = action; action='';  nnnargin=0;
   end

end


if nnnargin == 0 
 
     if exist('hdl'),titre = get(hdl.vol_list,'string');end
     global Data_path

     if isempty(Data_path), 
       data_path = pwd; %'/images';
     else
       data_path = Data_path;
     end

     if exist('Last_num_vol'),       Num_vol = Last_num_vol;
     else,       Num_vol = length(Volume)+1;end
  
     if ~exist('P'),
       P = spm_get([Inf],mars_veropts('get_img_ext'),{['select images']},data_path);
     end

     Vol = spm_vol(P);
     for kkk = 1:length(P)
       Volume(Num_vol).Vol = Vol{kkk};
       Volume(Num_vol).M_base = bare_head(Volume(Num_vol).Vol.fname);
       Volume(Num_vol).M_rot  = eye(4);
       Volume(Num_vol).coupe = 1 ;
       Volume(Num_vol).data=[];
       
       titre{Num_vol} = Volume(Num_vol).Vol.descrip;  
       titre{Num_vol} = addgrandfather(titre{Num_vol},P{kkk});
       
       Volume(Num_vol).titre = titre{Num_vol};
    
       if ( isempty(gcbf) | ~strcmp(get(gcbf,'tag'),'affichevol') )& (~exist('deja_fait') )
	 M_slice = spm_matrix([0 0 1]);
	 slice = (spm_slice_vol(Volume(Num_vol).Vol,...
				M_slice,Volume(Num_vol).Vol.dim(1:2),0))';
	 FigNum = initfigvol(slice,Num_vol, Volume(Num_vol).Vol.dim(3)); 
	 hdl = get(FigNum,'UserData');
	 set(gcf,'name',titre{Num_vol})
	 deja_fait=1;
       end

       Volume(Num_vol).Pos ={[]};
       Volume(Num_vol).Tpos  = [];
       Volume(Num_vol).Bw  = []; 
       Volume(Num_vol).Cont = [];
       Volume(Num_vol).stackofmaps = colormap;
       Volume(Num_vol).lengthofmap = size(Volume(Num_vol).stackofmaps,1);

       todo=1;
       if isfield(Volume(Num_vol),'result_path')
	 if ~isempty( Volume(Num_vol).result_path),todo=0;end
       end
       if todo
%	 global Result_path ;
%	 if isempty(Result_path),  Volume(Num_vol).result_path=pwd;  else
%	   Volume(Num_vol).result_path=[Result_path ];     end
%
%	   Volume(Num_vol).data_path = data_path;

         Exam = guess_Exam(P{kkk});  
         Volume(Num_vol).result_path= Exam(1).res_path;
         Volume(Num_vol).data_path= Exam(1).name;
	 Volume(Num_vol).Exam =Exam; 

       end


       Num_vol=Num_vol+1;

  end
  Num_vol=Num_vol-1;

 set(hdl.vol_list,'string',titre)
end
          
if nnnargin == 3
  
     if exist('hdl'),titre = get(hdl.vol_list,'string');end

  if isempty(Num_vol), Num_vol = 1; else,  Num_vol = Num_vol+1;  end

    Volume(Num_vol).data  = varargin{1};
    titre{Num_vol} = strcat(varargin{2});
    Volume(Num_vol).titre = titre{Num_vol};

    set(hdl.vol_list,'string',titre)
   
   %  initfigvol(varargin{1},action); 

  Volume(Num_vol).coupe = 1 ;
  Volume(Num_vol).Pos ={[]};
  Volume(Num_vol).Tpos  = [];
  Volume(Num_vol).Bw  = []; 
  Volume(Num_vol).Cont = [];
  Volume(Num_vol).stackofmaps = colormap;
  Volume(Num_vol).lengthofmap = size(Volume(Num_vol).stackofmaps,1);

     global Data_path Result_path ;
     if isempty(Result_path),  Volume(Num_vol).result_path=pwd;  else
       Volume(Num_vol).result_path=Result_path;     end
     if isempty(Data_path),  Volume(Num_vol).data_path = '/images'; else
       Volume(Num_vol).data_path = Data_path;     end


end


%change the volume to view from the list
if nnnargin == 1
  hdla.Num = action;NumVol=action;
  set(AxeNum,'UserData',hdla);
  action=0;
  set_axis = 'true';

  Vr = Volume(hdla.Num).Vr;
  if isempty(Vr)
    set(hdl.space.orient,'value',1);
    set(hdl.space.space,'value',1);
  else
    set(hdl.space.orient,'value',Vr.numrot);
    set(hdl.space.space,'value',Vr.num);
  end
end

  
if nnnargin == 3 | nnnargin == 0,
Pos ={[]};coupe =1; Tpos=[]; Cont=[];
hdla = get(gca,'UserData');  NumVol = hdla.Num; AxeNum = gca;
coupeprog

if exist('all_anat')
    affichevol(11,'hide_Tpos')
    affichevol(1,'multiV4')
      for nb = 1:length(Volume)
        if nb<=4 ,axes(hdl.axe(nb));end;
        affichevol(nb);
      end
if exist('tempo_also')
      affichevol(5,'init');
end

end
 
elseif  nnnargin == 2 | nnnargin == 1,
   
   if NumVol 
     Exam = Volume(NumVol).Exam ;

     Pos     = Volume(NumVol).Pos;
     Tpos    = Volume(NumVol).Tpos;
     Bw      = Volume(NumVol).Bw;
     Cont    = Volume(NumVol).Cont;

     result_path = Volume(NumVol).result_path;
     data_path = Volume(NumVol).data_path;
     
     coupe   = Volume(NumVol).coupe;
   end

   TypeAction = action;
   if nnnargin>1,   action = varargin{1}; end
   
   switch TypeAction
     case 1
       byby=0;
       graphprog   
       if NumVol, Volume(NumVol).coupe = coupe; end
       if  byby
         return
       end
       
     case 11
       set_gui

     case 2      
       segprog
       Volume(NumVol).Bw  = Bw;
       
     case 3
       workin_pos = str2num(get(hdl.Roi.disp ,'string'));
       if isempty(workin_pos)
	 workin_pos = 1;   set(hdl.Roi.disp ,'string', ['1'])
       end
       workin_pos = max(workin_pos);

       pPos = Pos{workin_pos};

       posprog

       if ~isempty(pPos), Pos{workin_pos} = pPos; end
       Volume(NumVol).Pos = Pos;

       
     case 4             	
       if isfield(Volume(NumVol),'Tpos_hdr'), Tpos_hdr=Volume(NumVol).Tpos_hdr;end
       tposprog             
     case 5
       decoursprog
   end

if NumVol
  coupeprog   
end


if get(hdl.space.syn_coupe,'value')

  cur_axe = gca;

  for na = 1:length(hdl.axe)
    if (hdl.axe(na)~=cur_axe)
      axes(hdl.axe(na))
      hdla = get(gca,'UserData'); NumVol = hdla.Num;

      if NumVol
	Volume(NumVol).coupe = coupe;
	coupeprog
      end
    end
  end

  axes(cur_axe)

end

end        


function titre=addgrandfather(titre,p)
%get the grand father directorie from the image

GF_name='';

        for i=1:3
                a=spm_str_manip(p,'t');
                p = spm_str_manip(p,['f',num2str(length(p)-length(a)-1)]);
                GF_name = [' ' a GF_name];
        end
        a=spm_str_manip(p,'t');
        GF_name = [' ' a  GF_name];

titre = [GF_name titre ];

function Ex = guess_Exam(P)

global SOS
if isempty(SOS)
  Ex.res_path = pwd;
  Ex.name     = pwd;
else
  pth=fileparts(P);
  [data_base res_dir] = rrr_cd_up(SOS.SOS_RESULT_ROOT_PATH);
  k=1;
  while ~strcmp(pth,data_base)
    if isempty(pth), 
      Ex.res_path = fileparts(P);
      Ex.name     = fileparts(P)
      return
    end
    [pth rep{k}] = rrr_cd_up(pth);
    k=k+1;
  end

  Exmas.the_name = rep{end-3};

  if strcmp(rep{end},res_dir)
    Ex.name = fullfile(SOS.SOS_CONVERTED_ROOT_PATH,rep{end-1},...
		       rep{end-2},rep{end-3});
    Ex.res_path = fileparts(P);

  else
    Ex.name = fileparts(P);
    Ex.res_path = fullfile(SOS.SOS_RESULT_ROOT_PATH,rep{end-1},...
		       rep{end-2},rep{end-3});
end

end

     
%  [Volume(Num_vol).data,titre{Num_vol},Volume(Num_vol).M,...
%   Volume(Num_vol).origin] = readvol(data,'data');
%  Volume(Num_vol).titre = titre{Num_vol};
%  %orientation SPM
%  nx = size(Volume(Num_vol).data,1)
%  Volume(Num_vol).data(1:nx,:,:) = Volume(Num_vol).data(nx:-1:1,:,:)
%  if isempty(gcbf)
%  	FigNum = initfigvol(Volume(Num_vol).data,Num_vol); 
%	hdl = get(FigNum,'UserData');
%  end