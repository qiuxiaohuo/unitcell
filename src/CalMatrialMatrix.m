function L = CalMatrialMatrix(E, nu)
%CalMatrialMatrix calculate 6x6 Voigt material matrix for isotropic elastic

  L = zeros(6,6);

  L(1,1) = (1-nu); L(1,3) = nu;     L(1,2) = nu;
  L(2,1) = nu;     L(2,2) = (1-nu); L(2,3) = nu;
  L(3,1) = nu;     L(3,2) = nu;     L(3,3) = (1-nu);

  L(4,4) = (1-2*nu)/2;
  L(5,5) = (1-2*nu)/2;
  L(6,6) = (1-2*nu)/2;

  L = E/(1+nu)/(1-2*nu).*L;
end