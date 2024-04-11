% flag of screen print and figure plot
isPrint = 1; isPlot = 1;

%% material paras
E_f = 379.2; nu_f = 0.21;
E_m =  68.9; nu_m = 0.33;
c_f = 0.267; % volume fraction of fiber

Lf = CalMatrialMatrix(E_f, nu_f);
Lm = CalMatrialMatrix(E_m, nu_m);

%% mesh input
mshFileName = "./msh/unit_cell.msh";
[info,physTag2Name,physName2Tag,geoEntity,V,ELEM,pedcPair] = ReadGMSHV4(mshFileName);

PrintInfo(info,fID,isPrint);

%% Get master-slave nodes pair
Pair = CalPeriodicNodePairUC(physName2Tag,geoEntity,V,pedcPair);

%% 
% *周期性边界条件*

msg = "Result from average strain field method with periodic boundary condition:";
pde_node = V.coord'; pde_elem = ELEM.VE.EToV'; % extract node and elem info to pdeplot RVE mesh

% cal homo material matrix via solving PDE on RVE with FEM
CHomo = zeros(6,6);
for i = 1:6
  eigE  = zeros(6,1); eigE(i) = 1; % set eigenstrain
  [u,Strn,Strs,strnAvg,strsAvg] = ...
    FEMSolverRVEPBC(info,physTag2Name,V,ELEM.VE,Pair,Lf,Lm,eigE);
  CHomo(:,i) = strsAvg;

  % plot deformation
  Chi = struct('ux',{[]},'uy',{[]},'uz',{[]});
  Chi.ux = u(1:3:end); Chi.uy = u(2:3:end); Chi.uz = u(3:3:end);
  pdeplot3D(pde_node,pde_elem,'Deformation',Chi,'DeformationScaleFactor',0.5);
  figName = strcat(currentForderName,"/","rve-deform-",num2str(i),".png");
  saveas(gcf,figName)
  
end

PrintCHomoAndEnginC(CHomo,fID,isPrint,msg);
%% 
% *单胞方程*

msg = "Result from asymtotic unit cell method with periodic boundary condition:";

CHomo = zeros(6,6);
for i = 1:6
  eigE  = zeros(6,1); eigE(i) = 1; % set eigenstrain
  [u,Strn,Strs,strnAvg,strsAvg] = ...
    FEMSolverUCell(info,physTag2Name,V,ELEM.VE,Pair,Lf,Lm,eigE);
  CHomo(:,i) = strsAvg;

  % plot deformation
  Chi = struct('ux',{[]},'uy',{[]},'uz',{[]});
  Chi.ux = u(1:3:end); Chi.uy = u(2:3:end); Chi.uz = u(3:3:end);
  pdeplot3D(pde_node,pde_elem,'Deformation',Chi,'DeformationScaleFactor',0.5);
  figName = strcat(currentForderName,"/","ucell-deform-",num2str(i),".png");
  saveas(gcf,figName)
end

CHomo = c_f*Lf + (1-c_f)*Lm - CHomo;
PrintCHomoAndEnginC(CHomo,fID,isPrint,msg);
%%
fclose('all');