function [info] = ReadGMSHMeshFormat(strFile)
  MeshFormat    = extractBetween(strFile,['$MeshFormat',newline],[newline,'$EndMeshFormat']);
  
  % Sanity check
  if isempty(MeshFormat),    error('Error - Wrong File Format!'); end
  cellsMF   = splitlines(MeshFormat);
  
  lineData = sscanf(cellsMF{1},'%f %d %d');
  info.version   = lineData(1);	% 4.1 is expected
  info.file_type = lineData(2);	% 0:ASCII or 1:Binary
  info.mode      = lineData(3);	% 1 in binary mode to detect endianness
  % fprintf('Mesh version %g, Binary %d, endian %d\n',...
  %             info.version,info.file_type,info.mode);
  
  % Sanity check
  if (info.version ~= 4.1), error('Error - Expected mesh format v4.1'); end
  if (info.file_type ~= 0), error('Error - Binary file not allowed');   end
end