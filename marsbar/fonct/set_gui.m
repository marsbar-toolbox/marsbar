
set(gca,'color',[1 0 0])

 

if strcmp(action,'change_axis'),


elseif strcmp(action,'hide_color'),

    name = fieldnames(hdl.color);
    for kk=1:length(name),set(getfield(hdl.color,name{kk}),'visible','off');
   end

%   set(hdl.vol_list,'visible','off');
   set(hdl.vol_list,'Position', [0.85 0.55 0.9 0.03])

elseif strcmp(action,'show_color'),

    name = fieldnames(hdl.color);
    for kk=1:length(name),set(getfield(hdl.color,name{kk}),'visible','on');
   end
   set(hdl.vol_list,'visible','on');


elseif strcmp(action,'hide_tempo'),

  affichevol(11,'show_color')

  hh=findobj('label','Hide tmp')
  set(hh,'label','Show tmp','callback','affichevol(11,''show_tempo'')');

   name = fieldnames(hdl.hdl_p);
   for kk=1:length(name)
      set(getfield(hdl.hdl_p,name{kk}),'visible','off');
   end

elseif strcmp(action,'show_tempo'),

  affichevol(11,'hide_color')

  hh=findobj('label','Show tmp')
  set(hh,'label','Hide tmp','callback','affichevol(11,''hide_tempo'')');

   name = fieldnames(hdl.hdl_p);
   for kk=1:length(name)
      set(getfield(hdl.hdl_p,name{kk}),'visible','on');
   end

elseif strcmp(action,'hide_Tpos'),

   name = fieldnames(hdl.tpos_hdl);
   for kk=1:length(name)
      set(getfield(hdl.tpos_hdl,name{kk}),'visible','off');
   end

   hdl.view.max_ini = [612 612];
   hdl.view.max     =  hdl.view.max_ini/hdl.view.mode;

   dec = 50;
   for na = 1:length(hdl.axe)
     hddl = get(hdl.axe(na),'UserData');
     a_pos = hddl.cur_pos;
     if na==3 , a_pos(2) = a_pos(2) + dec; end
     if na==4 , a_pos(2) = a_pos(2) + dec; end
     hddl.cur_pos = a_pos;

     set(hdl.axe(na),'UserData',hddl)
     if hdl.view.mode==2 , set(hdl.axe(na),'Position',a_pos,'visible','on');end
   end

   set(FigNum,'userdata',hdl);
   set_axis='true';

elseif strcmp(action,'show_Tpos'),

  ss = get(hdl.tpos_hdl.corected,'visible');

  if strcmp(ss,'off')

    name = fieldnames(hdl.tpos_hdl);
    for kk=1:length(name)
      set(getfield(hdl.tpos_hdl,name{kk}),'visible','on');
    end

    hdl.view.max_ini = [612 512];
    hdl.view.max     =  hdl.view.max_ini/hdl.view.mode;

    dec = 50;
    for na = 1:length(hdl.axe)
      hddl = get(hdl.axe(na),'UserData');
    
      a_pos = hddl.cur_pos;
      if na==3 , a_pos(2) = a_pos(2) - dec; end
      if na==4 , a_pos(2) = a_pos(2) - dec; end
      hddl.cur_pos = a_pos;
      
      set(hdl.axe(na),'UserData',hddl);
      if hdl.view.mode==2 , set(hdl.axe(na),'Position',a_pos,'visible','on');end
    end

    set(FigNum,'userdata',hdl);
    set_axis='true';
  end
     

end