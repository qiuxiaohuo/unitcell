function [V,info] = ReadGMSHNode(strFile, info)

  % extract nodes info
  Nodes         = extractBetween(strFile,['$Nodes',newline],[newline,'$EndNodes']);
  if isempty(Nodes),         error('Error - Nodes are missing!'); end
  cellN    = splitlines(Nodes);
  
  % read first line
  % numEntityBlocks(size_t) numNodes(size_t) minNodeTag(size_t) maxNodeTag(size_t) 
  l = 1; 
  lineData      = sscanf(cellN{l},'%d %d %d %d');
  nEntityBlocks = lineData(1);
  nNode         = lineData(2);
  %minNodeTag      = line_data(3); % not needed
  %maxNodeTag      = line_data(4); % not needed
  
  % read nodes
  V = GetGMSHNode(cellN,nEntityBlocks,nNode);

  % statistic info
  info.nNode = length(V.coord);
  info.nDof  = info.nNode*info.nDim;
  % fprintf('Total nodes found = %g\n',info.nNode);
  % fprintf('Total  Dofs found = %g\n',info.nDof);
end

function V = GetGMSHNode(cellN,nNodeBlock,nNode)
  % allocate space for nodal data
  V.coord   = zeros(nNode,3); % [x,y,z]
  V.entiDim = zeros(nNode,1); % entityDim
  V.entiTag = zeros(nNode,1); % entityTad

  l = 1; % this is the parameters line

  % Read nodes blocks:   (can be read in parallel!)
  for ent = 1:nNodeBlock
    % read block parameters
    % entityDim(int) entityTag(int) parametric(int; 0 or 1) numNodesInBlock(size_t) 
    l = l+1;
    line_data  = sscanf(cellN{l},'%d %d %d %d');
    entityDim  = line_data(1);
    entityTag  = line_data(2);
    %parametric = line_data(3); % not needed
    nNodeInBlc = line_data(4);
    
    % read nodes IDs
    nodeTag = zeros(1,nNodeInBlc); % nodeTag
    for i = 1:nNodeInBlc
      l = l+1;
      % nodeTag(size_t) 
      % ...
      nodeTag(i) = sscanf(cellN{l},'%d');
    end
    
    % read nodes coordinates
    for i = 1:nNodeInBlc
      l = l+1;
      % x(double) y(double) z(double) 
      % ...
      temp = sscanf(cellN{l},'%g %g %g'); % [x(i),y(i),z(i)]
      V.coord(nodeTag(i),:) = temp;
    end

    % assign values for nodes in the block
    V.entiDim(nodeTag) = entityDim;
    V.entiTag(nodeTag) = entityTag;
  end
end