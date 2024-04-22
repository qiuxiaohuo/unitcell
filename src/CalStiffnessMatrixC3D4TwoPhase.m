function [K] = CalStiffnessMatrixC3D4TwoPhase(info,physTag2Name,V_coord,ELEM_VE,Lf,Lm)
%CalStiffnessMatrix Calculate unconstraint gloabal stiffness matrix

  % function info
  elemType = 'C3D4';
  [~,dN]   = elempara(elemType);

  % preallocate K
  K = zeros(info.nDof);
  
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
        Ke = w.*detJ_ip.*B_ip'*Lf*B_ip;
      case 'matrix'
        Ke = w.*detJ_ip.*B_ip'*Lm*B_ip;
      otherwise
        error("Could not find physTag fiber or matrix!")
    end
    
    % assembly Ke
    K(DofID3(elemcnc), DofID3(elemcnc)) = K(DofID3(elemcnc), DofID3(elemcnc)) + Ke;

  end
end