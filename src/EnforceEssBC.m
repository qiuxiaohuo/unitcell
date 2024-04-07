function [K,f] = EnforceEssBC(K, f, essDof, essVal)
% Enforce essential boundary conditions

  % keeping condition number of K
  factorK = trace(K)/size(K,1); 

  % modify f
  f = f - K(:,essDof)*essVal; f(essDof) = factorK*essVal;

  % render col and row to zeros, except entity on diagnal
  K(:,essDof) = 0; K(essDof,:) = 0;
  K(essDof,essDof) = factorK * speye(length(essDof));
end