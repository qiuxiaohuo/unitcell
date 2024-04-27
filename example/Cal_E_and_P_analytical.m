%% Input material paras
tita_matrix = Isotropic('solid3d',[ 68.9 0.33]);
SiC_fiber   = Isotropic('solid3d',[379.2 0.21]);

c_f = 0.267;
c_m = 1 - c_f;

%% Cal homo stiffness matrix
Lhomo = Cal_Lhomo_Mori_Tanaka(tita_matrix,SiC_fiber,c_f);
L4_f = SiC_fiber.modl;
L4_m = tita_matrix.modl;

%% Cal tensor E
E4_anal_f = 1/c_f * inv( L4_f - L4_m ) * ( Lhomo - L4_m) ;
E4_anal_m = 1/c_m * inv( L4_m - L4_f ) * ( Lhomo - L4_f );

%% Cal tensor P
P4_anal_ff = ( eye(6) - E4_anal_f) * inv(L4_f - L4_m) * L4_f;
P4_anal_fm = ( eye(6) - E4_anal_f) * inv(L4_m - L4_f) * L4_m;
P4_anal_mm = ( eye(6) - E4_anal_m) * inv(L4_m - L4_f) * L4_m;
P4_anal_mf = ( eye(6) - E4_anal_m) * inv(L4_f - L4_m) * L4_f;
