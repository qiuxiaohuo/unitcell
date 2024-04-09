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