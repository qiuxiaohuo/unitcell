function [info,physTag2Name,physName2Tag,geoEntity,V,ELEM,pedcPair] = ReadGMSHV4(filename)
%Read GMSH format file
% This ReadGMSHV4 funtion reads gmsh .msh files in version 4.1,
% To know more about gmsh .msh format, please refer to 
% Gmsh mannel, Chapter 9, File formats
%
% Output
%   info - mesh information, cantains mesh format version, number of nodes, etc.
%     structure
%   physTag2Name - mappings from physical tag (int) to physical name (string)
%     mappings 
%   physName2Tag - mappings from physical name (string) to physical tag (int)
%     mappings
%   geoEntity - geometric entities of points, curves, surfaces and volumes
%     structure
%   V - nodes of mesh
%     structure
%   ELEM - elements of mesh
%     structure
%   pedcPair - nodes pair generated by periodic mesh
%     structure
% Example
%   [info,physTag2Name,physName2Tag,geoEntity,V,ELEM,pedcPair] = ReadGMSHV4('./msh/unit_cell.msh');

  %% Read all sections
  file = fileread(filename);
  fprintf('Locate mesh file name: %s, reading mesh...\n', filename);

  % Erase return-carrige character: (\r)
  strFile = erase(file,char(13));

  %% 1. Read Mesh Format
  [info] = ReadGMSHMeshFormat(strFile);
  fprintf('Success in reading mesh format!\n');

  %% 2. Read Physical Names
  [physTag2Name, physName2Tag, info] = ReadGMSHPhysicalName(strFile, info);
  fprintf('Success in reading physical name!\n');

  %% 3. Read Entities
  [geoEntity] = ReadGMSHEntity(strFile);
  fprintf('Success in reading geometry entity!\n');

  %% 4. Read Nodes
  [V,info] = ReadGMSHNode(strFile, info);
  fprintf('Success in reading mesh node!\n');

  %% 5. Read Elements
  [ELEM,info] = ReadGMSHMesh(strFile, geoEntity, info);
  fprintf('Success in reading mesh element!\n');

  %% 6. Read Periodic
  pedcPair = ReadGMSHPerodic(strFile);
  fprintf('Success in reading periodic node pair!\n');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%ReadGMSHMeshFormat Read gmsh keyword $MeshFormat
% Output
%   info.version - gmsh format version
%   info.fileType - gmsh file type, ASCII or binary
%   info.mode - 1 for binary mode
function [info] = ReadGMSHMeshFormat(strFile)
  MeshFormat    = extractBetween(strFile,['$MeshFormat',newline],[newline,'$EndMeshFormat']);
  
  % Sanity check
  if isempty(MeshFormat),    error('Error - File without keyword $MeshFormat'); end
  cellsMF   = splitlines(MeshFormat);
  
  lineData = sscanf(cellsMF{1},'%f %d %d');
  info.version  = lineData(1);	% 4.1 is expected
  info.fileType = lineData(2);	% 0:ASCII or 1:Binary
  info.mode     = lineData(3);	% 1 in binary mode to detect endianness
  % fprintf('Mesh version %g, Binary %d, endian %d\n',...
  %             info.version,info.fileType,info.mode);
  
  % Sanity check
  if (info.version  ~= 4.1), error('Error - Expected mesh format v4.1'); end
  if (info.fileType ~= 0), error('Error - Binary file not allowed');   end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%ReadGMSHPhysicalName Read gmsh keyword $PhysicalNames
