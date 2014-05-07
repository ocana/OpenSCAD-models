module clampPlates(height,thick,space,angle,holes,holeOffset,screw,nutWidth) {
    h = height;
    l = 1+screw+thick+2*holeOffset;
    translate([-1,0,0]) {
        translate([0,-space,0]) rotate([0,0,-angle]) translate([0,-thick,0]) difference() {
            //clamp screw plate
            cube(size=[l,thick,h]);
            if(holes>0) {
                //screw holes, slightly enlarged because this plate has slop
                for(n=[1:holes]) {
                    hull() {
                        for(i=[-0.25,0.25])
                            translate([1+screw/2+holeOffset+thick+i,-0.05,h/holes/2+(n-1)*h/holes])
                                rotate([-90,0,0]) cylinder(r=screw/2,h=thick+0.1);
                    }
                }
            }
        }
        difference() {
            if(nutWidth>0)
                cube(size=[l,1.5+thick,h]);
            else
                cube(size=[l,thick,h]);
            if(holes>0) {
                for(n=[1:holes]) {
                    translate([1+screw/2+holeOffset+thick,2,h/holes/2+(n-1)*h/holes]) rotate([-90,0,0]) union() {
                        //nut hole
                        if(nutWidth>0) translate([0,0,1.5]) rotate([0,0,30]) cylinder(r=nutWidth/2,h=thick,$fn=6);
                        //screw hole
                        translate([0,0,-2.05]) cylinder(r=screw/2,h=thick+1);
                    }
                }
            }
        }
    }
}

module clamp(diameter,height,thick,space,angle,holes,holeOffset,screw,nutWidth) {
    r=diameter/2;
    h=height;
    s=space;
    a=angle;
    w=screw;
    t=thick;
    translate([0,0,height/2]) difference() {
        union() {
            difference() {
                //body
                cylinder(r=r+t,h=h,center=true);
                //make a cut of the cicurlar clamp body
                translate([r,0,-h/2-0.05]) scale([0.9,1,1]) difference() {
                    hull() clampPlates(h+0.1,t,s,a,0,holeOffset,w,nutWidth);
                    clampPlates(h+0.1,t,s,a,0,holeOffset,w,nutWidth);
                }
            }
            //plates
            translate([r,0,-h/2]) clampPlates(h,t,s,a,holes,holeOffset,w,nutWidth);
        }
        //rod hole
        cylinder(r=r,h=h+0.1,center=true);
    }
}
