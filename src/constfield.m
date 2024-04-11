function fconst = constfield(const, n)
%Generate constant field for given degree
% For given constant(which might be a scale or vector) and number of degree
% duplicated case, z.B. number of nodes, number of element, expand const to
% the same size of field variables
% Input
%   const - constant of wanted
%     scale | vector | matrix
%   n - number of dupulicated cases
%     scale
% Output
%   fconst - field variables
%     scale | vector | matrix

%% preallocate fconst
[nr,nc] = size(const);
fconst = zeros(nr*n, nc);

%% set values
for i = 1:n
  fconst((i-1)*nr+1:i*nr,:) = const;
end
end