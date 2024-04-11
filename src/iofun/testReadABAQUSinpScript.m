  fileName = 'C3D4_tensile.inp';
  modelDim = 3;

  %% read file
  file = fileread(fileName);
  strFile = erase(file,char(13)); % erase return characters (\r)

  %% nodes
  [V,nDof] = ReadABAQUSNode(modelDim,strFile);

  %% elements
  VE = ReadABAQUSElem(strFile);

  %% boundary condition
  [essDof,essVal] = ReadABAQUSBoundary(strFile);

  %% concentrated loads
  [cloadVal] = ReadABAQUSCLoad(nDof,strFile);

  %ReadABAQUSCLoad Summary of this function goes here
%   Detailed explanation goes here
  DLOAD = extractBetween(strFile,['*DLOAD,OP=NEW',newline], [newline,'*']);
  cells_DL = splitlines(DLOAD);
  dloadVal = zeros(nDof,1);

  for i = 1:length(cells_DL)
    temp = textscan(cells_DL{i},'%d %s %f','Delimiter',',');
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

    n1 = V(faceNodeId(1),:); n2 = V(faceNodeId(2),:); n3 = V(faceNodeId(3),:);
    fe = -1/6 * pres * cross(n2-n1,n3-n1);
    dloadVal(DofID3(faceNodeId)) = dloadVal(DofID3(faceNodeId)) + [fe';fe';fe'];
  end
