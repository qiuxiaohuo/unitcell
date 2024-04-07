function [essDof,essVal] = ReadABAQUSBoundary(strFile)
%ReadABAQUSBoundary Summary of this function goes here
%   Detailed explanation goes here
  BOUNDARY = extractBetween(strFile,['*BOUNDARY',newline], [newline,'*']);
  cells_BC = splitlines(BOUNDARY);
  essDof = [];
  essVal = [];

  for i = 1:length(cells_BC)
    % data is separate by ',' thus total number equal to N(',') + 1
    ndata = length(strfind(cells_BC{i},',')) + 1; 
    switch ndata
      case 2 
        temp   = sscanf(cells_BC{i},'%d, %d');
        % <node ID>, <dof constrained>
        inode  = temp(1); idim = temp(2);
        essDof = [essDof; DofID3(inode, idim)];
        essVal = [essVal; 0];
      case 3 
        temp = sscanf(cells_BC{i},'%d, %d, %d');
        % <node ID>, <first dof constrained>, <last dof constrained>
        inode = temp(1); idimSta = temp(2); idimEnd = temp(3);
        for idim = idimSta:idimEnd
          essDof = [essDof; DofID3(inode, idim)];
          essVal = [essVal; 0];
        end
      case 4 
        temp = sscanf(cells_BC{i},'%d, %d, %d, %g');
        % <node ID>, <first dof constrained>, <last dof constrained>, <displacement>
        inode = temp(1); idimSta = temp(2); idimEnd = temp(3); disp = temp(4);
        for idim = idimSta:idimEnd
          essDof = [essDof; DofID3(inode, idim)];
          essVal = [essVal; disp];
        end

      otherwise

    end
  end