tol = 0.1;      //tolerance
$fn=200;

bladeNumber = 8;
camOuterRadius = 44;
baseOuterRadius = 40;
innerRadius = 15;
trackRadius = sqrt(  pow(baseOuterRadius,2) / 
                  ( 1+4*pow(tan(180/bladeNumber),2) ) 
                  );
layerThickness = 3;

*animate();
print();


module animate() {

    translate([0,0,-tol])
    color( "lightGrey", 1)
        base( camOuterRadius, baseOuterRadius-tol, trackRadius, innerRadius, layerThickness, bladeNumber);

    rotate([0,0,90/bladeNumber*(sin(360*$t)+1)])
    color( "goldenrod", .5) 
        diskCam( camOuterRadius, baseOuterRadius+tol, trackRadius, innerRadius, layerThickness, bladeNumber);

    color( "blue", .8)
        blades( trackRadius, bladeNumber, layerThickness);
}

module print() {

    translate([ camOuterRadius, 0, 0 ])
        base( camOuterRadius, baseOuterRadius-tol, trackRadius, innerRadius, layerThickness, bladeNumber);

    translate([ -camOuterRadius, 0, layerThickness*4 ])
    rotate([ 180, 0, 0 ])
        diskCam( camOuterRadius, baseOuterRadius+tol, trackRadius, innerRadius, layerThickness, bladeNumber);

    translate([ 0, -camOuterRadius, trackRadius+layerThickness/2 ])
    rotate([ 0, 90, -90 ])
        blade( trackRadius, bladeNumber, layerThickness);
}


module base(o, m, b, i, h, n) {
    //outer radius, blade height, number of blades, base height
    
    difference() {
        wheel();
        track();
    }
    
    module wheel() {
        difference() {
            union() {
            cylinder(h-tol, r=o);
            translate([0,0,tol/2])
            cylinder(h*2-tol, r=m);
            }
            translate([ 0, 0, -tol/2])
                cylinder( h*2+tol, r=i);
        }
    }    
    
    module track() {
        l = (2*b+h) * tan(180/n);
        for ( j = [ 1 : n ]) {
            rotate ([ 0, 0, j*360/n ])
            translate([ b, 0, h*1.5 ])
            cube([ h, l, h+tol ], true);
        }
    }
}


module diskCam(o, m, t, i, h, n) {
    // outer radius, middle radius, track radius, inner radius, height, number of blades
   
    difference() {
        translate( [0, 0, h] )
            cylinder( h*3, r=o);
        translate( [ 0, 0, -tol/2] )
            cylinder( h*3+tol, r=m );
        translate( [ 0, 0, h*3-tol/2] )
            cylinder( h+tol, r=i );
        translate( [ 0, 0, h*3] )
            holes();
    }
    
    module holes() {
        p=t/cos(180/n)-t;
        for ( j = [ 1 : n ]) {
            rotate ([ 0, 0, j*360/n+180/n ])
                translate([t, 0, -tol/2])
                cylinder(h+tol, r=2*PI*t/n/4);
            rotate ([ 0, 0, j*360/n ])
                translate( [ t+p/2, 0, 0] )
                minkowski() {
                    cube([ p, tol, tol], true);
                    cylinder(h, d=h);
                }
        }
    }
}

module blades(h, n, t) {
    for ( i = [ 1 : n ]) {
        rotate ([ 0, 0, i*360/n ])
        translate( [ 0, h*tan(90/n*(sin(360*$t)+1)), 2*t ])
        blade(h, n, t);
    }
}

module blade(h, n, t) {
    x =  h + t/2 - tol;
    y = x * tan(180/n);
    x2 = x - y/4/tan(180/n);

        polyhedron
            (points = [ [0,0,0], [x,-y,0], [x,y/2,0], [x2,y*3/4,0],
                        [0,0,t], [x,-y,t], [x,y/2,t], [x2,y*3/4,t] ],
              faces = [ [0,1,2,3], [4,7,6,5],
                        [0,4,5,1], [1,5,6,2], [2,6,7,3], [3,7,4,0] ] );
        translate([h-tol/2,0,0])
            cube([ t-tol, t-tol, (t-tol)*2], true);
        translate([h-tol/2,0,0])
            cylinder(t*2, d=t-tol);
}
