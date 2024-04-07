function enginC = CalEnginConstFromS(S)
  enginC.E1 = 1/S(1,1); enginC.E2 = 1/S(2,2); enginC.E3 = 1/S(3,3);

  enginC.nu12 = -S(1,2)/S(1,1); 
  enginC.nu13 = -S(1,3)/S(1,1); 
  enginC.nu23 = -S(2,3)/S(2,2); 

  enginC.mu23 = 1/S(4,4);
  enginC.mu13 = 1/S(5,5);
  enginC.mu12 = 1/S(6,6);
end