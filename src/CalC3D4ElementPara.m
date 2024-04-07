function [N,dN] = CalC3D4ElementPara(elemType)
  switch elemType
    case 'C3D4'
      % one integral point
      xi = [ 0.25, 0.25, 0.25]; % integral point in natural coordinate
      N  = [ 1-xi(1)-xi(2)-xi(3);
                           xi(1); 
                           xi(2); 
                           xi(3)];
      dN = [ -1 -1 -1;
              1  0  0;
              0  1  0;
              0  0  1];
    otherwise

  end
end