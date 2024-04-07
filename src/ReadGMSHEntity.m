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