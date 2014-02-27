/***************************************************************************
    Portabee Z-endstop Fine Tuner OpenSCAD version
    Author: Realthunder (realthunder.dev@gmail.com)
    Derived from a desgin by JamesRX at http://www.thingiverse.com/thing:155175
    Modified for easy printing

    Licensed under the Creative Commons - Attribution - Share Alike license. 
****************************************************************************/
use <MCAD/involute_gears.scad>
include <MCAD/nuts_and_bolts.scad>

//////////////
//parameters
///////////////

//base structural height
height=12;
//base structural wall size
thick=2.5;
//z rod diameter
rodD=8;
//tuner screw size
screw=4; //m4
//distance btw the center of two screws on endstop board
boardScrewsDistance=19;
//endstop board screw size
boardScrew=3; //m3
//endstop board screw center x offset to the panel edge when laying flat
boardScrewOffset=4;
//endstop board screw center y offset to the panel edge when laying flat.
//this offset is set shorter so that the nut hole top wall is cut out for easy printing,
//and also to give clearance to the component solder leads.
boardScrewOffsetY=2.5;
//board center offset with regarding to z rod to accomandate for the micro switch position
boardOffset=2;
//tuner wheel teeth count
wheelTeeth=24;
//tuner screw locker teeth count
lockerTeeth=16;
//tuner block rod clamp screw offset
clampScrewOffset=8;

show_endstop=true;
show_tuner_screw=true;

//for explode view
explode=10;

//set to true for single component export
// holder_export=true;
// tuner_export=true;
// wheel_export=true;
// locker_export=true;

//////////////////////
//derived parameters
/////////////////////

//board panel length
boardLength=boardScrewsDistance+2*boardScrewOffset;
//base structural width (for both endstop holder and tuner block)
width = rodD+2*thick;
//endstop holder overall length
length = boardLength+2*thick+screw;
//x offset w.r.t. z rod center
offset = length-boardOffset-boardLength/2;
//endstop board screw x offset
boardScrewX = boardScrewsDistance/2;
//endstop board screw y offset (or z offset when viewed in 3d)
boardScrewY = height-boardScrewOffsetY;
//endstop board screw nut thickness (from MCAD/nuts_and_bolts.scad)
boardScrewThick = METRIC_NUT_THICKNESS[boardScrew];
//endstop board holder bottom panel thickness
panelThick = thick+ boardScrewThick -0.05;
//tuner screw nut thickness
screwThick = METRIC_NUT_THICKNESS[screw]-0.05;
//tuner screw nut width
screwWidth = METRIC_NUT_AC_WIDTHS[screw];
//tuner screw locker diameter
lockerD = screwWidth+4;
//tuner screw locker height
lockerHeight = 3+screwThick;
//tuner wheel diameter
wheelD = screwWidth+6;
//tuner wheel height
wheelHeight = 1.5+screwThick;
//tuner screw offset w.r.t. z rod
tunerScrewOffset = -offset+thick+screw/2;
//set scad resolution
$fs = 0.2;

module roundCorner(h,r) {
    difference() {
        translate([-r-0.1,-r-0.1,-0.1]) cube([r+0.1,r+0.1,h+0.2]);
        translate([0,0,-0.1]) cylinder(r=r,h=h+0.2);
    }
}   

module roundCorners(size,r,tl,tr,bl,br) {
    if(bl) translate([r,r,0]) roundCorner(size.z,r);
    if(br) translate([size.x-r,r,0]) rotate([0,0,90]) roundCorner(size.z,r);
    if(tr) translate([size.x-r,size.y-r,0]) rotate([0,0,180]) roundCorner(size.z,r);
    if(tl) translate([r,size.y-r,0]) rotate([0,0,270]) roundCorner(size.z,r);
}

