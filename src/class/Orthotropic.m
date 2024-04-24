classdef Orthotropic
  %Orthotropic Orthotropic elastic material
  
  properties
    % Engineering constants
    E_1   (1,1) double = 0.0
    E_2   (1,1) double = 0.0
    E_3   (1,1) double = 0.0
    nu_12 (1,1) double = 0.0
    nu_13 (1,1) double = 0.0
    nu_23 (1,1) double = 0.0
    G_12  (1,1) double = 0.0
    G_13  (1,1) double = 0.0
    G_23  (1,1) double = 0.0

    % derived from engineer const
    nu_21 (1,1) double
    nu_31 (1,1) double
    nu_32 (1,1) double
    G_21  (1,1) double
    G_31  (1,1) double
    G_32  (1,1) double

    % matrix terms
    c_11 (1,1) double = 0.0
    c_12 (1,1) double = 0.0
    c_22 (1,1) double = 0.0
    c_13 (1,1) double = 0.0
    c_23 (1,1) double = 0.0
    c_33 (1,1) double = 0.0
    c_44 (1,1) double = 0.0
    c_55 (1,1) double = 0.0
    c_66 (1,1) double = 0.0

    type  (1,:) char = ''
  end

  properties (Dependent)
    modl
    cmpl
  end
  
  methods
    function ortt = Orthotropic(type,prop,varargin)
      validType = @(x) any(validatestring(x, ...
                    {'solid3d'}));
      validProp = @(x) validateattributes(x, {'double'},{'numel', 9});
      defaultPara = 'engineering'; % default prop as engineering
      expectedParas = {'engineering', 'matrixTerm'};

      p = inputParser;
      addRequired( p,'type',validType);
      addRequired( p,'prop',validProp);
      addParameter(p,'paraName',defaultPara,...
                @(x) any(validatestring(x,expectedParas)));

      parse(p,type,prop,varargin{:});

      % assign property
      ortt.type = p.Results.type;
      switch p.Results.paraName
        case 'engineering'
          % assign value
          ortt.E_1   = p.Results.prop(1);
          ortt.E_2   = p.Results.prop(2);
          ortt.E_3   = p.Results.prop(3);
          ortt.nu_12 = p.Results.prop(4);
          ortt.nu_13 = p.Results.prop(5);
          ortt.nu_23 = p.Results.prop(6);
          ortt.G_12  = p.Results.prop(7);
          ortt.G_13  = p.Results.prop(8);
          ortt.G_23  = p.Results.prop(9);

          % derive other engineering constants
          ortt.nu_21 = ortt.nu_12 * ortt.E_2 / ortt.E_1;
          ortt.nu_31 = ortt.nu_13 * ortt.E_3 / ortt.E_1;
          ortt.nu_32 = ortt.nu_23 * ortt.E_3 / ortt.E_2;

          ortt.G_21  = ortt.G_12;
          ortt.G_31  = ortt.G_13;
          ortt.G_32  = ortt.G_23;

          delta = 1 - ortt.nu_12*ortt.nu_21 ...
                    - ortt.nu_13*ortt.nu_31 ...
                    - ortt.nu_23*ortt.nu_32 ...
                    - 2*ortt.nu_21*ortt.nu_32*ortt.nu_13;

          % check material stability
          cdtion_1 = all([ortt.E_1  ortt.E_2  ortt.E_3 ...
                          ortt.G_12 ortt.G_13 ortt.G_23] > 0);
          cdtion_2 = all([abs(ortt.nu_12) < sqrt(ortt.E_1/ortt.E_2) ...
                          abs(ortt.nu_13) < sqrt(ortt.E_1/ortt.E_3) ...
                          abs(ortt.nu_23) < sqrt(ortt.E_2/ortt.E_3)]);
          cdtion_3 = (delta>0);

          if ~all([cdtion_1 cdtion_2 cdtion_3])
            error('Orthotropic:MaterialNOTStable',...
              'Material does NOT satisfy stability condition')
          end
        
          % cal matrix terms from engineer const
          ortt.c_11 = ortt.E_1 * (1 - ortt.nu_23*ortt.nu_32) / delta;
          ortt.c_22 = ortt.E_2 * (1 - ortt.nu_13*ortt.nu_31) / delta;
          ortt.c_33 = ortt.E_3 * (1 - ortt.nu_12*ortt.nu_21) / delta;
          
          ortt.c_12 = ortt.E_1 * (ortt.nu_21 + ortt.nu_31*ortt.nu_23) / delta;
          ortt.c_13 = ortt.E_1 * (ortt.nu_31 + ortt.nu_21*ortt.nu_32) / delta;
          ortt.c_23 = ortt.E_2 * (ortt.nu_32 + ortt.nu_12*ortt.nu_31) / delta;

          ortt.c_44 = ortt.G_23;
          ortt.c_55 = ortt.G_13;
          ortt.c_66 = ortt.G_12;

        case 'matrixTerm'
          % assign value
          ortt.c_11 = p.Results.prop(1);
          ortt.c_12 = p.Results.prop(2);
          ortt.c_22 = p.Results.prop(3);
          ortt.c_13 = p.Results.prop(4);
          ortt.c_23 = p.Results.prop(5);
          ortt.c_33 = p.Results.prop(6);
          ortt.c_44 = p.Results.prop(7);
          ortt.c_55 = p.Results.prop(8);
          ortt.c_66 = p.Results.prop(9);

          % derive other engineering constants
          ortt.nu_21 = ortt.nu_12 * ortt.E_2 / ortt.E_1;
          ortt.nu_31 = ortt.nu_13 * ortt.E_3 / ortt.E_1;
          ortt.nu_32 = ortt.nu_23 * ortt.E_3 / ortt.E_2;

          ortt.G_21  = ortt.G_12;
          ortt.G_31  = ortt.G_13;
          ortt.G_32  = ortt.G_23;

          detC3 =     ortt.c_11 * ortt.c_22 * ortt.c_33 ...
                  + 2*ortt.c_12 * ortt.c_23 * ortt.c_13 ...
                  - ortt.c_11 * ortt.c_23^2 ...
                  - ortt.c_22 * ortt.c_13^2 ...
                  - ortt.c_33 * ortt.c_12^2;

          detC23 = ortt.c_22 * ortt.c_33 - ortt.c_23^2;
          detC13 = ortt.c_11 * ortt.c_33 - ortt.c_13^2;
          detC12 = ortt.c_11 * ortt.c_22 - ortt.c_12^2;
          
          % check material stability
          cdtion_1 = all([ortt.c_11 ortt.c_22 ortt.c_33 ...
                          ortt.c_44 ortt.c_55 ortt.c_66] > 0);
          cdtion_2 = all([detC23 detC13 detC12] > 0);
          cdtion_3 = (detC3>0);

          if ~all([cdtion_1 cdtion_2 cdtion_3])
            error('Orthotropic:MaterialNOTStable',...
              'Material does NOT satisfy stability condition')
          end
        
          % cal engineer const from matrix terms
          ortt.E_1 = detC3 / detC23;
          ortt.E_2 = detC3 / detC13;
          ortt.E_3 = detC3 / detC12;

          ortt.nu_12 = (ortt.c_12*ortt.c_33 - ortt.c_13*ortt.c_23) / detC23;
          ortt.nu_21 = (ortt.c_12*ortt.c_33 - ortt.c_13*ortt.c_23) / detC13;
          ortt.nu_13 = (ortt.c_22*ortt.c_13 - ortt.c_12*ortt.c_23) / detC23;
          ortt.nu_31 = (ortt.c_22*ortt.c_13 - ortt.c_12*ortt.c_23) / detC12;
          ortt.nu_23 = (ortt.c_11*ortt.c_23 - ortt.c_12*ortt.c_13) / detC13;
          ortt.nu_32 = (ortt.c_11*ortt.c_23 - ortt.c_12*ortt.c_13) / detC12;

          ortt.G_23 = ortt.c_44; ortt.G_32 = ortt.c_44;
          ortt.G_13 = ortt.c_55; ortt.G_31 = ortt.c_55;
          ortt.G_12 = ortt.c_66; ortt.G_21 = ortt.c_66;
      end
    end
    
    function modl = get.modl(ortt)
    % calculate 6x6 material stiffness matrix for orthogonal elastic
      modl = zeros(6,6);
    
      modl(1,1) = ortt.c_11; modl(1,2) = ortt.c_12; modl(1,3) = ortt.c_13;
      modl(2,1) = ortt.c_12; modl(2,2) = ortt.c_22; modl(2,3) = ortt.c_23;
      modl(3,1) = ortt.c_13; modl(3,2) = ortt.c_23; modl(3,3) = ortt.c_33;
    
      modl(4,4) = ortt.c_44;
      modl(5,5) = ortt.c_55;
      modl(6,6) = ortt.c_66;
    end

    function cmpl = get.cmpl(ortt)
    % calculate 6x6 material compliance matrix for orthogonal elastic
      cmpl = zeros(6,6);
    
      cmpl(1,1) = 1/ortt.E_1; cmpl(2,2) = 1/ortt.E_2; cmpl(3,3) = 1/ortt.E_3;
      cmpl(2,3) = -ortt.nu_32/ortt.E_3;
      cmpl(1,3) = -ortt.nu_31/ortt.E_3;
      cmpl(1,2) = -ortt.nu_21/ortt.E_2; 
      
      cmpl(3,2) = cmpl(2,3); cmpl(3,1) = cmpl(1,3); cmpl(2,1) = cmpl(1,2); 
    
      cmpl(4,4) = 1/ortt.G_23;
      cmpl(5,5) = 1/ortt.G_13;
      cmpl(6,6) = 1/ortt.G_12;
    end

  end
end

