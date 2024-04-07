function [U,Strn,Strs,strnAvg,strsAvg] = FEMSolverRVEPBC(info,physTag2Name,V,ELEM_VE,Pair,Lf,Lm,eigE0)
%FEMSolverUCellLDC Solve 
%   Detailed explanation goes here

  % form constraint matrix for RVE
  [C,g] = CalConstraintMatrix(info,Pair,eigE0);

  % form force array for RVE problem, which is zero
  f = zeros(info.nDof,1);

  % cal stiffness matrix
  [K] = CalStiffnessMatrixC3D4TwoPhase(info,physTag2Name,V.coord,ELEM_VE,Lf,Lm);

  % lagrange multiplier
  Kl = [K C';C zeros(size(C,1))];
  Ul = Kl\[f;g];
  U  = Ul(1:info.nDof);

  %% postprocess
  % cal strain and stress
  [Strn,Strs,strnAvg,strsAvg] = CalStrainAndStressC3D4(info,physTag2Name,V.coord,ELEM_VE,Lf,Lm,U);

end
