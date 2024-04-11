function PrintCHomoAndEnginC(CHomo,fID,isPrint,msg)
%PrintCHomoAndEnginC Summary of this function goes here
%   Detailed explanation goes here
  % postprocess data
  CHomo(CHomo<1e-10) = 0;
  enginC = CalEnginConstFromS(inv(CHomo));

  % print message of method
  strline = strcat(msg,"\n");
  if isPrint, fprintf(strline); end
  fprintf(fID,strline);

  % print material matrix
  strline = "The Homogenilised material matrix is:\n";
  if isPrint, fprintf(strline); end
  fprintf(fID,strline);

  for i = 1:6
    strline = "%16.8E  %16.8E  %16.8E  %16.8E  %16.8E  %16.8E\n";
    if isPrint, fprintf(strline,CHomo(i,:)); end
    fprintf(fID,strline,CHomo(i,:));
  end

  % print eigineering constants
  strline = "The eigneering constants are(calculated from material matrix):\n";
  if isPrint, fprintf(strline); end
  fprintf(fID,strline);

  strline = "E1   = %16.8E;  E2   = %16.8E;  E3   = %16.8E;\n";
  if isPrint, fprintf(strline,enginC.E1,enginC.E2,enginC.E3); end
  fprintf(fID,strline,enginC.E1,enginC.E2,enginC.E3);

  strline = "nu12 = %16.8E;  nu13 = %16.8E;  nu23 = %16.8E;\n";
  if isPrint, fprintf(strline,enginC.nu12,enginC.nu13,enginC.nu23); end
  fprintf(fID,strline,enginC.nu12,enginC.nu13,enginC.nu23);

  strline = "mu12 = %16.8E;  mu13 = %16.8E;  mu23 = %16.8E;\n";
  if isPrint, fprintf(strline,enginC.mu12,enginC.mu13,enginC.mu23); end
  fprintf(fID,strline,enginC.mu12,enginC.mu13,enginC.mu23);

  fprintf(fID,"\n");

end