function hdlFig = panel(nbx,nby,V,C,Volume,Tpos,Ser_disp,name)
% do panel for ROI drawing tool
%
% $Id$
  
keyboard
     NbCoupe = Volume.dim(3)
NbLigne

sc = get(0,'ScreenSize');
sw = sc(3);sh = sc(4);
mmm = fix((sh-100)/nby);
left = sw - (mmm*3+10);

%oldFigNumber=watchon;
figNum =figure( ...
        'Name',name, ...
        'Units','Pixel', ...
        'Position',[left 40 mmm*nbx mmm*nby], ...%   [left bottom width height]
        'NumberTitle','off');

colordef(figNum,'black');
colormap(C);
    
hdlFig = figNum;


length_x = 1/nbx;
length_y = 1/nby;

for i= 1:nbx*nby 

	left = rem(i-1,nbx)*length_x;
	bottom = 1-(fix((i-1)/nbx)+1)*length_y;

	hdl.axes(i) = axes('Position',[left bottom length_x length_y],'visible','off');

	%if (i>2) & (i-2<(NbCoupe+1))
	%	c=i-2;
	if (i<=NbCoupe)
		c=i;
		hdl.Im(c) = imagesc(V(:,:,c),'parent',hdl.axes(i),'EraseMode','none');
		hdl.Tpos{c} =  affiche_tpos(Tpos,c,Volume(hdl.Num).Vol,...
					   Volume(hdl.Num).M_rot,0,Ser_disp);

		set(hdl.Tpos{c},'markersize',5,'marker','.')
		set(hdl.axes(i),'visible','off');
	end

end


return

hdl.plot(1) = plot(0,0,'xr','MarkerSize',5,'eraseMode','none','parent',hdl.axe1);
hdl.plot(2) = plot(0,0,'xr','MarkerSize',5,'eraseMode','none','parent',hdl.axe2);
hdl.plot(3) = plot(0,0,'xr','MarkerSize',5,'eraseMode','none','parent',hdl.axe3);
hdl.plot(4) = plot(0,0,'xr','MarkerSize',5,'eraseMode','none','parent',hdl.axe4);

%hdl.plot(4) = plot('parent',hdl.axe4,'marker','x','color',[1 0 0]);

