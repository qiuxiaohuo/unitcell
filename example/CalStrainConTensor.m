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

%% Initialize script

init;

%% Set script input

% const number
n_phase = 2; % number of material phase
n_mode  = 6; % mode of deformation

% material para
E0_f = 379.2; nu0_f = 0.21;
E0_m =  68.9; nu0_m = 0.33;
c0_f = 0.267; c0_m  = 1-c0_f;

% rewrite material matrix function
L4_f = elasticity(E0_f, nu0_f);
L4_m = elasticity(E0_m, nu0_m);

mshFileName   = "./msh/unit_cell.msh";
datFolderName = "./data";

% initialize strain concentrated tensor
E4_fld = cell(1,n_mode);
P4_fld = cell(n_phase,n_mode);

%% Read mesh

[info,physTag2Name,physName2Tag,geoEntity,Node,Elem,pedcPair] = ...
  ReadGMSHV4(mshFileName);
% PrintMeshInfo(info);

%% Get master-slave nodes pair

Pair = CalPeriodicNodePairUC(physName2Tag,geoEntity,Node,pedcPair);

%% Aymtotic methods, with periodic boundary condition

for i_mode = 1:n_mode
  mode_i = zeros(n_mode,1); mode_i(i_mode) = 1; % set eigenstrain
  [u,p_f,p_m] = FEMSolverUCell(info,physTag2Name,Node,Elem.VE,Pair,L4_f,L4_m,mode_i);
  E4_fld{i_mode}  = strain(info,Node.coord,Elem.VE,-u) ...
    + constfield(mode_i',Elem.VE.NELEM);

  P4_fld{1,i_mode} = strain(info,Node.coord,Elem.VE,p_f);
  P4_fld{2,i_mode} = strain(info,Node.coord,Elem.VE,p_m);
end

clear mode_i u p_f p_m
