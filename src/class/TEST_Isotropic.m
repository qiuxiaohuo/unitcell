classdef TEST_Isotropic < matlab.unittest.TestCase
  properties (TestParameter)
    % obtained from https://www.omnicalculator.com/physics/elastic-constants
    E_nu_Props      = {[200.0   0.2] [100.0   0.3] [300.0   0.1]};
    lambda_mu_Props = {[55.56 83.33] [57.69 38.46] [34.09 136.4]};
    kappa_Props     = {[      111.1] [      83.33] [	    125.0]}
  end
  
  methods(TestClassSetup)
    % Shared setup for the entire test class
  end
  
  methods(TestMethodSetup)
    % Setup for each test
  end
  
  methods(Test, ParameterCombination = 'sequential')
    % Test 1: cal paras from E and nu
    function Regular_Input_Solu_E_nu(testCase, ...
        E_nu_Props,lambda_mu_Props,kappa_Props)

      iso = Isotropic('solid3d',E_nu_Props);
      testCase.verifyEqual([iso.lambda iso.mu], lambda_mu_Props, 'Abstol',0.1);
      testCase.verifyEqual( iso.kappa, kappa_Props, 'Abstol',0.1);
    end
    % Test 2: cal paras from lambda and mu
    function Regular_Input_Solu_l_mu(testCase, ...
        E_nu_Props,lambda_mu_Props,kappa_Props)

      iso = Isotropic('solid3d',lambda_mu_Props,'paraName','lambda&mu');
      testCase.verifyEqual([iso.E iso.nu], E_nu_Props, 'Abstol',0.1);
      testCase.verifyEqual( iso.kappa, kappa_Props, 'Abstol',0.1);
    end
  end

  methods(Test)
    % Test 3: material stable check
    function Material_Stable_Check(testCase)
      testCase.verifyError( ...
                @()Isotropic('solid3d',[-1  0.2]), ...
                'Isotropic:MaterialNOTStable')
      testCase.verifyError( ...
                @()Isotropic('solid3d',[200 -1]), ...
                'Isotropic:MaterialNOTStable')
      testCase.verifyError( ...
                @()Isotropic('solid3d',[200 0.5]), ...
                'Isotropic:MaterialNOTStable')
      testCase.verifyError( ...
                @()Isotropic('solid3d',[-200 -100]), ...
                'Isotropic:MaterialNOTStable')

      testCase.verifyError( ...
                @()Isotropic('solid3d',[-1  1],'paraName','lambda&mu'), ...
                'Isotropic:MaterialNOTStable')
      testCase.verifyError( ...
                @()Isotropic('solid3d',[ 1 -1],'paraName','lambda&mu'), ...
                'Isotropic:MaterialNOTStable')
      testCase.verifyError( ...
                @()Isotropic('solid3d',[-1 -1],'paraName','lambda&mu'), ...
                'Isotropic:MaterialNOTStable')
    end

    % Test 4: numuber of prop must be 2
    function Input_Prop_Numel(testCase)
      testCase.verifyError( ...
                @()Isotropic('solid3d',[200 0.2 83.33]), ...
                'MATLAB:incorrectNumel')
    end

    % Test 5: Hill paras
    function CalHill(testCase)
      iso = Isotropic('solid3d',[100.0 100.0],'paraName','lambda&mu');
      actualSolu = iso.getHill;
      expectSolu = [200. 100. 300. 100. 100.];
      testCase.verifyEqual(actualSolu, expectSolu, 'Abstol',0.01);
    end
  end
end