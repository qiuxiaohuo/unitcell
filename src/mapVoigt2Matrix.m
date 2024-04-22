function [matArg] = mapVoigt2Matrix(voiArg,charType)
%mapVoigt2Matrix mapping Voigt notation 6x1 array to 3x3 matrix
%   Detailed explanation goes here

  arguments
    voiArg   (6,1) double
    charType (1,:) char = 'stress'
  end

  % Function code
  switch charType
    case 'stress'
      matArg = zeros(3);

      % diagnal part
      matArg(1,1) = voiArg(1); matArg(2,2) = voiArg(2); matArg(3,3) = voiArg(3);
    
      % symmetric deviatoric part
      matArg(2,3) = voiArg(4); matArg(3,2) = matArg(2,3); 
      matArg(1,3) = voiArg(5); matArg(3,1) = matArg(1,3);
      matArg(1,2) = voiArg(6); matArg(2,1) = matArg(1,2);
    case 'strain'
      matArg = zeros(3);

      % diagnal part
      matArg(1,1) = voiArg(1); matArg(2,2) = voiArg(2); matArg(3,3) = voiArg(3);
    
      % symmetric deviatoric part
      matArg(2,3) = 0.5*voiArg(4); matArg(3,2) = matArg(2,3); 
      matArg(1,3) = 0.5*voiArg(5); matArg(3,1) = matArg(1,3);
      matArg(1,2) = 0.5*voiArg(6); matArg(2,1) = matArg(1,2);
    otherwise
      error("The second argument must be strain!")
  end
end