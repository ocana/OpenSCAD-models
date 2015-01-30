use <MCAD/boxes.scad>

HOOK_DIAMETER = 5;
d=5;
D=7.5;
t=3;
h=10;
R=D/2+t;
r=6;

$fs=0.05;

l=D+D/2+5;

module hook() {
    union() {
        difference() {
            rotate_extrude(convexity=10) 
					translate([r,0,0]) 
						circle(r=HOOK_DIAMETER/2);

            translate([-HOOK_DIAMETER/2-r,0,-HOOK_DIAMETER/2-0.05]) 
					cube([HOOK_DIAMETER+r*2,HOOK_DIAMETER/2+r,HOOK_DIAMETER+0.1]);
        }

        translate([r,0,0]) 
				sphere(r=HOOK_DIAMETER/2);
    };
}

module hanger() {
    difference() {
        union() {
            cylinder(r=R,h=h,center=true);
            translate([0,l/2,0]) cube([R*2,l,h],center=true);
        }
        cylinder(r=D/2,h=h+0.1,center=true);
        translate([0,l/2,0]) cube([D,l+0.1,h+0.1],center=true);
        translate([t,D+4,0]) cube([2*R,D+8.1,h+0.1],center=true);
    }
    translate([D/2+t/2,D/2,0]) roundedBox([t,2,h],radius=1,sidesonly=true);
    translate([0,l-3+h/2,0]) {
        roundedBox([R*2,h,h],radius=1,sidesonly=true);
        translate([0,0,h/2+R]) difference() {
            translate([0,0,HOOK_DIAMETER/4-2]) roundedBox([R*2,h,R*2+4+HOOK_DIAMETER/2],radius=1);
            rotate([90,0,0]) cylinder(r=D/2,h=h+0.1,center=true);
            translate([D/2,0,0]) cube([D,h+0.1,D],center=true);
        }
    }
    translate([0,l-3+h-r-HOOK_DIAMETER/2,r+h/2+R*2])
    rotate([180,0,0]) 
    rotate([0,90,0]) 
    hook();
}

mirror([0,1,0]) rotate([0,-90,0]) hanger();




