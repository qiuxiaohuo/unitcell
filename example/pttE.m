%% Description
% calculate E on partitions
% physical group index:
%   fiber - 1 | matrix - 2

%% run CalStrainConTensor.m
% CalStrainConTensor

%% average strain concentrated tensor on phase
% physical tags for fiber and matrix in gmsh
int_tag_f = 1;
int_tag_m = 2;

E4_f = zeros(6,6);
E4_m = zeros(6,6);
V0_f = 0;
V0_m = 0;

for i = 1:6
  [E4_f(:,i),V0_f] = avgptt(Cct{i},Node.coord,Elem.VE,int_tag_f);
  [E4_m(:,i),V0_m] = avgptt(Cct{i},Node.coord,Elem.VE,int_tag_m);
end

%% check analytical solution
V0_f*E4_f + V0_m*E4_m

%% average Lc
L4_c = c0_f * L4_f * E4_f + c0_m * L4_m * E4_m