% Output
%   physTag2Name - mappings from physical tag (int) to physical name (string)
%     mappings 
%   physName2Tag - mappings from physical name (string) to physical tag (int)
%     mappings
%   info.nDim - dimension of problem
function [physTag2Name, physName2Tag, info] = ReadGMSHPhysicalName(strFile, info)
  
  % extract PhysicalName info
  PhysicalName = extractBetween(strFile,['$PhysicalNames',newline],[newline,'$EndPhysicalNames']);
  if isempty(PhysicalName), error('Error - No Physical names!'); end % sanity check
  cellsPN   = splitlines(PhysicalName);
  
  % intial data struct
  phys = struct('dim',{},'tag',{},'name',{});

  % read first data line: number of physical name
  nPhysName = sscanf(cellsPN{1},'%d');

  % read the next data lines
  for i = 1:nPhysName
    parts = strsplit(cellsPN{i+1});
    phys(i).dim  = str2double(parts{1});
    phys(i).tag  = str2double(parts{2});
    phys(i).name = strrep(parts{3},'"','');
  end

  % create mappings
  physTag2Name = containers.Map([phys.tag],{phys.name});
  physName2Tag = containers.Map({phys.name},[phys.tag]);

  % statistic info
  info.nDim = max([phys.dim]);
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%ReadGMSHEntity Read gmsh keyword $Entities
% Output
%   geoEntitu.P - point entity
%     structure vector
%   geoEntitu.C - curve entity
%     structure vector
%   geoEntitu.S - surface entity
%     structure vector
%   geoEntitu.V - volume entity
%     structure vector
function [geoEntity] = ReadGMSHEntity(strFile)
  % extract entity info
  Entities      = extractBetween(strFile,['$Entities',newline],[newline,'$EndEntities']);
  if isempty(Entities),      error('Error - No Entities found!'); end % Sanity check
  cellEnt  = splitlines(Entities);

  % initial data struct
  point   = struct('entiTag',{},'physTag',{});
  curve   = struct('entiTag',{},'physTag',{});
  surface = struct('entiTag',{},'physTag',{});
  volume  = struct('entiTag',{},'physTag',{});
  
  % read first data line
  l = 1;
  % numPoints(size_t) numCurves(size_t) numSurfaces(size_t) numVolumes(size_t)
  lineData  = sscanf(cellEnt{l},'%d %d %d %d');
  nP = lineData(1);
  nC = lineData(2);
  nS = lineData(3);
  nV = lineData(4);
  l = l+1;

  % read points
  if nP>0, for i = 1:nP, point(i)   = GetGMSHEntity(cellEnt{l},'node');    l = l+1; end, end
  % read curves
  if nC>0, for i = 1:nC, curve(i)   = GetGMSHEntity(cellEnt{l},'curve');   l = l+1; end, end
  % read surfaces
  if nS>0, for i = 1:nS, surface(i) = GetGMSHEntity(cellEnt{l},'surface'); l = l+1; end, end
  % read volumes
  if nV>0, for i = 1:nV, volume(i)  = GetGMSHEntity(cellEnt{l},'volume');  l = l+1; end, end

  % forming geometry entity
  geoEntity.P = point;
  geoEntity.C = curve;
  geoEntity.S = surface;
  geoEntity.V = volume;
end

% Get single entity information:
function entity = GetGMSHEntity(strLine,type)
  % extract vector from data line 
  dataVec = str2double(regexp(strLine,'-?[\d.]+(?:e-?\d+)?','match'));

  switch type
    case 'node'
      % pointTag(int) X(double) Y(double) Z(double) 
      %   numPhysicalTags(size_t) physicalTag(int) ...
      % 1. get entityTag
      entiTag = dataVec(1);

      % 2. get entity coordinates % not needed
      % ignore indexes 2, 3, 4

      % 3. get physical tag associated
      nPhysTag = dataVec(5);
      if nPhysTag == 0
        physTag = -1;
      else
        physTag = dataVec(6);
      end

    otherwise
      % curves, surfaces and volumes have similar data struct, e.g.
      % curveTag(int) (1)
      % minX(double) minY(double) minZ(double) maxX(double) maxY(double) maxZ(double) (2-7)
      % numPhysicalTags(size_t) physicalTag(int) ... (8-)
      % numBoundingPoints(size_t) pointTag(int) ...
      % 1. get entityTag
      entiTag = dataVec(1);
  
      % 2. get entity boxing limits (for visualization) % not needed
      % ignore indexes 2, 3, 4, 5, 6, 7
      
      % 3. get physical tag associated
      nPhysTag = dataVec(8);
      if nPhysTag == 0
        physTag = -1;
      else
        physTag = dataVec(9);
      end
  end
  % output structure:
  entity  = struct('entiTag',entiTag,'physTag',physTag);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%ReadGMSHNode Read gmsh keyword $Nodes
