function avgf = avgptt(field,node,elem,tag)
%avgptt Return field volume average of given physical tag
% Input
%   field - field varible, index by row
%     vector | matrix

  V = 0;
  avgf = zeros(size(field(1,:)));

  for ielem = 1:elem.NELEM
    elemPhystag = elem.physTag(ielem);
    if elemPhystag == tag
      cnnt = elem.EToV(ielem,:);
      elemType = elem.Etype(ielem);

      Vi = elemv(elemType, node(cnnt,:));
      avgf = avgf + field(ielem,:)*Vi;
      V = V + Vi;
    end
  end

  if V~=0
    avgf = avgf/V;
  end
end