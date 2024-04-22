function avgf = avgptt(field,node,elem,tag)
%avgptt Return field volume average of given physical tag
% Input
%   field - field varible, index by row
%     vector | matrix
%   tag - physical tag for desired average domain, -1 will average 
%   on the whole domain
%     scalar(boolen | int)


  V = 0;
  avgf = zeros(size(field(1,:)));

  for ielem = 1:elem.NELEM
    elem_tag = elem.physTag(ielem);
    if tag == elem_tag || tag == -1
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