% Output
%   V.coord - coordinate of node
%     matrix (number of node X dimension)
%   V.entiDim - entity dimension which node belongs to
%     vector (number of node)
%   V.entiTag - enetity tag which node belongs to
%     vector (number of node)
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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%ReadGMSHNode Read gmsh keyword $Nodes
% Output
% ELEM is a structure consisting of four structure vectors:
%   PE - point element
%   LE - line element
%   SE - surface element
%   VE - volume element
% each structure has the following fields:
%   EToV - element connectivity matrix
%     matrix (number of element X number of nodes in element)
%   physTag - physical tag which element belongs to
%     vector
%   geomTag - geometry tag which element belongs to
%     vector
%   Etype - element type, indexed by gmsh rule
%     vector (1:line, 2:triangle, 4:tetrahedron, 15:point)
%   NELEM - number of element
%     scale
function [ELEM,info] = ReadGMSHMesh(strFile, geoEntity, info)
  Elements      = extractBetween(strFile,['$Elements',newline],[newline,'$EndElements']);
  if isempty(Elements),      error('Error - No elements found!'); end
  cellE    = splitlines(Elements);
  
  % read first line
  % numEntityBlocks(size_t) numElements(size_t) minElementTag(size_t) maxElementTag(size_t)
  l = 1; 
  lineData         = sscanf(cellE{l},'%d %d %d %d');
  nEntityBlocks    = lineData(1);
  nElements        = lineData(2);
  %minElementsTag  = line_data(3); % not needed
  %maxElementsTag  = line_data(4); % not needed
  
  % Allocate space for Elements data
  PE = struct('EToV',{[]},'physTag',{[]},'geomTag',{[]},'Etype',{[]},'NELEM',{[]});
  LE = struct('EToV',{[]},'physTag',{[]},'geomTag',{[]},'Etype',{[]},'NELEM',{[]});
  SE = struct('EToV',{[]},'physTag',{[]},'geomTag',{[]},'Etype',{[]},'NELEM',{[]});
  VE = struct('EToV',{[]},'physTag',{[]},'geomTag',{[]},'Etype',{[]},'NELEM',{[]});
  
  % Element counters
  numE1  = 0; % Lines        
  numE2  = 0; % Triangle     
  numE3  = 0; % Quatrilateral
  numE4  = 0; % Tetrahedron  
  numE15 = 0; % point        
  
  % Read elements blocks
  for ent = 1:nEntityBlocks
    % entityDim(int) entityTag(int) elementType(int) numElementsInBlock(size_t)
    l = l+1; lineData = sscanf(cellE{l},'%d %d %d %d');
    % entityDim     = lineData(1);  % 0:point, 1:curve, 2:surface, 3:volume
    entityTag     = lineData(2);
    elementType   = lineData(3);  % 1:line, 2:triangle, 4:tetrahedron, 15:point
    nElemInBlock  = lineData(4);
    
    % Read Elements in block
    for i=1:nElemInBlock
      l = l+1; lineData = sscanf(cellE{l},'%d %d %d %d %d');
      %elementID = line_data(1); % we use a local numbering instead
      switch elementType
        case 1 % Line elements
          numE1 = numE1 + 1;
          LE.Etype  (numE1,1) = elementType;
          LE.EToV   (numE1,:) = lineData(2:3);
          LE.geomTag(numE1,1) = entityTag;
          LE.physTag(numE1,1) = entityTag2PhysTag(geoEntity, 1, entityTag);
          
        case 2 % triangle elements
          numE2 = numE2 + 1;
          SE.Etype(numE2,1)   = elementType;
          SE.EToV(numE2,:)    = lineData(2:4);
          SE.geomTag(numE2,1) = entityTag;
          SE.physTag(numE2,1) = entityTag2PhysTag(geoEntity,2,entityTag);
          
        case 3 % quatrilateral elements
          numE3 = numE3 + 1;
          SE.Etype(numE3,1)   = elementType;
          SE.EToV(numE3,:)    = lineData(2:5);
          SE.geomTag(numE3,1) = entityTag;
          SE.physTag(numE3,1) = entityTag2PhysTag(geoEntity,2,entityTag);
          
        case 4 % tetrahedron elements
          numE4 = numE4 + 1;
          VE.Etype(numE4,1)   = elementType;
          VE.EToV(numE4,:)    = lineData(2:5);
          VE.geomTag(numE4,1) = entityTag;
          VE.physTag(numE4,1) = entityTag2PhysTag(geoEntity,3,entityTag);
          
        case 15 % Point elements
          numE15 = numE15 + 1;
          PE.Etype(numE15,1)   = elementType;
          PE.EToV(numE15,:)    = lineData(2);
          PE.geomTag(numE15,1) = entityTag;
          PE.physTag(numE15,1) = entityTag2PhysTag(geoEntity,0,entityTag);
          
        otherwise, error('ERROR: element type not in list');
          
      end
    end
  end
  
  PE.NELEM =        numE15;
  LE.NELEM =         numE1;
  SE.NELEM = numE2 + numE3;
  VE.NELEM =         numE4;
  
  % fprintf('Total point-elements found         = %d\n',numE15);
  % fprintf('Total line-elements found          = %d\n',numE1);
  % fprintf('Total triangle-elements found      = %d\n',numE2);
  % fprintf('Total quatrilateral-elements found = %d\n',numE3);
  % fprintf('Total elems found = %d\n',numE4);
  
  % Sanity check
  nElem = numE15+numE1+numE2+numE4+numE3;
  if nElements ~= nElem
    error('Total number of elements missmatch!'); 
  end

  % forming element data
  ELEM = struct('PE',{PE},'LE',{LE},'SE',{SE},'VE',{VE});

  % statistic info
  info.nElem = numE4; % only counts volume-elements
