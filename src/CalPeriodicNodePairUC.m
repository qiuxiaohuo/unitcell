function Pair = CalPeriodicNodePairUC(physName2Tag, geoEntity, V, pedcPair)

  % function info
  % slave face physName    % master surface physName
  strFaceX = 'surf_front'; strFaceXM = 'surf_back'; 
  strFaceY = 'surf_right'; strFaceYM = 'surf_left'; 
  strFaceZ = 'surf_top';   strFaceZM = 'surf_bottom'; 

  % uo, ux, uy, uz physName
  struo = 'u_o'; strux = 'u_x'; struy = 'u_y'; struz = 'u_z';

  % get entity tag of face pair
  entiTagFaceX  = physName2EntiTagSurf(physName2Tag, geoEntity, strFaceX);
  entiTagFaceY  = physName2EntiTagSurf(physName2Tag, geoEntity, strFaceY);
  entiTagFaceZ  = physName2EntiTagSurf(physName2Tag, geoEntity, strFaceZ);
  entiTagFaceXM = physName2EntiTagSurf(physName2Tag, geoEntity, strFaceXM);
  entiTagFaceYM = physName2EntiTagSurf(physName2Tag, geoEntity, strFaceYM);
  entiTagFaceZM = physName2EntiTagSurf(physName2Tag, geoEntity, strFaceZM);

  % get node ID of uo, ux, uy, uz
  uo  = physName2NodeID(physName2Tag, geoEntity, V, struo);
  ux  = physName2NodeID(physName2Tag, geoEntity, V, strux);
  uy  = physName2NodeID(physName2Tag, geoEntity, V, struy);
  uz  = physName2NodeID(physName2Tag, geoEntity, V, struz);

  % get nodePair of three direction
  nodePairX = GetNodePairSurf(entiTagFaceX, entiTagFaceXM, pedcPair);
  nodePairY = GetNodePairSurf(entiTagFaceY, entiTagFaceYM, pedcPair);
  nodePairZ = GetNodePairSurf(entiTagFaceZ, entiTagFaceZM, pedcPair);

  % shift pair (ui, uo) to top row, i=x,y,z
  nodePairX = RearrangeNodePair(ux,uo,nodePairX);
  nodePairY = RearrangeNodePair(uy,uo,nodePairY);
  nodePairZ = RearrangeNodePair(uz,uo,nodePairZ);

  % delete repeated constrainted pairs
  for i = size(nodePairY,1):(-1):1
    x = V.coord(nodePairY(i,1), 1);
    % for pairs in y direction, repeated nodes
    % are those with coordinate x equal to 1
    if abs(x-1.0) < 1e-10
      nodePairY(i,:)=[];
    end
  end

  for i = size(nodePairZ,1):(-1):1
    x = V.coord(nodePairZ(i,1),1); y = V.coord(nodePairZ(i,1),2);
    % for pairs in z direction, repeated nodes
    % are those with coordinate x or y equal to 1
    if abs(x-1.0)<1e-10 || abs(y-1.0)<1e-10
      nodePairZ(i,:)=[];
    end
  end

  % construct Pair
  Pair.N = size(nodePairX,1) + size(nodePairY,1) + size(nodePairZ,1);
  Pair.X = nodePairX;
  Pair.Y = nodePairY;
  Pair.Z = nodePairZ;
end

function entiTag = physName2EntiTagSurf(physName2Tag, geoEntity, strSurfName)
% physName2EntiTagSurf find entity tag from physName of surface

  % return physical tag from physical name
  physTag = physName2Tag(strSurfName);

  % extract phystag field from all surface entities
  physTagField = extractfield(geoEntity.S,'physTag');

  % identify position of surface entity
  k = find(physTagField==physTag);
  if ~isempty(k)
    entiTag = [geoEntity.S(k).entiTag];
  else
    error("Could not find surface %s in geometry entities!", strSurfName)
  end
end

function nodeID  = physName2NodeID(physName2Tag, geoEntity, V, strPtName)
  % get entity tag of Point 
  ptPhysTag = physName2Tag(strPtName);
  k = find(extractfield(geoEntity.P,'physTag')==ptPhysTag);
  if ~isempty(k)
    ptEntiTag = geoEntity.P(k).entiTag;
  else
    error("No match physical tag of point %s!", strPtName)
  end

  % get node ID
  k = find(V.entiTag==ptEntiTag);
  if ~isempty(k)
    nodeID = k(1); % first of array belongs to dim 0 entity.
  end
end

function nodePair = GetNodePairSurf(entiTag, entiTagM, pedcPair)

  % extract field from pedcPair
  fieldEntiDim  = extractfield(pedcPair,'entiDim');
  fieldEntiTag  = extractfield(pedcPair,'entiTag');
  fieldEntiTagM = extractfield(pedcPair,'entiTagM');

  % locate surface entity
  sfloc = find(fieldEntiDim==2);

  % locate entiTag, entiTagM in local array fieldEntiTag(sfloc)
  [~,entiloc]  = ismember(entiTag,  fieldEntiTag(sfloc));
  [~,entiMloc] = ismember(entiTagM, fieldEntiTagM(sfloc));

  % check whether entiTag, entiTagM form a M-S pair
  if all(entiloc == entiMloc)
    nodePair = vertcat(pedcPair(sfloc(entiloc)).nodePair); % entiloc might be array
    nodePair = unique(nodePair,'row','stable'); % delete repeated pairs
  else
    error("fail to ...")
  end
end

function nodePair = RearrangeNodePair(ui,uo,nodePair)
  % get row ID where uo belongs to
  k = find(nodePair(:,2)==uo);
  if isempty(k)
    error("Not find node ID uo in nodePair!")
  end

  % check whether ui in nodePair is the same as ui
  uiInPair = nodePair(k,1);
  if ui ~= uiInPair
    error("ui ID in nodePair does NOT match input ui!")
  end

  % shift (ui, ux) line to the top
  nodePair(k,:) = nodePair(1,:);
  nodePair(1,:) = [ui uo];
end