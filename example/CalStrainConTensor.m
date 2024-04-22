%% Description
% Calculate concentrated tensor A_{ijkl}(y) of unit cell
%
% A_{ijkl}(y) is a fourth-order tensor field, transforming coarse-scale strain
% ec_{kl} into fine-scale strain ef_{ij}(y):
% 
% (1)               ef_{ij}(y) = A_{ijkl}(y) ec_{kl}
% 
% A_{ijkl}(y) has 36 components, every 6 components represent a deformation
% mode. A_{ijkl}(y) is stored in a 1x6 cell array, each cell is calculated 
% from one mode and stored as a matrix of size (nDof, 6).
% To perform EQ.1 with coarse scale strain e(1,6) stored in Voigt notation,
% 

%% Initial
init;

%% script input
% material para
E0_f = 379.2; nu0_f = 0.21;
E0_m =  68.9; nu0_m = 0.33;
c0_f = 0.267; c0_m  = 1-c0_f;

%#TODO: rewrite material matrix function
L4_f = elasticity(E0_f, nu0_f);
L4_m = elasticity(E0_m, nu0_m);

mshFileName   = "./msh/unit_cell.msh";
datFolderName = "./data";

% initialize strain concentrated tensor
Cct = {};

%% Read mesh
[info,physTag2Name,physName2Tag,geoEntity,Node,Elem,pedcPair] = ...
  ReadGMSHV4(mshFileName);
% PrintMeshInfo(info);

%% Get master-slave nodes pair
Pair = CalPeriodicNodePairUC(physName2Tag,geoEntity,Node,pedcPair);

%% RVE method, with periodic boundary condition
% for i = 1:6
%   eigE  = zeros(6,1); eigE(i) = 1; % set eigenstrain
%   U = FEMSolverRVEPBC(info,physTag2Name,V,ELEM.VE,Pair,Lf,Lm,eigE);
%   Strncct{i} = strain(info,V.coord,ELEM.VE,U);
% end

%% aymtotic methods, with periodic boundary condition
for i = 1:6
  eigE  = zeros(6,1); eigE(i) = 1; % set eigenstrain
  U = FEMSolverUCell(info,physTag2Name,Node,Elem.VE,Pair,L4_f,L4_m,eigE);
  Cct{i} = strain(info,Node.coord,Elem.VE,-U) ...
    + constfield(eigE',Elem.VE.NELEM);
end
