function U = FEMSolverUCell(info,physTag2Name,V,ELEM_VE,Pair,Lf,Lm,eigE0)
%FEMSolverUCell Solve unit cell equations
%   Detailed explanation goes here

  % form constraint matrix for RVE
  [C,g] = CalConstraintMatrix(info,Pair,[0 0 0 0 0 0]); % approach 1

  % form force array for UCell problem
  [f] = CalUCellForce(info,physTag2Name,V.coord,ELEM_VE,Lf,Lm,eigE0);

  % cal stiffness matrix
  [K] = CalStiffnessMatrixC3D4TwoPhase(info,physTag2Name,V.coord,ELEM_VE,Lf,Lm);

  % lagrange multiplier
  Kl = [K C';C zeros(size(C,1))];
  Ul = Kl\[f;g];
  U  = Ul(1:info.nDof);

end