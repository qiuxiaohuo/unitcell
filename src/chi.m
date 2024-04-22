function chi_field = chi(VE, tag)
%chi Identity field on desired domain
%   Detailed explanation goes here
  chi_field = zeros(VE.NELEM,1);
  for i_elem = 1:VE.NELEM
    if VE.physTag(i_elem) == tag
      chi_field(i_elem) = 1;
    end
  end
end