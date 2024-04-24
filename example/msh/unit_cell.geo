SetFactory("OpenCASCADE");

//----------------- fiber volume fraction  -----------------------
vf = 0.267;
r  = Sqrt(vf/Pi);

//----------------- geometry of matrix and fiber -----------------
Box(1)      = {0, 0, 0, 1, 1, 1};                    // matrix
Cylinder(2) = {0, 0.5, 0.5, 1, 0, 0, r, 2*Pi}; // fiber

//----------------- delete intersected volume --------------------
v() = BooleanFragments{ Volume{1}; Delete; }{ Volume{2}; Delete; };

//----------------- select periodic surface   --------------------
eps = 0.001;
// x-plane
Sxmin() = Surface In BoundingBox{0-eps, 0-eps, 0-eps, 0+eps, 1+eps, 1+eps};
For i In {0:#Sxmin()-1}
  // Then we get the bounding box of each left surface
  bb() = BoundingBox Surface { Sxmin(i) };
  // We translate the bounding box to the right and look for surfaces inside it:
  Sxmax() = Surface In BoundingBox { bb(0)-eps+1, bb(1)-eps, bb(2)-eps,
                                     bb(3)+eps+1, bb(4)+eps, bb(5)+eps };
  // For all the matches, we compare the corresponding bounding boxes...
  For j In {0:#Sxmax()-1}
    bb2() = BoundingBox Surface { Sxmax(j) };
    bb2(0) -= 1;
    bb2(3) -= 1;
    // ...and if they match, we apply the periodicity constraint
    If(Fabs(bb2(0)-bb(0)) < eps && Fabs(bb2(1)-bb(1)) < eps &&
       Fabs(bb2(2)-bb(2)) < eps && Fabs(bb2(3)-bb(3)) < eps &&
       Fabs(bb2(4)-bb(4)) < eps && Fabs(bb2(5)-bb(5)) < eps)
      Periodic Surface {Sxmax(j)} = {Sxmin(i)} Translate {1,0,0};
    EndIf
  EndFor
EndFor

// y-plane
Symin() = Surface In BoundingBox{0-eps, 0-eps, 0-eps, 1+eps, 0+eps, 1+eps};
For i In {0:#Symin()-1}
  // Then we get the bounding box of each left surface
  bb() = BoundingBox Surface { Symin(i) };
  // We translate the bounding box to the right and look for surfaces inside it:
  Symax() = Surface In BoundingBox { bb(0)-eps, bb(1)-eps+1, bb(2)-eps,
                                     bb(3)+eps, bb(4)+eps+1, bb(5)+eps };
  // For all the matches, we compare the corresponding bounding boxes...
  For j In {0:#Symax()-1}
    bb2() = BoundingBox Surface { Symax(j) };
    bb2(1) -= 1;
    bb2(4) -= 1;
    // ...and if they match, we apply the periodicity constraint
    If(Fabs(bb2(0)-bb(0)) < eps && Fabs(bb2(1)-bb(1)) < eps &&
       Fabs(bb2(2)-bb(2)) < eps && Fabs(bb2(3)-bb(3)) < eps &&
       Fabs(bb2(4)-bb(4)) < eps && Fabs(bb2(5)-bb(5)) < eps)
      Periodic Surface {Symax(j)} = {Symin(i)} Translate {0,1,0};
    EndIf
  EndFor
EndFor

// z-plane
Szmin() = Surface In BoundingBox{0-eps, 0-eps, 0-eps, 1+eps, 1+eps, 0+eps};
For i In {0:#Szmin()-1}
  // Then we get the bounding box of each left surface
  bb() = BoundingBox Surface { Szmin(i) };
  // We translate the bounding box to the right and look for surfaces inside it:
  Szmax() = Surface In BoundingBox { bb(0)-eps, bb(1)-eps, bb(2)-eps+1,
                                     bb(3)+eps, bb(4)+eps, bb(5)+eps+1 };
  // For all the matches, we compare the corresponding bounding boxes...
  For j In {0:#Szmax()-1}
    bb2() = BoundingBox Surface { Szmax(j) };
    bb2(2) -= 1;
    bb2(5) -= 1;
    // ...and if they match, we apply the periodicity constraint
    If(Fabs(bb2(0)-bb(0)) < eps && Fabs(bb2(1)-bb(1)) < eps &&
       Fabs(bb2(2)-bb(2)) < eps && Fabs(bb2(3)-bb(3)) < eps &&
       Fabs(bb2(4)-bb(4)) < eps && Fabs(bb2(5)-bb(5)) < eps)
      Periodic Surface {Szmax(j)} = {Szmin(i)} Translate {0,0,1};
    EndIf
  EndFor
EndFor

Physical Volume("fiber") = {2};
Physical Volume("matrix")= {3};

sf = Surface In BoundingBox{0-eps, 0-eps, 0-eps, 0+eps, 1+eps, 1+eps};
Physical Surface("surf_back") = {sf, 10};
sf = Surface In BoundingBox{1-eps, 0-eps, 0-eps, 1+eps, 1+eps, 1+eps};
Physical Surface("surf_front") = {sf,15};
sf = Surface In BoundingBox{0-eps, 0-eps, 0-eps, 1+eps, 0+eps, 1+eps};
Physical Surface("surf_left") = {sf};
sf = Surface In BoundingBox{0-eps, 1-eps, 0-eps, 1+eps, 1+eps, 1+eps};
Physical Surface("surf_right") = {sf};
sf = Surface In BoundingBox{0-eps, 0-eps, 0-eps, 1+eps, 1+eps, 0+eps};
Physical Surface("surf_bottom") = {sf};
sf = Surface In BoundingBox{0-eps, 0-eps, 1-eps, 1+eps, 1+eps, 1+eps};
Physical Surface("surf_top") = {sf};

cv = Line In BoundingBox{1-eps, 0-eps, 0-eps, 1+eps, 0+eps, 1+eps};
Physical Line("line_left_front") = {cv};
cv = Line In BoundingBox{1-eps, 1-eps, 0-eps, 1+eps, 1+eps, 1+eps};
Physical Line("line_front_right") = {cv};
cv = Line In BoundingBox{1-eps, 0-eps, 0-eps, 1+eps, 1+eps, 0+eps};
Physical Line("line_bottom_front") = {cv};
cv = Line In BoundingBox{1-eps, 0-eps, 1-eps, 1+eps, 1+eps, 1+eps};
Physical Line("line_front_top") = {cv};
cv = Line In BoundingBox{0-eps, 1-eps, 1-eps, 1+eps, 1+eps, 1+eps};
Physical Line("line_right_top") = {cv};
cv = Line In BoundingBox{0-eps, 1-eps, 0-eps, 1+eps, 1+eps, 0+eps};
Physical Line("line_bottom_right") = {cv};

pt = Point In BoundingBox{0-eps, 0-eps, 0-eps, 0+eps, 0+eps, 0+eps};
Physical Point("u_o") = {pt};
pt = Point In BoundingBox{1-eps, 0-eps, 0-eps, 1+eps, 0+eps, 0+eps};
Physical Point("u_x") = {pt};
pt = Point In BoundingBox{0-eps, 1-eps, 0-eps, 0+eps, 1+eps, 0+eps};
Physical Point("u_y") = {pt};
pt = Point In BoundingBox{0-eps, 0-eps, 1-eps, 0+eps, 0+eps, 1+eps};
Physical Point("u_z") = {pt};

Mesh.MeshSizeMax = 0.2;
Mesh 3;
Save "unit_cell.msh";
