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