classdef Isotropic
  %Isotropic isotropic elastic material
  properties
    E      (1,1) double = 0.0 % Young's modulus
    nu     (1,1) double = 0.0 % Poisson's ratio

    lambda (1,1) double = 0.0 % Lame modulus
    mu     (1,1) double = 0.0 % shear modulus

    type   (1,:) char   = ''
  end

  properties (Dependent)
    kappa  (1,1) double       % bulk modulus

    modl % elastic modulus matrix
    cmpl % elastic compliance matrix
  end
  
  methods
    function iso = Isotropic(problemType,prop,varargin)
      %Isotropic Construct an instance of this class
      % Input:
      %   type - 
      %     'solid3d' | 'pstress'

      % function input parser
      validType = @(x) any(validatestring(x, ...
                    {'solid3d', 'pstress', 'pstrain', 'axisymmetric'}));
      % input prop must be double array of length 2
      validProp = @(x) validateattributes(x, {'double'},{'numel', 2});
      default_paraName   = 'E&nu';
      expected_paraNames = {'E&nu', 'lambda&mu'};

      p = inputParser;
      addRequired( p,'type',validType);
      addRequired( p,'prop',validProp);
      addParameter(p,'paraName',default_paraName,...
                @(x) any(validatestring(x,expected_paraNames)));

      parse(p,problemType,prop,varargin{:});

      % assign property
      iso.type = p.Results.type;
      switch p.Results.paraName
        case 'E&nu'
          iso.E  = p.Results.prop(1);
          iso.nu = p.Results.prop(2);

          % check material stability
          if ~(iso.E>0 && -1<iso.nu && iso.nu<0.5)
            error('Isotropic:MaterialNOTStable',...
              'Material does NOT satisfy stability condition')
          end

          % cal lambda and mu from E and nu
          iso.lambda = (iso.E * iso.nu) / (1 + iso.nu) / (1 - 2*iso.nu);
          iso.mu     = iso.E / ( 1 + iso.nu) / 2;

        case 'lambda&mu'
          iso.lambda  = p.Results.prop(1);
          iso.mu      = p.Results.prop(2);

          % check material stability
          if ~(iso.lambda>0 && iso.mu>0)
            error('Isotropic:MaterialNOTStable',...
              'Material does NOT satisfy stability condition')
          end

          % cal E and nu from lambda and mu
          iso.E  = iso.mu * (3*iso.lambda + 2*iso.mu) / (iso.lambda + iso.mu);
          iso.nu = iso.lambda / (iso.lambda + iso.mu) / 2;
      end
    end

    function kappa = get.kappa(iso)
      %get.lambda Cal bulk modulus from E and nu
      %   Detailed explanation goes here
      kappa = iso.E / ( 1 - 2*iso.nu) / 3;
    end

    function modl = get.modl(iso)
      E0  = iso.E;
      nu0 = iso.nu;

      switch iso.type
        case 'solid3d'
          % 6x6 material matrix for isotropic elastic
          modl = zeros(6,6);
      
          modl(1,1) = (1-nu0); modl(1,3) = nu0;     modl(1,2) = nu0;
          modl(2,1) = nu0;     modl(2,2) = (1-nu0); modl(2,3) = nu0;
          modl(3,1) = nu0;     modl(3,2) = nu0;     modl(3,3) = (1-nu0);
        
          modl(4,4) = (1-2*nu0)/2;
          modl(5,5) = (1-2*nu0)/2;
          modl(6,6) = (1-2*nu0)/2;
        
          modl = E0/(1+nu0)/(1-2*nu0).*modl;
        case 'pstress'
          
        case 'pstrain'

        case 'axisymmetric'
      end

    end

    function cmpl = get.cmpl(iso)
      %elasticity calculate 6x6 Voigt material matrix for isotropic elastic
      E0  = iso.E;
      nu0 = iso.nu;
      switch iso.type
        case 'solid3d'
          % 6x6 material matrix for isotropic elastic
          cmpl = zeros(6,6);
          for i = 1:3
            for j = 1:3
              if i ~= j; cmpl(i,j) = -nu0 / E0; end
              if i == j; cmpl(i,j) =    1 / E0; end 
            end
          end
          for i = 4:6; cmpl(i,i) = 2*(1+nu0) / E0; end

        case 'pstress'

        case 'pstrain'

        case 'axisymmetric'
      end
    end
    
    function hill = getHill(iso)
      k = iso.lambda + iso.mu;
      l = iso.lambda;
      n = iso.lambda + 2*iso.mu;
      m = iso.mu;
      p = iso.mu;

      hill = [k l n m p];
    end
  end
end

