function Strn = strain(info,V_coord,ELEM_VE,U)
%CalStrainAndStressC3D4 Calculate unconstraint gloabal stiffness matrix

  % function info
  elemType = 'C3D4';
  [~,dN] = elempara(elemType);

  % preallocate struct array of Strain and Stress
  Strn = zeros(info.nElem,6);

  for ielem = 1:info.nElem
    elemcnc = ELEM_VE.EToV(ielem,:);   % element conectivity matrix
    coord   = V_coord(elemcnc,:);      % nodal coordinate of element

    [B_ip,~] = CalBMatrix(dN, coord, elemType);

    % cal strain on elem
    strain = B_ip * U(DofID3(elemcnc));
    
    % form strain struxt
    Strn(ielem,:) = strain';
  end
end