%   [left bottom width height]


 %====================================
 % The PLUS  Moins buttons
    uicontrol( ...
        'Style','pushbutton', ...
        'Units','normalized', ...
        'Position',[0.85 0.93 0.05 0.05], ...
        'String','+', ...
        'Interruptible','on', ...
        'Callback','plotPos(''Plus'');');

    uicontrol( ...
        'Style','pushbutton', ...
        'Units','normalized', ...
        'Position',[0.91 0.93 0.05 0.05], ...
        'String','-', ...
        'Callback','plotPos(''Moins'')');
     
     smax= size(S,4);
     lim = strcat('1:',num2str(smax))
    hdl.NbPos = uicontrol( ...
        'Style','edit', ...
        'Units','normalized', ...
        'Position',[0.9 0.85 0.09 0.035], ...
        'BackgroundColor',[1 1 1],...
        'String',lim,...
        'CallBack','plotPos(''verif'')');
     
    hdl.Serie = uicontrol( ...
        'Style','edit', ...
        'Units','normalized', ...
        'Position',[0.94 0.80 0.05 0.035], ...
        'BackgroundColor',[1 1 1],...
        'String','4');
     
    hdl.pause = uicontrol( ...
        'Style','edit', ...
        'Units','normalized', ...
        'Position',[0.94 0.75 0.05 0.035], ...
        'BackgroundColor',[1 1 1],...
        'String','0.2');
     
    hdl.start = uicontrol( ...
        'Style','pushbutton', ...
        'Units','normalized', ...
        'Position',[0.94 0.70 0.05 0.035], ...
        'BackgroundColor',[1 1 1],...
        'String','start',...
        'CallBack','plotPos(''start'')');
     
    hdl.stop = uicontrol( ...
        'Style','pushbutton', ...
        'Units','normalized', ...
        'Position',[0.94 0.65 0.05 0.035], ...
        'BackgroundColor',[1 1 1],...
        'String','stop',...
        'CallBack','set(gca,''UserData'',0)');
    
    %====================================
    % The CLOSE button
    
    uicontrol( ...
        'Style','push', ...
        'Units','normalized', ...
        'position',[0.92 0 0.08 0.08], ...
        'string','Close', ...
        'call','close(gcbf)');
     
     
     
    %====================================
    %====================================
    %initialisation image
    
   %load anat
   hdl.Im(1) = imagesc(A(:,:,4),'parent',hdl.axe1,'EraseMode','none');
   hdl.Im(2) = imagesc(A(:,:,5),'parent',hdl.axe2,'EraseMode','none');
   hdl.Im(3) = imagesc(A(:,:,6),'parent',hdl.axe3,'EraseMode','none');
   hdl.Im(4) = imagesc(A(:,:,7),'parent',hdl.axe4,'EraseMode','none');
         

    set(figNum,'Visible','on','UserData',hdl);
     
    watchoff(oldFigNumber);
    figure(figNum);
    
    
    coupemenuh = uimenu(gcf,'label','coupe');
    uimenu(coupemenuh,'label','1','callback', 'plotPos(1);');
    uimenu(coupemenuh,'label','2','callback', 'plotPos(2);');
    uimenu(coupemenuh,'label','3','callback', 'plotPos(3);');
    uimenu(coupemenuh,'label','4','callback', 'plotPos(4);');
    uimenu(coupemenuh,'label','5','callback', 'plotPos(5);');
    uimenu(coupemenuh,'label','6','callback', 'plotPos(6);');
    uimenu(coupemenuh,'label','7','callback', 'plotPos(7);');
    uimenu(coupemenuh,'label','8','callback', 'plotPos(8);');
    uimenu(coupemenuh,'label','9','callback', 'plotPos(9);');
    uimenu(coupemenuh,'label','10','callback', 'plotPos(10);');

    menuh2 = uimenu(gcf,'label','graph');
    uimenu(menuh2,'label','zoom','callback', 'zoom');
    uimenu(menuh2,'label','pixval','callback', 'pixval');
    uimenu(menuh2,'label','axeson','callback','set(gca,''visible'',''on'')');
    uimenu(menuh2,'label','grill','callback','affichevol(''grille'')');
    uimenu(menuh2,'label','colorLim','callback','affichevol(''colorlim'')');
    
    maps = str2mat('gray','hsv','hot','pink','cool','bone','jet','copper','flag','prism');
colormenuh = uimenu(gcf,'label','colormaps');

for k = 1:size(maps,1);
   uimenu(colormenuh,'label',maps(k,:),'callback',['colormap(' maps(k,:) ');']);
end

uimenu(colormenuh,'label','rand', 'callback','colormap(rand(lengthofmap,3))');

uimenu(colormenuh,'label','brighten','callback','brighten(.25)');
uimenu(colormenuh,'label','darken','callback','brighten(-.25)');

uimenu(colormenuh,'label','inverse','callback','colormap(flipud(colormap))');
uimenu(colormenuh,'label','fliplr','callback','colormap(fliplr(colormap))');
uimenu(colormenuh,'label','permute', ...
   'callback','c = colormap; colormap(c(:,[2 3 1]))');

uimenu(colormenuh,'label','spin','callback','spinmap');

uimenu(colormenuh,'label','remember','callback','plotPos(''remember'')');

uimenu(colormenuh,'label','restore', ...
   'callback','plotPos(''restore'')');


%uimenu(colormenuh,'label','done','Callback',...
%       'delete(colormenuh);clear stackofmaps lengthofmap maps colormenuh k');

colormap(gray);