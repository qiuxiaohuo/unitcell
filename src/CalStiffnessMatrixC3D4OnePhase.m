function [K] = CalStiffnessMatrixC3D4OnePhase(nDof,V,VE,L)
%CalStiffnessMatrix Calculate unconstraint gloabal stiffness matrix

  elemType = 'C3D4';
  nDim     = 3; nElem = size(VE,1);
  [~,dN]   = elempara(elemType);

  K = zeros(nDof);
  
  % loop of element
  for ielem = 1:nElem
    elemcnc = VE(ielem,:);       % element conectivity matrix
    coord   = V(elemcnc,1:nDim); % nodal coordinate of element
    
    % element stiffness matrix
    [B_ip,detJ_ip] = CalBMatrix(dN,coord,elemType);
    w  = 1/6; % weight for Tetrahedral elements with one integral point
    Ke = w.*detJ_ip.*B_ip'*L*B_ip;
    
    % assembly Ke
    K(DofID3(elemcnc), DofID3(elemcnc)) = K(DofID3(elemcnc), DofID3(elemcnc)) + Ke;

  end % end ielem
end