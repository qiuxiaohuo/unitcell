function [B,detJ] = CalBMatrix(dNdxi,coord,elemType)
% calculate C3D4 1 integral point B matrix at elem i
  switch elemType
    case {'C3D4'}
      % initialize
      nDim   = 3;
      nNodeE = size (coord, 1); % node of element
      B      = zeros(6, nDim*nNodeE);
      
      % cal Jacobian matrix and its deteminate
      Ji   = coord' * dNdxi;
      detJ = det(Ji);
      if detJ <= 0, error("Jacobian negative!"); end % check Jacobian sign

      % obtain derivative of shape function with Euclid coordinates
      dNdx = dNdxi/Ji;

      for iNode = 1:nNodeE
        pNpx = dNdx(iNode,1);
        pNpy = dNdx(iNode,2);
        pNpz = dNdx(iNode,3);
        
        % B matrix of one node for 3D solid element
        Bi = [pNpx    0    0;
                  0 pNpy    0;
                  0    0 pNpz;
                  0 pNpz pNpy;   
               pNpz    0 pNpx;
               pNpy pNpx    0];
        
        % B = [B1 B2 B3 B4]
        B(:,DofID3(iNode)) = Bi;
      end

    otherwise

  end
end