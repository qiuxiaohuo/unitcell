%% Description:
% Calculate tensor E from asymtotic differential equation

%% 
E_f = 379.2; nu_f = 0.21;
E_m =  68.9; nu_m = 0.33;
c_f = 0.267; % volume fraction of fiber

Lf  = CalMatrialMatrix(E_f, nu_f);
Lm  = CalMatrialMatrix(E_m, nu_m);
%% 
% 导入由 Gmsh 生成的周期性单胞网格
mshFileName = "./msh/unit_cell.msh";
[info,physTag2Name,physName2Tag,geoEntity,V,ELEM,pedcPair] =...
  ReadGMSHV4(mshFileName);

PrintMeshInfo(info,fID,isPrint);
%% 
% 获取主从节点, 并在网格中绘制出节点位置

Pair = CalPeriodicNodePairUC(physName2Tag,geoEntity,V,pedcPair);

PrintPairNode(Pair,fID,isPrint);
PlotPairNode(V,ELEM,Pair,currentForderName,isPlot)