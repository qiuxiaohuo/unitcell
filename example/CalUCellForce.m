function [f,f_f,f_m] = CalUCellForce(info,physTag2Name,V_coord,ELEM_VE,Lf,Lm,eigE0)
%CalStiffnessMatrix Calculate unconstraint gloabal stiffness matrix

  % function info
  elemType = 'C3D4';
  [~,dN]   = elempara(elemType);

  % preallocate f_f and f_m
  f   = zeros(info.nDof,1);
  f_f = zeros(info.nDof,1);
  f_m = zeros(info.nDof,1);
  
  % loop of element
  for ielem = 1:info.nElem
    elemcnc = ELEM_VE.EToV(ielem,:);   % element conectivity matrix
    elemTag = ELEM_VE.physTag(ielem);  % element physical tag
    coord   = V_coord(elemcnc,:);      % nodal coordinate of element
    
    % cal B matrix and corresponding integral weights
    [B_ip,detJ_ip] = CalBMatrix(dN,coord,elemType);
    w  = 1/6; % weight for Tetrahedral elements with one integral point

    % switch phystag to choose material matrix
    switch physTag2Name(elemTag)
      case 'fiber'
        fe = w.*detJ_ip.*B_ip'*Lf*eigE0;
        f_f(DofID3(elemcnc)) = f_f(DofID3(elemcnc)) + fe;
      case 'matrix'
        fe = w.*detJ_ip.*B_ip'*Lm*eigE0;
        f_m(DofID3(elemcnc)) = f_m(DofID3(elemcnc)) + fe;
      otherwise
        error("Could not find physTag fiber or matrix!")
    end
  end

  f = f_f + f_m;
end