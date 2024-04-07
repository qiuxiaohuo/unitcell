function PrintInfo(info, fID, isPrint)

  strline = "Succeed in reading mesh info from Gmsh file!\n";
  if isPrint, fprintf(strline); end
  fprintf(fID,strline);

  strline = "Total number of nodes is %d\n";
  if isPrint, fprintf(strline,info.nNode); end
  fprintf(fID,strline,info.nNode);

  strline = "Total number of  Dofs is %d\n";
  if isPrint, fprintf(strline,info.nDof); end
  fprintf(fID,strline,info.nDof);

  strline = "Total number of elems is %d\n";
  if isPrint, fprintf(strline,info.nElem); end
  fprintf(fID,strline,info.nElem);

  fprintf(fID,"\n");
end