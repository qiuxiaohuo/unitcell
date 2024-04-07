function [V,nDof] = ReadABAQUSNode(modelDim,strFile)
%ReadABAQUSNode Summary of this function goes here
%   Detailed explanation goes here
  % extract nodes info
  % add keyword '**NODE', '**ENDNODE' manually to locate nodes info
  NODE    = extractBetween(strFile,['**NODE', newline], [newline, '**ENDNODE']);
  cells_N = splitlines(NODE);

  % read nodes coordinates
  switch modelDim
    case 2
      V = zeros(length(cells_N) - 1, modelDim);
      for i = 2:length(cells_N)
        % <node ID>, <x coordinate>, <y coordinate>
        temp     = sscanf(cells_N{i},'%d, %g, %g');
        V(i-1,:) = temp(2:end);
      end
    case 3
      V = zeros(length(cells_N) - 1, modelDim);
      for i = 2:length(cells_N)
        % <node ID>, <x coordinate>, <y coordinate>, <z coordinate>
        temp     = sscanf(cells_N{i},'%d, %g, %g, %g');
        V(i-1,:) = temp(2:end);
      end
  end

  nDof = length(V)*modelDim;
  fprintf('Total num Dofs found = %g\n',nDof);
end