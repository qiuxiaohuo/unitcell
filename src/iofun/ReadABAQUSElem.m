function VE = ReadABAQUSElem(strFile)
%ReadABAQUSNode Summary of this function goes here
%   Detailed explanation goes here
  % extract elems info
  ELEM    = extractBetween(strFile,['**ELEMENT',newline], [newline,'**ENDELEMENT']);
  cells_E = splitlines(ELEM);

  % read elems connectivity
  VE = zeros(length(cells_E)-1, 4);
  for i = 2:length(cells_E)
    temp = sscanf(cells_E{i},'%d, %d, %d, %d, %d'); % id,x(i),y(i)
    VE(i-1,:) = temp(2:end);
  end
  fprintf('Total elements found = %d\n',length(VE));
end