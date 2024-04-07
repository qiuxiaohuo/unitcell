function [dloadVal] = ReadABAQUSDLoad(nDof,strFile,V,VE)
%ReadABAQUSCLoad Summary of this function goes here
%   Detailed explanation goes here
  DLOAD = extractBetween(strFile,['*DLOAD,OP=NEW',newline], [newline,'*']);
  cells_DL = splitlines(DLOAD);
  dloadVal = zeros(nDof,1);

  for i = 1:length(cells_DL)
    temp = textscan(cells_DL{i},'%d %s %f','Delimiter',',');
    % <element ID>, <element face ID>, <pressure>
    ielem = temp{1}; strElemFace = temp{2}{1}; pres = temp{3};
    switch strElemFace
      case 'P1'
        trifaceloc = [1 3 2];
      case 'P2'
        trifaceloc = [1 2 4];
      case 'P3'
        trifaceloc = [2 3 4];
      case 'P4'
        trifaceloc = [1 4 3];
    end

    elemcnc = VE(ielem,:);
    faceNodeId = elemcnc(trifaceloc);

    % cal nodal force of one node
    n1 = V(faceNodeId(1),:); n2 = V(faceNodeId(2),:); n3 = V(faceNodeId(3),:);
    fe = -1/6 * pres * cross(n2-n1,n3-n1);

    % pressure contributes to equal force on three nodes of element face
    dloadVal(DofID3(faceNodeId)) = dloadVal(DofID3(faceNodeId)) + [fe';fe';fe'];
  end