module roundCube(size,center=false,r=1.5,tl=true,tr=true,bl=true,br=true) {
    difference() {
        cube(size=size,center=center);
        if(center) {
            translate(-size/2) roundCorners(size,r,tl,tr,bl,br);
        } else
            roundCorners(size,r,tl,tr,bl,br);
    }
}

module holder() {
    soffset=boardLength/2-boardOffset;
    difference() {
        union() {
            //rod holder
            cylinder(r=rodD/2+thick,h=height);
            //side panel
            translate([-soffset,width/2,0]) rotate([90,0,0]) roundCube([boardLength,height,panelThick],r=1);
            translate([-offset,-width/2,0]) union() {
                //bottom panel
                roundCube([offset,width,2*thick],br=false);
                //tuner screw holder
                roundCube([screw+thick*2,width,height],tr=false);
            }
        }
        //carve away a bit to make room for board screw
        translate([-soffset,width/2-4*thick,2*thick+0.05]) cube([boardLength/2-2,2*thick+0.2,height]);

        //drill a hole for rod
        translate([0,0,-0.1]) cylinder(r=rodD/2,h=height+0.2);

        //drill holes for board scews
        translate([boardOffset+boardScrewX,width/2+0.1,boardScrewY]) rotate([90,0,0]) union() {
            cylinder(r=boardScrew/2,h=thick+0.2);
            translate([0,0,thick+0.1]) nutHole(boardScrew);
            translate([-boardScrewX*2,0,0]) union() {
                 cylinder(r=boardScrew/2,h=thick+0.2);
                 translate([0,0,thick+0.1]) nutHole(boardScrew);
            }
        }
        
        //carve away a bit of the tuner screw holder to give space for stopper board pins
        translate([-offset-0.1,-width/2-0.1,height-boardScrewOffset]) cube([screw+thick*2+0.2,width+0.2,boardScrewOffset+0.1]);

        translate([tunerScrewOffset,0,-0.1]) union() {
            //drill hole for tuner screw
            cylinder(r=screw/2,h=height+0.2);
            //tuner screw nut socket
            rotate([0,0,30]) nutHole(screw);
        }
    }
}

module tuner() {
    f=clampScrewOffset;
    l=f+2*thick;
    difference() {
        union() {
            //rod holder
            cylinder(r=rodD/2+thick,h=height);
            //main body
            translate([-offset,-width/2,0]) roundCube([offset+l,width,height],tr=false,br=false);
        }

        //drill a hole for rod
        translate([0,0,-0.1]) cylinder(r=rodD/2,h=height+0.2);

        //slice some space for rod clamp
        translate([0,-width/2+thick,-0.1]) cube([l+0.1,width-3*thick,height+0.2]);
        translate([f,width/2+0.05,height/2]) rotate([90,0,0]) union() {
            //clamp screw hole
            cylinder(r=boardScrew/2,h=width+0.1);
            //rod clamp nut socket
            rotate([0,0,30]) nutHole(boardScrew);
        }

        translate([tunerScrewOffset,0,height/2]) union() {
            //drill hole for tuner screw
            cylinder(r=screw/2,h=height+0.2,center=true);
            //carve up space for tuner wheel
            cylinder(r=wheelD/2+2,height-2*thick,center=true);
        }
    }
}

//d: dameter, h: height, c: clearance, t: tolerance
module wheel(teeth,d,h,c,t=0.0001) {
    p = (teeth+2)/d;
    difference() {
        gear(teeth,clearance=c,pressure_angle=40,diametral_pitch=p,gear_thickness=h,
                rim_thickness=h,rim_width=5,hub_diameter=0,bore_diameter=screw);
        translate([0,0,h-screwThick+0.05]) nutHole(screw,tolerance=t);
    }
}

module screw(d,h=10) {
    r=d/2;
    translate([0,0,-d]) difference() {
        cylinder(r=r+1,h=d);
        translate([0,0,-0.1]) cylinder(r=r-0.5,h=d,$fn=6);
    }
    cylinder(r=r,h=h);
}