end

function physTag = entityTag2PhysTag(geoEntity, entityDim, entityTag)
  switch entityDim
    case 0 % point
      pTag = extractfield(geoEntity.P,'entiTag');
      k = find(pTag==entityTag);
      if ~isempty(k)
        physTag = geoEntity.P(k).physTag;
      else
        error("Could not find entity %d in Points!", entityTag);
      end
    case 1 % Curve
      cTag = extractfield(geoEntity.C,'entiTag');
      k = find(cTag==entityTag);
      if ~isempty(k)
        physTag = geoEntity.C(k).physTag;
      else
        error("Could not find entity %d in Curves!", entityTag);
      end
    case 2 % Surface
      sTag = extractfield(geoEntity.S,'entiTag');
      k = find(sTag==entityTag);
      if ~isempty(k)
        physTag = geoEntity.S(k).physTag;
      else
        error("Could not find entity %d in Surfaces!", entityTag);
      end
    case 3 % Volume
      vTag = extractfield(geoEntity.V,'entiTag');
      k = find(vTag==entityTag);
      if ~isempty(k)
        physTag = geoEntity.V(k).physTag;
      else
        error("Could not find entity %d in Volumes!", entityTag);
      end
  end
end

% //TODO add comments for periodic parser function
function pedcPair = ReadGMSHPerodic(strFile)
  % Extract strings between:
  Periodic      = extractBetween(strFile,['$Periodic',newline],[newline,'$EndPeriodic']);
  if isempty(Periodic),      error('Error - No Periodic mesh !'); end
  cellPer    = splitlines(Periodic);
  
  % read first line
  % numPeriodicLinks(size_t)
  l = 1;  lineData = sscanf(cellPer{l},'%d');
  numPeriodicLinks = lineData(1);
  
  pedcPair = struct('entiDim',{[]},'entiTag',{[]},'entiTagM',{[]},'nodePair',{[]});
  for i = 1:numPeriodicLinks
    % entityDim(int) entityTag(int) entityTagMaster(int)
    l = l+1; lineData = sscanf(cellPer{l},'%d %d %d');
    pedcPair(i).entiDim  = lineData(1);
    pedcPair(i).entiTag  = lineData(2);
    pedcPair(i).entiTagM = lineData(3);
  
    % numAffine(size_t) value(double) ..., skip
    l = l+1; 
  
    % numCorrespondingNodes(size_t)
    l = l+1; nPair = sscanf(cellPer{l},'%d');
  
    for ipair = 1:nPair
      % nodeTag(size_t) nodeTagMaster(size_t)
      l = l+1; pedcPair(i).nodePair(ipair,:) = sscanf(cellPer{l},'%d %d');
    end
  end
end