function [Strn,Strs,strnAvg,strsAvg] = CalStrainAndStressC3D4(info,physTag2Name,V_coord,ELEM_VE,Lf,Lm,U)
%CalStrainAndStressC3D4 Calculate unconstraint gloabal stiffness matrix

  % function info
  elemType = 'C3D4';
  [~,dN] = CalC3D4ElementPara(elemType);

  % preallocate struct array of Strain and Stress
  Strn(1:info.nElem) = struct('xx',{0},'yy',{0},'zz',{0},'yz',{0},'xz',{0},'xy',{0});
  Strs(1:info.nElem) = struct('xx',{0},'yy',{0},'zz',{0},'yz',{0},'xz',{0},'xy',{0});

  % average strain and stress
  strnAvg = zeros(6,1);
  strsAvg = zeros(6,1);

  for ielem = 1:info.nElem
    elemcnc = ELEM_VE.EToV(ielem,:);   % element conectivity matrix
    elemTag = ELEM_VE.physTag(ielem);  % element physical tag
    coord   = V_coord(elemcnc,:);      % nodal coordinate of element

    [B_ip,det_J] = CalBMatrix(dN, coord, elemType);

    % cal strain on elem
    strain = B_ip * U(DofID3(elemcnc));

    % cal stress on elem of material fiber and matrix
    switch physTag2Name(elemTag)
      case 'fiber',  stress = Lf*strain;
      case 'matrix', stress = Lm*strain;
      otherwise, error("Could not find physTag fiber or matrix!")
    end

    % cal average strain and stress
    strnAvg = strnAvg + 1/6.*det_J.*strain;
    strsAvg = strsAvg + 1/6.*det_J.*stress;
    
    % form strain struxt
    Strn(ielem).xx = strain(1); Strn(ielem).yy = strain(2); Strn(ielem).zz = strain(3);
    Strn(ielem).yz = strain(4); % engineering shear strain
    Strn(ielem).xz = strain(5); Strn(ielem).xy = strain(6);

    % form stress struxt
    Strs(ielem).xx = stress(1); Strs(ielem).yy = stress(2); Strs(ielem).zz = stress(3);
    Strs(ielem).yz = stress(4); Strs(ielem).xz = stress(5); Strs(ielem).xy = stress(6);
  end
end