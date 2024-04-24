%% case1: matrix and fiber are the same isotropic material
% matl_iso_1 = Isotropic('solid3d',[200.0 0.2]);
% matl_iso_2 = Isotropic('solid3d',[200.0 0.2]);
% Lhomo_1 = Moritanaka_Transverse(matl_iso_1, matl_iso_2, 0.5);
% Lhomo_2 = Moritanaka_Transverse(matl_iso_1, matl_iso_2, 1.0);
% Lhomo_3 = Moritanaka_Transverse(matl_iso_1, matl_iso_2, 0.0);
% matl_iso_1.modl

%% case2: matrix and fiber are the same transverse-isotropic material
prop_eg = [ 250.  100.  100.   ...
              0.2   0.2   0.25 ...
             50.   50.  100.];
matl_iso_1 = Orthotropic('solid3d',prop_eg);
matl_iso_2 = Orthotropic('solid3d',prop_eg);
Lhomo_1 = Moritanaka_Transverse(matl_iso_1, matl_iso_2, 0.5);
Lhomo_2 = Moritanaka_Transverse(matl_iso_1, matl_iso_2, 1.0);
Lhomo_3 = Moritanaka_Transverse(matl_iso_1, matl_iso_2, 0.0);
matl_iso_1.modl

%% case3: matrix and fiber are the same transverse-isotropic material
% prop_eg = [ 250.  250.  250.   ...
%               0.25  0.25  0.25 ...
%             100.  100.  100.];
% matl_iso_1 = Orthotropic('solid3d',prop_eg);
% matl_iso_2 = Orthotropic('solid3d',prop_eg);
% Lhomo_1 = Moritanaka_Transverse(matl_iso_1, matl_iso_2, 0.5);
% Lhomo_2 = Moritanaka_Transverse(matl_iso_1, matl_iso_2, 1.0);
% Lhomo_3 = Moritanaka_Transverse(matl_iso_1, matl_iso_2, 0.0);
% matl_iso_1.modl