
if ~isempty(Volume(NumVol).Vol)

  coupe = Volume(NumVol).coupe;
  Vi = Volume(NumVol).Vol;

  if ~isfield(Volume,'Vr'),   Volume(NumVol).Vr = []; end;
  if ~isfield(Volume,'Pos_space'),   Volume(NumVol).Pos_space = []; end;

  Vr = Volume(NumVol).Vr ;  %represented volume information
  Pos_space = Volume(NumVol).Pos_space;

if ( isempty(Vr) )

  Vr = set_box_view(Volume(NumVol),'box');
  Volume(NumVol).Vr = Vr;

  set_axis='true';
end

if ( isempty(Pos_space) )
  Volume(NumVol).Pos_space = Vr.box_space;
end

slice = spm_slice_vol(Vi, Vr.mat * spm_matrix([0 0 coupe]) ,...
			  Vr.dim(1:2), Vr.hold)';


else
  dim = size(Volume(NumVol).data);
  slice =  Volume(NumVol).data(:,:,coupe);
  Vr = Volume(NumVol).Vr;
end
