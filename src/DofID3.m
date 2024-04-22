function dofID = DofID3(nodeID, dimID)
%DofID mapping node and dimention index to global freedom index in 3D
  % assuming 3D problem, and node ID is indexed as 1,2,3,...
  % the vector is [u1x u1y u1z u2x u2y u2z ...]
  ndim = 3;
  switch nargin
    case 2
      dofID = nodeID*ndim - ndim + dimID;
    case 1
      lenNode = length(nodeID);
      dofID = zeros(ndim*lenNode,1);
      dofID(1:3:end)=nodeID*ndim - ndim + 1;
      dofID(2:3:end)=nodeID*ndim - ndim + 2;
      dofID(3:3:end)=nodeID*ndim - ndim + 3;
    otherwise
      error('DofID3 must have 1 or 2 input!')
  end
end