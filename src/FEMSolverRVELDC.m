function [U,Strn,Strs, strnAvg, strsAvg] = FEMSolverRVELDC(info,physTag2Name,V,ELEM_VE,Lf,Lm,vE0)
%FEMSolverUCellLDC Solve 
%   Detailed explanation goes here

  % cal linear displacement condition for RVE
  mE0 = mapVoigt2Matrix(vE0,'strain');
  [essDof, essVal] = CalRVELDC(info,V,mE0);

  % form force array for RVE problem, which is zero
  f = zeros(info.nDof,1);

  % cal stiffness matrix
  [K] = CalStiffnessMatrixC3D4TwoPhase(info,physTag2Name,V.coord,ELEM_VE,Lf,Lm);

  % enforce linear displace boundary condition on K
  [Kc,f] = EnforceEssBC(K,f,essDof,essVal);
  U = Kc\f;


  %% postprocess
  % cal strain and stress
  [Strn,Strs,strnAvg,strsAvg] = CalStrainAndStressC3D4(info,physTag2Name,V.coord,ELEM_VE,Lf,Lm,U);

end

function [essDof, essVal] = CalRVELDC(info,V,e0)
  %SetRVELDC set essential boundary condition of unit cell 
  % with linear displacement boundary conditions

  % preallocate essential dof index and value array
  essDof = zeros(info.nDof,1);
  essVal = zeros(info.nDof,1);

  % check coordinate to find boundary nodes
  for i=1:info.nNode
    coord = V.coord(i,:);
    
    % boundary nodes must have coord 0.0 or 1.0
    if ismember(1.0,coord) || ismember(0.0,coord)
      nodeDof = DofID3(i);
      essDof(nodeDof) = nodeDof;
      essVal(nodeDof) = e0*coord'; % u_i = e0_ij * x_j
    end
  end

  % delete free Dof in essential Dof array
  freeDof = essDof==0;
  essDof(freeDof)=[];
  essVal(freeDof)=[];
end
