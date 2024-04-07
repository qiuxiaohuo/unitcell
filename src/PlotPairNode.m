function PlotPairNode(V,ELEM,Pair,currentForderName,isPlot)
%PlotPairNode Summary of this function goes here
%   Detailed explanation goes here
  
  if isPlot
    % plot mesh
    pdeplot3D(V.coord',ELEM.VE.EToV');
    hold on
  
    % plot pair nodes
    nodeX  = Pair.X(:,1); nodeXM  = Pair.X(:,2);
    nodeY  = Pair.Y(:,1); nodeYM  = Pair.Y(:,2);
    nodeZ  = Pair.Z(:,1); nodeZM  = Pair.Z(:,2);
  
    scatter3(V.coord(nodeXM,1), V.coord(nodeXM,2), V.coord(nodeXM,3),...
              100,'rp','filled');
    scatter3(V.coord(nodeX, 1), V.coord(nodeX, 2), V.coord(nodeX, 3),...
              81, 'ro','filled');
    scatter3(V.coord(nodeYM,1), V.coord(nodeYM,2), V.coord(nodeYM,3),...
              100,'bp','filled');
    scatter3(V.coord(nodeY, 1), V.coord(nodeY, 2), V.coord(nodeY, 3),...
              81, 'bo','filled');
    scatter3(V.coord(nodeZM,1), V.coord(nodeZM,2), V.coord(nodeZM,3),...
              100,'kp','filled');
    scatter3(V.coord(nodeZ, 1), V.coord(nodeZ, 2), V.coord(nodeZ, 3),...
              81, 'ko','filled');

    % save fig
    figName = strcat(currentForderName,"/","nodePair.png");
    saveas(gcf,figName)
  
    hold off
  end
end