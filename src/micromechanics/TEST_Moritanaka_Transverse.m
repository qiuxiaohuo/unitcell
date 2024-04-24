% case1: matrix and fiber are the same isotropic material
eg.E_a   = 200;
eg.E_t   = 200;
eg.E_at  = 250/3;
eg.nu_at = 0.2;
eg.nu_t  = 0.2;

Moritanaka_Transverse(eg, eg,'property','Engineer')
elasticity(200,0.2)

% case2: matrix and fiber are the same transverse-isotropic material
eg.E_a   = 200;
eg.E_t   = 200;
eg.E_at  = 250/3;
eg.nu_at = 0.2;
eg.nu_t  = 0.2;

Moritanaka_Transverse(eg, eg,'property','Engineer')
elasticity(200,0.2)