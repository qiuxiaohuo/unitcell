function [cloadVal] = ReadABAQUSCLoad(nDof,strFile)
%ReadABAQUSCLoad Summary of this function goes here
%   Detailed explanation goes here
  CLOAD = extractBetween(strFile,['*CLOAD',newline], [newline,'*']);
  cells_CL = splitlines(CLOAD);
  cloadVal = zeros(nDof,1);

  for i = 1:length(cells_CL)
    temp = sscanf(cells_CL{i},'%d, %d, %g');
    % <node ID>, <dof>, <load magnitude>
    inode = temp(1); idim = temp(2); ival = temp(3);
    cloadVal(DofID3(inode, idim)) = ival;
  end

  fprintf('Total cload found = %d\n',length(cells_CL));