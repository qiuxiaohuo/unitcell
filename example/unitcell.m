%% 单胞问题有限元求解
% 初始化脚本运行环境

clear
addpath(genpath(pwd));
%% 
% 初始化脚本运行信息

% create data folder
folderName = "./data";
if ~exist(folderName,'dir'), mkdir(folderName); end

% get current time, use it as current folder name
t = datetime('now','Format','yyyyMMdd-HH-mm-ss');
currentForderName = strcat(folderName,'/',string(t));
mkdir(currentForderName);

% create log file
logFileName = "ucell.txt";
fID = fopen(strcat(currentForderName,'/',logFileName),'w');

% flag of screen print and figure plot
isPrint = 1; isPlot = 1;
%% 
% 将脚本信息写入 script.log 中

% job commit message to script log
msg = input('Job commit message: ', 's');

% fileattrib('script.log', '+w') % unset script.log read only
logID = fopen('script.log','a');
fprintf(logID,'------------------------------------------------\n');
fprintf(logID,'Job commit time:    %s \n', string(t));
fprintf(logID,'Job output folder:  %s \n', currentForderName);
fprintf(logID,'Job flag status:    isPrint-%d  isPlot-%d \n', isPrint, isPlot);
fprintf(logID,'Job commit message: %s \n \n', msg);
fclose(logID);
% fileattrib('script.log', '-w') % set script.log read only
%% 
% 输入单胞几何与材料信息

E_f = 379.2; nu_f = 0.21;
E_m =  68.9; nu_m = 0.33;
c_f = 0.267; % volume fraction of fiber

Lf = CalMatrialMatrix(E_f, nu_f);
Lm = CalMatrialMatrix(E_m, nu_m);

PrintMaterialConsts(E_f,nu_f,E_m,nu_m,c_f,fID,isPrint);
%% 
% 导入由 Gmsh 生成的周期性单胞网格

mshFileName = "./msh/unit_cell.msh";
[info,physTag2Name,physName2Tag,geoEntity,V,ELEM,pedcPair] = ReadGMSHV4(mshFileName);

PrintMeshInfo(info,fID,isPrint);
%% 
% 获取主从节点, 并在网格中绘制出节点位置

Pair = CalPeriodicNodePairUC(physName2Tag,geoEntity,V,pedcPair);

PrintPairNode(Pair,fID,isPrint);
PlotPairNode(V,ELEM,Pair,currentForderName,isPlot)
%% 
% *平均应变场方法计算等效弹性模量*
% 
% 有限元求解, 需要求解 6 套方程

msg = "Result from average strain field method with linear displacement condition:";
CHomo = zeros(6,6);
for i = 1:6
  eigE  = zeros(6,1); eigE(i) = 1; % set eigenstrain
  [~,~,~,~,stressAvg] = FEMSolverRVELDC(info,physTag2Name,V,ELEM.VE,Lf,Lm,eigE);
  CHomo(:,i) = stressAvg;
end

PrintCHomoAndEnginC(CHomo,fID,isPrint,msg)
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