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
  numE1  = 0; % Lines         Element counter
  numE2  = 0; % Triangle      Element counter
  numE3  = 0; % Quatrilateral Element counter
  numE4  = 0; % Tetrahedron   Element counter
  numE15 = 0; % point         Element counter
  
  % Read elements blocks
  for ent = 1:nEntityBlocks
    % entityDim(int) entityTag(int) elementType(int) numElementsInBlock(size_t)
    l = l+1; lineData = sscanf(cellE{l},'%d %d %d %d');
    entityDim     = lineData(1);  % 0:point, 1:curve, 2:surface, 3:volume
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