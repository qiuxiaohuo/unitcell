classdef Cal_Lhomo_Mori_Tanaka_TEST < matlab.unittest.TestCase
  properties (TestParameter)
    c_f = num2cell(0:0.1:1); % fraction of fiber
  end

  methods (TestClassSetup)
    % Shared setup for the entire test class
  end

  methods (TestMethodSetup)
    % Setup for each test
  end

  methods (Test)
    % Test methods

    function SameIsotropicMaterial(testCase,c_f)
      %% case1: matrix and fiber are the same isotropic material
      matl_iso = Isotropic('solid3d',[200.0 0.2]);
      
      actualSolu = Cal_Lhomo_Mori_Tanaka(matl_iso, matl_iso, c_f);
      expectSolu = matl_iso.modl;

      testCase.verifyEqual(actualSolu, expectSolu, 'Abstol',0.01);
    end

    function SameOrthotropicMaterial(testCase,c_f)
      %% case2: matrix and fiber are the same transverse-isotropic material
      prop_eg = [ 250.  100.  100.   ...
                    0.2   0.2   0.25 ...
                   50.   50.   40.];
      matl_ortt = Orthotropic('solid3d',prop_eg);
      
      actualSolu = Cal_Lhomo_Mori_Tanaka(matl_ortt, matl_ortt, c_f);
      expectSolu = matl_ortt.modl;

      testCase.verifyEqual(actualSolu, expectSolu, 'Abstol',0.01);
    end
  end

end