function [C,g] = CalConstraintMatrix(info,Pair,vE0)
%CalConstraintMatrix Summary of this function goes here
%   Detailed explanation goes here
  % function info
  pairField = ['X' 'Y' 'Z'];
  mE0 = mapVoigt2Matrix(vE0,'strain');

  % loop field variable
  C = {}; g = {};
  for ifield = 1:3
    nodePair = Pair.(pairField(ifield));
    len = length(nodePair);                   % num of constraint equations
    ui = nodePair(1,1); uo = nodePair(1,2);   % reference nodeID, which is stored in 1st row
    Ci = zeros(info.nDim*len, info.nDof);     % intialize constraint matrix
    gi = zeros(info.nDim*len, 1);             % intialize val matrix, Cu = g

    %% 1. constraint ui
    for i = 1:info.nDim
      Ci(i,DofID3(ui,i)) = 1; gi(i) = mE0(i,ifield);
    end

    %% 2. fomulate all other nDim*(len-1) equations:
    % ui - uo = u(ipair,1)(slave) - u(ipair,2)(master), or
    % us - um + uo - ui = 0
    for ipair = 2:len
      us = nodePair(ipair,1); um = nodePair(ipair,2); 
      for idim = 1:info.nDim
        lID = DofID3(ipair,idim); % line ID of equations
        Ci(lID,DofID3(us,idim)) =  1; %  us
        Ci(lID,DofID3(um,idim)) = -1; % -um
        Ci(lID,DofID3(uo,idim)) = +1; % +uo
        Ci(lID,DofID3(ui,idim)) = -1; % -ui
      end
    end

    % store Ci,gi in cell C,g
    C{ifield} = Ci; g{ifield} = gi;
  end

  %% 3. constraint uo, reduce rigid deformation
  Ci = zeros(3, info.nDof); gi = zeros(3, 1);
  for i = 1:info.nDim
    Ci(i,DofID3(uo,i)) = 1;
  end
  C{4} = Ci; g{4} = gi;

  C = [C{1}; C{2}; C{3}; C{4}]; g = [g{1}; g{2}; g{3}; g{4}];
  
end