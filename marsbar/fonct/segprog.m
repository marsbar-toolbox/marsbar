%*************** Fonctions Segmentation ***************


if strcmp(action,'Seg'),

   inter = {num2str(get(hdl.color.slide_min,'value')),num2str(get(hdl.color.slide_max,'value'))};
   answer = inputdlg({'min','max'},'seuil de segmentation',1,inter);
   smin = str2num(answer{1})
   smax = str2num(answer{2})

   if isempty(Volume(hdl.Num).data)
     Vr = Volume(hdl.Num).Vr ; 
     for cc = 1:Vr.dim(3)
       Volume(hdl.Num).coupe = cc;
       get_slice;
       Volume(hdl.Num).data(:,:,cc) = slice;
     end
   end

   Vol = Volume(hdl.Num).data(:,:,:);
   Bw = (smin<Vol) & (Vol<smax);
   
   if ~hdl.Bw
      titreBw = strcat('masque :min max : ',num2str([smin smax]));
      fff = gcf;
      hdl.Bw = figure;
      set(hdl.Bw,'Position',[576 364 421 360]);
      set(FigNum,'UserData',hdl);
      figure(fff);
  end
      
elseif strcmp(action,'LoadMask'),
    [Bw,DESCRIP,M,ORIGIN,dim] = readvol({Result_SPM},'un peu complique');
nx=dim(1);
   Bw(1:nx,:,:) = Bw(nx:-1:1,:,:);
   Bw(find(~Bw)) = NaN;

   if hdl.Bw==0
   	titreBw = strcat('masque :',num2str(size(Bw)));
   	hdl.Bw = NewFigure(titreBw);
	set(hdl.Bw,'Position',[576 364 421 360]);
      	set(FigNum,'UserData',hdl);
        figure(FigNum);         
   end
  
elseif strcmp(action,'LoadBw'),
   cd ([repDataLog,'volume',filesep,'Bw'])
      [Fname, Pname] = mars_uifile('get', '*.mat', 'where');
   cd (workdir)
   
   if Fname
      Fname = cat(2,Pname,Fname);
      Fname = cat(2,'load ',Fname);
      eval(Fname); %charge une variable Bw
      
	   if hdl.Bw==0
   		titreBw = strcat('masque :',num2str(size(Bw)));
   		hdl.Bw = NewFigure(titreBw);
		set(hdl.Bw,'Position',[576 364 421 360]);
      		set(FigNum,'UserData',hdl);
        	figure(FigNum);         
  	   end
   end
   
   
elseif strcmp(action,'Bw2Pos')
   kp = size(Pos,1)+1;
   for c = 1:NbCoupe
   	[indl indc] = find (Bw(:,:,c));
	   dimc = length(indl)
   	for k = 1:dimc
      	Pos(kp,:) = [indl(k) indc(k) c ];
      	kp = kp+1;
   	end
   end
   Volume(hdl.Num).Pos =Pos;

   
elseif strcmp(action,'Bw2Cont'),
   if ~isempty(Bw)
      if size(Bw,1)==64 & NbLigne == 256
         display('expand BW 64->256');
         
         Bw = expand64to256(Bw);
      end      
      
      if size(Bw,1)==128 & NbLigne == 256
         display('expand BW 128->256');
         
         Bw = expand128to256(Bw);
      end    
      
Cont = contourc(Bw(:,:,coupe),1);  Cont(:,1)=[];
Volume(hdl.Num).Cont = Cont;

   end
   
   
elseif strcmp(action,'Hist'),  
   Im = Volume(hdl.Num).data(:,:,coupe);   
   dim = prod(size(Im));   Im  = reshape(Im,1,dim);
   titre= strcat('histograme de  ',Volume(hdl.Num).titre,num2str(coupe));
   
   hdl.Hist = NewFigure(titre) ;
   subplot(2,1,1)
   hist(Im,200);
   
   set(FigNum,'userdata',hdl);
   
if ~isempty(Bw)
   maa =squeeze( max(max(Volume(hdl.Num).data.*Bw)))
   mii =squeeze( min(min(Volume(hdl.Num).data.*Bw)))
   mea =squeeze( mean(mean(Volume(hdl.Num).data.*Bw)))
else
   maa =squeeze( max(max(Volume(hdl.Num).data)))
   mii =squeeze( min(min(Volume(hdl.Num).data)))
   mea =squeeze( mean(mean(Volume(hdl.Num).data)))
end

   subplot(2,1,2)
   hold on
   plot(maa,'r')
   plot(mea,'g')
   plot(mii,'b')
   
 
elseif strcmp(action,'Segone'),
   answer = inputdlg({'min','max'},'seuil de segmentation',1,{'150','300'});
   smin = str2num(answer{1})
   smax = str2num(answer{2})

   CoupeVol = Volume(hdl.Num).data(:,:,coupe);
   Bw(:,:,coupe) = (smin<CoupeVol) & (Volcoupe<smax);
elseif strcmp(action,'choose'),
   if hdl.Bw
      figure(hdl.Bw);
      Bw(:,:,coupe) = bwselect(4);
   end
elseif strcmp(action,'rempli'),
   bruit = ~Bw(:,:,coupe);  
   rien  = bwselect(bruit,1,1,4);
   Bw(:,:,coupe) = ~rien;      

elseif strcmp(action,'CleanCoupeBw');
   
   a = inputdlg({'c1','c2','c3','c4','c5','c6','c7','c8','c9','c10'},'bloups',1,num2cell(['0' '0' '0' '1' '1' '1' '1' '0' '0' '0']));
   for c = 1:10
      bol = str2num(a{c});
      if(bol==0)
         Bw(:,:,c) = 0;
      end
   end

        
elseif strcmp(action,'SaveBw'),   
   cd ([repDataLog,'volume',filesep,'Bw'])
   [Fname, Pname] = mars_uifile('put', '*.mat', 'where');
   if Fname
	   Fname = cat(2,Pname,Fname)
	   Fname = cat(2,'save ',Fname,' Bw');
   	eval(Fname);
   end
   cd (workdir)


elseif strcmp(action,'CloseBw'),
    delete(hdl.Bw);  hdl.Bw=0;
    %Bw=[];on le laisse pour le contour
    set(gcf,'UserData',hdl);

   
elseif strcmp(action,'CleanCont&Bw'),
   delete(hdl.Cont);
   delete(hdl.Bw);  hdl.Bw=0;
    
   Bw=[];Cont=[];
   set(gcf,'UserData',hdl);
   Volume(hdl.Num).Cont = Cont;
   
   
end;
