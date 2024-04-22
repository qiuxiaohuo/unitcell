%% Description
% calculate E P on partitions

%% Run CalStrainConTensor.m
% calculate concentrated tensor field on unit cell

% comment out after first run, avoid repeated FEM calculation
% CalStrainConTensor

%% Average strain concentrated tensor on phase

% initial phase cells
n_phase = 2; % number of material phase
n_mode  = 6; % mode of deformation

E4 = cell(n_phase,1);  % tensor E
P4 = cell(n_phase);    % tensor P
V0 = zeros(n_phase,1); % Volume
Tag= zeros(n_phase,1); % Physical tag
Chi= cell(n_phase,1);  % indicator field

% assign physical tags for fiber and matrix in gmsh
Tag(1) = 1; % fiber tag
Tag(2) = 2; % matrix tag

% cal indicator field
for i_phase = 1:n_phase
  Chi{i_phase} = chi(Elem.VE,Tag(i_phase));
end

for i_phase = 1:n_phase % average on i_phase
  tag_i = Tag(i_phase);
  E4_i  = zeros(n_mode);
  chi_i = Chi{i_phase};

  % average E4
  for i_mode = 1:n_mode
    E_fld_i = E4_fld{i_mode};
    E4_i(:,i_mode) = avgptt(E_fld_i,Node.coord,Elem.VE,tag_i);
    
  end
  E4{i_phase} = E4_i;

  % average V0
  V0(i_phase) = avgptt(chi_i,Node.coord,Elem.VE,-1);

  % average P_j
  for j_phase = 1:n_phase
    P4_ij  = zeros(n_mode);
    for i_mode = 1:n_mode
      P4_fld_phase_j_mode_i = P4_fld{j_phase,i_mode};
      P4_ij(:,i_mode) = avgptt(P4_fld_phase_j_mode_i,Node.coord,Elem.VE,tag_i);
    end
    P4{i_phase, j_phase} = P4_ij;
  end

end
clear E_fld_i E4_i chi_i
clear P4_ij P4_fld_phase_j_mode_i
clear i_mode i_phase j_phase tag_i

%% Check analytical solution of two phase problem
% refer to eq.(4.119abcd) in P.M.

% should equal to fourth order identity tensor of Voigt notation
V0(1)*E4{1} + V0(2)*E4{2}

% homogenization of modules on unit cell
L4_c = c0_f * L4_f * E4{1} + c0_m * L4_m * E4{2}

% shoulde equal to identity tensor
P4{1,1} + P4{1,2} + E4{1}
P4{2,1} + P4{2,2} + E4{2}
