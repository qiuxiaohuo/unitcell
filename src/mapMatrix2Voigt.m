function [voiArg] = mapMatrix2Voigt(matArg,charType)
%mapVoigt2Matrix mapping Voigt notation 6x1 array to 3x3 matrix
%   Detailed explanation goes here

  arguments
    matArg   (3,3) {mustSymmetric}
    charType (1,:) char = 'stress'
  end

  switch charType
    case 'stress'
      voiArg = zeros(6,1);

      % diagnal part
      voiArg(1) = matArg(1,1); voiArg(2) = matArg(2,2); voiArg(3) = matArg(3,3);
    
      % symmetric deviatoric part
      voiArg(4) = matArg(2,3);
      voiArg(5) = matArg(1,3);
      voiArg(6) = matArg(1,2);
    case 'strain'
      voiArg = zeros(6,1);

      % diagnal part
      voiArg(1) = matArg(1,1); voiArg(2) = matArg(2,2); voiArg(3) = matArg(3,3);
    
      % symmetric deviatoric part
      voiArg(4) = 2*matArg(2,3);
      voiArg(5) = 2*matArg(1,3);
      voiArg(6) = 2*matArg(1,2);
    otherwise
      error("The second argument must be strain!")
  end
end

% Custom validation function
function mustSymmetric(matArg)
  if ~isequal(matArg(2,3),matArg(3,2)) || ~isequal(matArg(1,3),matArg(3,1)) || ...
     ~isequal(matArg(1,2),matArg(2,1)) 

    msg = 'Input matrix is NOT symmetric.';
    error(msg)
  end
end