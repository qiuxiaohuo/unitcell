function V = elemv(type,node)
%elemv Element volume
% Input
%   type - element type defined in gmsh, page 109
%     integer
%   node - element node coordinates, row is element local node index, refer to
%   gmsh, 9.2 Node ordering
%     matrix 

switch type
  case 4 % 4-node tetrahedron.
    v1 = node(2,:) - node(1,:);
    v2 = node(3,:) - node(1,:);
    u  = node(4,:) - node(1,:);
    V  = 1/6 * dot(cross(v1,v2), u);

    % check negative volume
    if V < 0
      error('Negative volume!')
    end
  otherwise
    error('No such element type %d!', type)
end