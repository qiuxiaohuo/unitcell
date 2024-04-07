function PrintMaterialConsts(E_f,nu_f,E_m,nu_m,c_f,fID,isPrint)
%PrintMaterialConsts Summary of this function goes here
%   Detailed explanation goes here
  % print fiber material consts
  strline = "The material consts of fiber  is: %8.3f, %8.3f\n";
  if isPrint, fprintf(strline,E_f,nu_f); end
  fprintf(fID,strline,E_f,nu_f);

  % print matrix material consts
  strline = "The material consts of matrix is: %8.3f, %8.3f\n";
  if isPrint, fprintf(strline,E_m,nu_m); end
  fprintf(fID,strline,E_m,nu_m);

  % print volume fraction of fiber
  strline = "The volume fraction of fiber  is: %8.3f\n";
  if isPrint, fprintf(strline,c_f); end
  fprintf(fID,strline,c_f);

  fprintf(fID,"\n");
end