function PrintMeshInfo(info, fID)
  switch nargin
    case 2 % file print
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
      
    case 1 % screen print
      strline = "Succeed in reading mesh info from Gmsh file!\n";
      fprintf(strline);
      strline = "Total number of nodes is %d\n";
      fprintf(strline,info.nNode);
      strline = "Total number of  Dofs is %d\n";
      fprintf(strline,info.nDof);
      strline = "Total number of elems is %d\n";
      fprintf(strline,info.nElem);

    otherwise
      error('The number of input variables does NOT match!')
  end

end