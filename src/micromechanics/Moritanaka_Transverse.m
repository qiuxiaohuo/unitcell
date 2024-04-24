function Lhomo = Moritanaka_Transverse(prop_m,prop_f,varargin)
%MoriTanaka return matrix of homo modulus using Mori Tanaka method

  % input parameter check
  defaultProperty = 'Hill';
  expectedProperties = {'Hill', 'Engineer'};
  defaultC        = 0.5;
  
  p = inputParser;
  validScalarPosNum = @(x) isnumeric(x) && isscalar(x) && (x > 0);
  addRequired( p,'prop_m');
  addRequired( p,'prop_f');
  addOptional( p,'c_f',defaultC,validScalarPosNum);
  addParameter(p,'property',defaultProperty,...
                @(x) any(validatestring(x,expectedProperties)));
  parse(p,prop_m,prop_f,varargin{:});

  % main program
  switch p.Results.property
    case 'Hill'
      Lhomo = Moritanaka_Transverse_Hill_2_Phase( ...
                p.Results.prop_m, p.Results.prop_f, p.Results.c_f);
    case 'Engineer'
      hill_m = eg2hill(p.Results.prop_m);
      hill_f = eg2hill(p.Results.prop_f);
      Lhomo = Moritanaka_Transverse_Hill_2_Phase( ...
                hill_m, hill_f, p.Results.c_f);
  end

end

function hill = eg2hill(eg)
%eg2hill transform engineering constant to Hill constant
% for transverse isotropic material with 1-direction as
% axis of symmetry
  E11  = eg.E_a;
  E22  = eg.E_t;
  G12  = eg.E_at;
  nu12 = eg.nu_at;
  nu23 = eg.nu_t;

  hill.k = ( 2*(1-nu23)/E22 - 4*nu12^2/E11 )^(-1);
  hill.l = 2*hill.k*nu12;
  hill.n = E11 + hill.l^2/hill.k;
  hill.m = E22/( 2*(1 + nu23) );
  hill.p = G12;

end

function Lhomo = Moritanaka_Transverse_Hill_2_Phase(hill_m,hill_f,c_f)

  k_m = hill_m.k;   k_f = hill_f.k;
  l_m = hill_m.l;   l_f = hill_f.l;
  n_m = hill_m.n;   n_f = hill_f.n;
  m_m = hill_m.m;   m_f = hill_f.m;
  p_m = hill_m.p;   p_f = hill_f.p;

  c_m = 1-c_f;

  % calculate homogenerous properties
  hill.k = (c_f*k_f*(k_m+m_m)+c_m*k_m*(k_f+m_m))/...
      (c_f*(k_m+m_m)+c_m*(k_f+m_m));

  hill.m = (m_f*m_m*(k_m+2*m_m)+k_m*m_m*(c_f*m_f+c_m*m_m))/...
      (k_m*m_m+(k_m+2*m_m)*(c_f*m_m+c_m*m_f));

  hill.p = (2*c_f*p_f*p_m+c_m*(p_f*p_m+p_m^2))/...
      (2*c_f*p_m+c_m*(p_f+p_m));

  hill.l = (c_f*l_f*(k_m+m_m)+c_m*l_m*(k_f+m_m))/...
      (c_f*(k_m+m_m)+c_m*(k_f+m_m));
  
  if k_m==k_f % k_m - k_f at the denominator
    hill.n = c_f*n_f+c_m*n_m;
  else
    hill.n = c_f*n_f+c_m*n_m +...
      (hill.l-c_f*l_f-c_m*l_m)*...
      (l_f-l_m)/(k_f-k_m);
  end

  Lhomo = Material_Matrix_3d_Transverse_Hill(hill);
end

function L = Material_Matrix_3d_Transverse_Hill(hill)
%CalTransverseStiffnessMatrix3D calculate isotropic material matrix 
% from Hill constant
%   The fiber direction is 1 direction
  k = hill.k;
  l = hill.l;
  n = hill.n;
  m = hill.m;
  p = hill.p;

  L = zeros(6,6);
  L(1,1) = n; 
  L(2,2) = k+m; L(3,3) = k+m;
  L(2,3) = k-m; L(3,2) = k-m;
  L(1,2) = l; L(1,3) = l; L(2,1) = l; L(3,1) = l;
  L(4,4) = m;
  L(5,5) = p; L(6,6) = p;
end