module washer(d) {
    r=d/2;
    w=METRIC_NUT_AC_WIDTHS[d];
    difference() {
        cylinder(r=w/2+0.5,h=1);
        translate([0,0,-0.1]) cylinder(r=r,h=1.2);
    }
}

module nut(d) {
    r=d/2;
    t=METRIC_NUT_THICKNESS[d];
    difference() {
        nutHole(d,tolerance=0.05);
        translate([0,0,-0.1]) cylinder(r=r,h=t+0.2);
    }
}

module micro_switch(l=15,w=5,h=5) {
    translate([-l/2,0,0]) union() {
        translate([0,0,-h]) cube(size=[l,w,h]);
        rotate([0,-15,0]) cube([l,w,0.5]);
    }
}

module endstop(l=35,w=12,h=1.5,show_screw=true) {
    d=boardScrewsDistance;
    r=boardScrew/2;
    difference() {
        translate([-l/2,-w/2,0]) cube(size=[l,w,h]);
        for(i=[-d/2,d/2])
            translate([i,w/2-r-2,-0.1]) cylinder(r=r,h=h+0.2);
    }
    translate([boardOffset,-w/2,h]) rotate([90,0,0]) micro_switch();
    if(show_screw) {
        for(i=[-d/2,d/2]) {
            translate([i,w/2-r-2,0]) union() {
                translate([0,0,2.2*explode+3]) rotate([0,180,0]) screw(boardScrew);
                translate([0,0,0.8*explode+2]) washer(boardScrew);
                translate([0,0,-0.5-explode*2.5-thick-boardScrewThick]) nut(boardScrew);
            }
        }
    }
}

module assembly() {
    translate([0,0,height+5+explode*0.6]) union() {
        if(show_endstop) 
            translate([boardOffset,width/2+explode,6-2-1.5+boardScrewY]) rotate([-90,0,0]) endstop();
        holder();
        if(show_tuner_screw) {
            translate([tunerScrewOffset,0,3.5*explode+height-boardScrewOffset]) rotate([0,180,0]) screw(screw,30);
            translate([tunerScrewOffset,0,1-0.8*explode]) rotate([0,0,30]) nut(screw);
        }
    }

    translate([0,0,height/2]) rotate([180,0,0]) translate([0,0,-height/2]) tuner();

    if(show_tuner_screw) {
        translate([clampScrewOffset,width/2+2*explode,height/2]) rotate([90,0,0]) screw(boardScrew,14);
        translate([clampScrewOffset,-width/2-explode-0.5,height/2]) rotate([-90,30,0]) nut(boardScrew);
        translate([tunerScrewOffset-explode,0,height-thick-1.2]) washer(screw);
        translate([tunerScrewOffset-explode,0,thick+0.2]) washer(screw);
    }

    //tuner wheel
    translate([tunerScrewOffset-2.5*explode,0,height/2-wheelHeight/2]) union(){
    if(show_tuner_screw) 
        translate([0,0,0.5*explode+0.5]) nut(screw); 
        wheel(wheelTeeth,wheelD,wheelHeight,0.2);
    }


    translate([tunerScrewOffset,0,-thick-0.2*explode-1]) union() {
        if(show_tuner_screw) 
            washer(screw);
        //tuner locker 
        //the locker is small and the nut hole will shrink a bit after printing, so need more tolerance.
        translate([0,0,-lockerHeight-0.6*explode]) {
            if(show_tuner_screw) 
                translate([0,0,0.7*explode]) nut(screw);
            wheel(lockerTeeth,lockerD,lockerHeight,-0.3,0.05);
        }
    }
}

if(holder_export) {
    holder();
}else if(tuner_export) {
    tuner();
}else if(wheel_export) {
    wheel(wheelTeeth,wheelD,wheelHeight,0.2);
}else if(locker_export) {
    wheel(lockerTeeth,lockerD,lockerHeight,-0.3,0.05);
}else
    assembly();

