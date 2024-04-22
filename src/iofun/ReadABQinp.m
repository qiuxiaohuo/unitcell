function [info,Node] = ReadABQinp(filename)
%READABQINP Summary of this function goes here
%   Detailed explanation goes here

  %% Read all sections
  file = fileread(filename);

  % Erase return-carrige character: (\r)
  strFile = erase(file,char(13));

  [info,Node] = ReadABAQUSNode(strFile);
end

function [info,Node] = ReadABAQUSNode(strFile)
%ReadABAQUSNode Summary of this function goes here
%   Detailed explanation goes here
  % extract nodes info
  % add keyword '**NODE', '**ENDNODE' manually to locate nodes info

  str_node = extractBetween(strFile,['**NODE',newline],[newline,'**ENDNODE']);
  if isempty(str_node), error('Error - Nodes are missing!'); end
  cell_N    = splitlines(str_node);

  % statistic info
  info.nNode = length(cell_N);

  % read nodes coordinates
  Node.coord = zeros(info.nNode, 3);
  for i = 1:length(cell_N)
    % <node ID>, <x coordinate>, <y coordinate>, <z coordinate>
    temp     = sscanf(cell_N{i},'%d, %g, %g, %g');
    Node.coord(i,:) = temp(2:end);
  end

end