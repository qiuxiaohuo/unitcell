function PrintPairNode(Pair,fID,isPrint)
%PrintPair Summary of this function goes here
%   Detailed explanation goes here
  strline = "Succeed in creating Pairs from GMSH Periodic info!\n";
  if isPrint, fprintf(strline); end
  fprintf(fID,strline);

  strline = "Total number of Pairs: %d\n";
  if isPrint, fprintf(strline,Pair.N); end
  fprintf(fID,strline,Pair.N);

  % x direction pairs
  xNode = size(Pair.X,1);
  strline = "X direction Pairs: total number is %d\n";
  if isPrint, fprintf(strline,xNode); end
  fprintf(fID,strline,xNode);

  strline = "Slave nodes   Master nodes \n";
  if isPrint, fprintf(strline); end
  fprintf(fID,strline);

  for i = 1:xNode
    strline = "%d \t \t %d\n";
    if isPrint, fprintf(strline,Pair.X(i,1), Pair.X(i,2)); end
    fprintf(fID,strline,Pair.X(i,1), Pair.X(i,2));
  end

  % y direction pairs
  yNode = size(Pair.Y,1);
  strline = "Y direction Pairs: total number is %d\n";
  if isPrint, fprintf(strline,yNode); end
  fprintf(fID,strline,yNode);

  strline = "Slave nodes   Master nodes \n";
  if isPrint, fprintf(strline); end
  fprintf(fID,strline);

  for i = 1:yNode
    strline = "%d \t \t %d\n";
    if isPrint, fprintf(strline,Pair.Y(i,1), Pair.Y(i,2)); end
    fprintf(fID,strline,Pair.Y(i,1), Pair.Y(i,2));
  end

  % z direction pairs
  zNode = size(Pair.Z,1);
  strline = "Z direction Pairs: total number is %d\n";
  if isPrint, fprintf(strline,zNode); end
  fprintf(fID,strline,zNode);

  strline = "Slave nodes   Master nodes \n";
  if isPrint, fprintf(strline); end
  fprintf(fID,strline);

  for i = 1:zNode
    strline = "%d \t \t %d\n";
    if isPrint, fprintf(strline,Pair.Z(i,1), Pair.Z(i,2)); end
    fprintf(fID,strline,Pair.Z(i,1), Pair.Z(i,2));
  end

  fprintf(fID,"\n");
end