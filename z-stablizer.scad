use <rod-clamp.scad>
include <MCAD/nuts_and_bolts.scad>

// exportRodClamp=true;
exportHolder=true;

distanceX=35;
distanceY=40;
bearingD = 17.05;
zRodD = 8.05;
rodD=12.75;
thick=3.5;
screw=3;
rodClampLength=20;

nutThick = METRIC_NUT_THICKNESS[screw];
nutWidth = METRIC_NUT_AC_WIDTHS[screw];
zr=zRodD/2+thick;
rr=rodD/2+thick;
br=bearingD/2+thick;
height=nutThick*thick;
clampHoleOffset=2.5;

$fs=0.05;

pos=[
    [0,distanceY/2-rr,height/2],
    [-distanceX/2,-distanceY/2,height/2],
    [distanceX/2,-distanceY/2,height/2]
];

module plateShape() {
    hull() {
        //rod clamp base
        translate(pos[0]) cube(size=[rodClampLength,rr*2,height],center=true);
        //z rod clamp pos
        translate(pos[1]) cylinder(r=zRodD/2,h=height,center=true);
        //z thread clamp pos
        translate(pos[2]) cylinder(r=zRodD/2,h=height,center=true);
    }
}

module plate() {
    difference() {
        plateShape();
        //plate hole
        translate([0,0,-0.05]) scale([0.5,0.5,1.1]) plateShape();
        translate(pos[0]+[0,rr-screw/2-clampHoleOffset,height/2-nutThick+0.1]) union() {
            //rod clamp screw and nut holes
            for(i=[-1,1]) {
                translate([i*rodClampLength/4,0,0]) union() {
                    translate([0,0,-height]) cylinder(r=screw/2,h=height*2);
                    nutHole(screw);
                }
            }
        }
    }
}

module holder() {
    difference() {
        plate();
        translate(pos[1]) cylinder(r=zRodD/2+0.05,h=height+0.1,center=true);
        translate(pos[2]) cylinder(r=bearingD/2+0.05,h=height+0.1,center=true);
    }
    //z rod clamp
    translate(pos[1]+[0,0,-height/2]) rotate([0,0,-90])
        clamp(zRodD,height,thick,1,5,1,clampHoleOffset,screw,nutWidth); 
    //z thread rod holder
    translate(pos[2]) difference() {
        cylinder(r=br,h=height,center=true);
        cylinder(r=bearingD/2-1,h=height+0.1,center=true);
        translate([0,0,thick]) cylinder(r=bearingD/2,h=height,center=true);
    }
}

module rodClamp() {
    clamp(rodD,rodClampLength,thick,1,5,2,clampHoleOffset,screw,0);
}

module assembly() {
    rotate([0,180,0]) {
        holder();
        //rod clamp
        translate([rodClampLength/2,distanceY/2+rr,-thick]) 
            rotate([90,0,-90]) 
                rodClamp();
    }
}

if(exportHolder)
    holder();
else if(exportRodClamp)
    rodClamp();
else
    assembly();



