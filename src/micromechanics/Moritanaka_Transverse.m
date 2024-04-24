function Lhomo = Moritanaka_Transverse(matl_m,matl_f,c_f)
%MoriTanaka return matrix of homo modulus using Mori Tanaka method
  arguments
    matl_m (1,1) 
    matl_f (1,1) 
    c_f    (1,1) {double} 
  end

  % main program
  hill_m = matl_m.getHill;
  hill_f = matl_f.getHill;
  Lhomo  = Moritanaka_Transverse_Hill_2_Phase(hill_m, hill_f, c_f);
end

function Lhomo = Moritanaka_Transverse_Hill_2_Phase(hill_m,hill_f,c_f)

  k_m = hill_m(1);   k_f = hill_f(1);
  l_m = hill_m(2);   l_f = hill_f(2);
  n_m = hill_m(3);   n_f = hill_f(3);
  m_m = hill_m(4);   m_f = hill_f(4);
  p_m = hill_m(5);   p_f = hill_f(5);

  c_m = 1-c_f;

  % calculate homogenerous properties
  k = ( c_f*k_f*(k_m+m_m) + c_m*k_m*(k_f+m_m) ) ...
      / ( c_f*(k_m+m_m) + c_m*(k_f+m_m) );

  l = ( c_f*l_f*(k_m+m_m) + c_m*l_m*(k_f+m_m) ) ...
      / ( c_f*(k_m+m_m) + c_m*(k_f+m_m) );
  
  if k_m==k_f % k_m - k_f at the denominator
    n = c_f*n_f + c_m*n_m;
  else
    n = c_f*n_f + c_m*n_m ...
      + (l-c_f*l_f - c_m*l_m) * (l_f-l_m) / (k_f-k_m);
  end

  m = ( m_f*m_m*(k_m+2*m_m) + k_m*m_m*(c_f*m_f+c_m*m_m) ) ...
      / ( k_m*m_m + (k_m+2*m_m) * (c_f*m_m+c_m*m_f) );

  p = (2*c_f*p_f*p_m + c_m*(p_f*p_m+p_m^2)) ...
      / (2*c_f*p_m + c_m*(p_f+p_m));

  hill = [k l n m p];

  Lhomo = Material_Matrix_3d_Transverse_Hill(hill);
end

function L = Material_Matrix_3d_Transverse_Hill(hill)
%CalTransverseStiffnessMatrix3D calculate isotropic material matrix 
% from Hill constant
%   The fiber direction is 1 direction
  k = hill(1);
  l = hill(2);
  n = hill(3);
  m = hill(4);
  p = hill(5);

  L = zeros(6,6);
  L(1,1) = n;  L(1,2) = l;    L(1,3) = l; 
  L(2,1) = l;  L(2,2) = k+m;  L(2,3) = k-m; 
  L(3,1) = l;  L(3,2) = k-m;  L(3,3) = k+m;
    
  L(4,4) = m;  L(5,5) = p;    L(6,6) = p;
end

