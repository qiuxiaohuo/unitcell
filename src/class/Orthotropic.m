classdef Orthotropic
  %Orthotropic Orthotropic elastic material
  
  % Engineering constants
  properties
    E_1   (1,1) double = 0.0
    E_2   (1,1) double = 0.0
    E_3   (1,1) double = 0.0
    nu_12 (1,1) double = 0.0
    nu_13 (1,1) double = 0.0
    nu_23 (1,1) double = 0.0
    G_12  (1,1) double = 0.0
    G_13  (1,1) double = 0.0
    G_23  (1,1) double = 0.0
  end

  % 
  properties
    D_1111 (1,1) double = 0.0
    D_1122 (1,1) double = 0.0
    D_2222 (1,1) double = 0.0
    D_1133 (1,1) double = 0.0
    D_2233 (1,1) double = 0.0
    D_3333 (1,1) double = 0.0
    D_2323 (1,1) double = 0.0
    D_1313 (1,1) double = 0.0
    D_1212 (1,1) double = 0.0
  end

  properties (Dependent)
    modl % elastic modulus matrix
    cmpl % elastic compliance matrix
  end
  
  methods
    function trans_iso_3d = TransIsotropic3D(E_a,E_t,G_at,nu_at,nu_t)
      if nargin > 0
        trans_iso_3d.E_a   = E_a  ;
        trans_iso_3d.E_t   = E_t  ;
        trans_iso_3d.G_at  = G_at ;
        trans_iso_3d.nu_at = nu_at;
        trans_iso_3d.nu_t  = nu_t ;
      end

      % check material stability

    end
    
    function lambda = get.lambda(iso3d)
      %get.lambda Cal Lame Modulus from E and nu
      %   Detailed explanation goes here
      lambda = iso3d.E_1 * iso3d.nu;
      lambda = lambda/(1 + iso3d.nu);
      lambda = lambda/(1 - 2*iso3d.nu);
    end

    function mu = get.mu(iso3d)
      %get.lambda Cal shear modulus from E and nu
      %   Detailed explanation goes here
      mu = iso3d.E_1 / ( 1 + iso3d.nu);
      mu = mu/2;
    end

    function kappa = get.kappa(iso3d)
      %get.lambda Cal bulk modulus from E and nu
      %   Detailed explanation goes here
      kappa = iso3d.E_1 / ( 1 - 2*iso3d.nu);
      kappa = kappa/3;
    end

    function modl = get.modl(iso3d)
      %elasticity calculate 6x6 Voigt material matrix for isotropic elastic
      E0  = iso3d.E_1;
      nu0 = iso3d.nu;

      modl = zeros(6,6);
    
      modl(1,1) = (1-nu0); modl(1,3) = nu0;     modl(1,2) = nu0;
      modl(2,1) = nu0;     modl(2,2) = (1-nu0); modl(2,3) = nu0;
      modl(3,1) = nu0;     modl(3,2) = nu0;     modl(3,3) = (1-nu0);
    
      modl(4,4) = (1-2*nu0)/2;
      modl(5,5) = (1-2*nu0)/2;
      modl(6,6) = (1-2*nu0)/2;
    
      modl = E0/(1+nu0)/(1-2*nu0).*modl;
    end

    function cmpl = get.cmpl(iso3d)
      %elasticity calculate 6x6 Voigt material matrix for isotropic elastic
      E0  = iso3d.E_1;
      nu0 = iso3d.nu;

      cmpl = zeros(6,6);
    
      for i = 1:3
        for j = 1:3
          if i ~= j; cmpl(i,j) = -nu0; end
          if i == j; cmpl(i,j) = 1;    end 
        end
      end

      for i = 4:6
        cmpl(i,i) = 2*(1+nu0);
      end

      cmpl = 1/E0 .* cmpl;
    end

  end
end

