%% Initial
init;

%% script input
E_f = 379.2; nu_f = 0.21;
E_m =  68.9; nu_m = 0.33;
c_f = 0.267; % volume fraction of fiber

Lf = CalMatrialMatrix(E_f, nu_f);
Lm = CalMatrialMatrix(E_m, nu_m);

mshFileName   = "./msh/unit_cell.msh";
datFolderName = "./data";

% initialize strain concentrated tensor
Strncct = {};

%% Read mesh
[info,physTag2Name,physName2Tag,geoEntity,V,ELEM,pedcPair] = ReadGMSHV4(mshFileName);
% PrintMeshInfo(info);

%% Get master-slave nodes pair
Pair = CalPeriodicNodePairUC(physName2Tag,geoEntity,V,pedcPair);

%% RVE method, with periodic boundary condition
% for i = 1:6
%   eigE  = zeros(6,1); eigE(i) = 1; % set eigenstrain
%   U = FEMSolverRVEPBC(info,physTag2Name,V,ELEM.VE,Pair,Lf,Lm,eigE);
%   Strncct{i} = strain(info,V.coord,ELEM.VE,U);
% end

%% aymtotic methods, with periodic boundary condition
for i = 1:6
  eigE  = zeros(6,1); eigE(i) = 1; % set eigenstrain
  U = FEMSolverUCell(info,physTag2Name,V,ELEM.VE,Pair,Lf,Lm,eigE);
  Strncct{i} = strain(info,V.coord,ELEM.VE,-U) + constfield(eigE',ELEM.VE.NELEM);
end

