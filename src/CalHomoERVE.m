function [enginC] = CalHomoERVE(e0, e1, s0, s1)
%CalHomoERVE Summary of this function goes here
%   Detailed explanation goes here

  % 1. solve compliance 6x6 matrix
  S = zeros(6);
  
  f0 = formFactor(s0); f1 = formFactor(s1);       % 3x6 factor of variable S_ij
  voiS = inv([f0; f1]) * [e0(1:3); e1(1:3)];

  S(1:3,1:3) = mapVoigt2Matrix(voiS);
  S(4,4) = e0(4)/s0(4); S(5,5) = e0(5)/s0(5); S(6,6) = e0(6)/s0(6); 

  % 2. solve enginner constants from S
  enginC = CalEnginConstFromS(S);
end

function f = formFactor(s)
  f = zeros(3,6);

  f(1,1) = s(1); f(1,5) = s(3); f(1,6) = s(2);
  f(2,2) = s(2); f(2,4) = s(3); f(2,6) = s(1);
  f(3,3) = s(3); f(3,4) = s(2); f(3,5) = s(1);
end