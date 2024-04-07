function [V,VE,essDof,essVal,cloadVal,dloadVal,nDof] = ReadABAQUSinpFile(fileName, modelDim)
%ReadABAQUSinpFile Summary of this function goes here
%   Detailed explanation goes here
  % read file
  file = fileread(fileName);
  strFile = erase(file,char(13)); % erase return characters (\r)

  % nodes
  [V,nDof] = ReadABAQUSNode(modelDim,strFile);

  % elements
  VE = ReadABAQUSElem(strFile);

  % boundary condition
  [essDof,essVal] = ReadABAQUSBoundary(strFile);

  % concentrated loads
  [cloadVal] = ReadABAQUSCLoad(nDof,strFile);

  % distributed loads
  [dloadVal] = ReadABAQUSDLoad(nDof,strFile,V,VE);
  