function Vr = set_box_view(Volume,box_view)
% set_box_view function for ROI drawing tool
%
% $Id$
  
Vi = Volume.Vol;

s = size(Vi.dim);
if s(1)>s(2)
Vi.dim = Vi.dim';
end

M_rot = Volume.M_rot;
M_base= Volume.M_base;

%guess rot view
if M_rot == eye(4)
  numrot=1;
elseif M_rot == [0 0 1 0;1 0 0 0;0 1 0 0;0 0 0 1],
    numrot=2;
elseif M_rot == [1 0 0 0;0 0 1 0;0 1 0 0;0 0 0 1],
    numrot=3;
end
     %numrot = get(hdl.space.orient,'value');

switch lower(box_view)

  case 'box'

    Vr.mat = M_rot; 
    Vr.dim =Vi.dim(1:3);  

    Vr.box_space = mars_space ( struct('dim',Vr.dim,'mat',Vi.mat) );

    Vr.vox(1) = M_base(1,1);    Vr.vox(2) = M_base(2,2);    
    Vr.vox(3) = M_base(3,3);  

    Vr.hold = 1;

    Vr.dim = Vr.dim * M_rot(1:3,1:3);   
    Vr.vox = Vr.vox * M_rot(1:3,1:3);
    Vr.num = 1;
    Vr.numrot = numrot;

  case 'space'

    dim = Vi.dim;
    vox=[];h=1;

    % space for new image          
      [dim mat vox] = mars_new_space(dim,Vi.mat, vox);
    % get data for image
      Vr.mat = inv(Vi.mat) * mat* M_rot;

    Vr.box_space = mars_space ( struct('dim',dim,'mat', mat) );

    dim = dim*M_rot(1:3,1:3);   vox = vox*M_rot(1:3,1:3);

    Vr.dim = dim;  Vr.vox = vox;   Vr.hold = 1;

    Vr.numrot = numrot;
    Vr.num = 2;

  case 'new'
    dim = Vi.dim;
    vox=[];h=1;

    % space for new image          
      [dim mat vox] = mars_new_space(dim,Vi.mat, vox);

    a = inputdlg({'vox size 3 vector'},'bloups',1,{num2str(vox)});

    if ~isempty(a),
      vox = str2num(a{1});
      [dim mat vox] = mars_new_space(dim,Vi.mat, vox);
    end

    Vr.mat = inv(Vi.mat) * mat* M_rot;

    Vr.box_space = mars_space ( struct('dim',dim,'mat', mat) );

    dim = dim*M_rot(1:3,1:3);   vox = vox*M_rot(1:3,1:3);

    Vr.dim = dim;  Vr.vox = vox;   Vr.hold = 1;

    Vr.numrot = numrot;
    Vr.num = 2;

end