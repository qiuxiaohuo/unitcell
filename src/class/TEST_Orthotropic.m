classdef TEST_Orthotropic < matlab.unittest.TestCase
  
  methods(TestClassSetup)
    % Shared setup for the entire test class
  end
  
  methods(TestMethodSetup)
    % Setup for each test
  end
  
  methods(Test)
    % Test 1: form class from engineer constant
    function Form_Class_From_EG(testCase)
      prop_eg = [ 1000. 1000. 1000. ...
                     0.    0.    0.1 ...
                   100.  100.  100.];
      orrt = Orthotropic('solid3d',prop_eg);

      actualSolu = [orrt.c_11 orrt.c_12 orrt.c_22 ...
                    orrt.c_13 orrt.c_23 orrt.c_33 ...
                    orrt.c_66 orrt.c_55 orrt.c_44];
      expectSolu = [ 1000.   0.   1010.1 ...
                        0. 101.01 1010.1 ...
                      100. 100.    100.];

      testCase.verifyEqual(actualSolu, expectSolu, 'Abstol',0.01);
    end

    % Test 2: form class from matrix terms
    function Form_Class_From_MT(testCase)
      prop_mt = [  1000.   0.   1010.1 ...
                      0. 101.01 1010.1 ...
                    100. 100.    100.];
      orrt = Orthotropic('solid3d',prop_mt,'paraName','matrixTerm');

      actualSolu = [orrt.E_1   orrt.E_2   orrt.E_3 ...
                    orrt.nu_12 orrt.nu_13 orrt.nu_23 ...
                    orrt.G_12  orrt.G_13  orrt.G_23];
      
      expectSolu = [ 1000. 1000. 1000. ...
                        0.    0.    0.1 ...
                      100.  100.  100.];

      testCase.verifyEqual(actualSolu, expectSolu, 'Abstol',0.01);
    end

    % Test 3: material stable check
    function Material_Stable_Check(testCase)
      prop_eg_not_stable = [  1000. 1000. 1000. ...
                                 1.    0.    0.1 ...
                               100.  100.  100.];
      testCase.verifyError( ...
                @()Orthotropic('solid3d',prop_eg_not_stable), ...
                'Orthotropic:MaterialNOTStable')
    end

    % Test 4: numuber of prop must be 9
    function Input_Prop_Numel(testCase)
      prop_eg_10_elem = [  1000. 1000. 1000.  ...
                                 1.    0.    0.1 ...
                               100.  100.  100.  ...
                               999.];
      testCase.verifyError( ...
                @()Orthotropic('solid3d',prop_eg_10_elem), ...
                'MATLAB:incorrectNumel')
    end

    % Test 5: Hill paras
    function CalHill(testCase)
      prop_eg = [250. 250. 250. 0.25 0.25 0.25 100. 100. 100.];
      ortt = Orthotropic('solid3d',prop_eg);
      actualSolu = ortt.getHill;
      expectSolu = [200. 100. 300. 100. 100.];
      testCase.verifyEqual(actualSolu, expectSolu, 'Abstol',0.01);
    end
  end
end