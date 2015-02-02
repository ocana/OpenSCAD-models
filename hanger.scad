use <MCAD/boxes.scad>

NEGATIVE_FACTOR = -1;

HOOK_DIAMETER = 5;
TORUS_DIAMETER = 12;

DELTA = 0.1;

D=7.5;
t=3;
h=10;
R=D/2+t;

$fs=0.05;

l=D+D/2+5;

function half(number) = number / 2;

function radius(diameter) = half(diameter);

module torus(diameter, tubeDiameter){
	rotate_extrude(convexity = 10) 
		translate([radius(diameter), 0, 0]) 
			circle(r = radius(tubeDiameter));
}

module cuboid(diameter, tubeDiameter) {
	cuboid_length = tubeDiameter + diameter;
	cuboid_width = half(cuboid_length);
	cuboid_height = tubeDiameter + DELTA;
	dimensions = [cuboid_length, cuboid_width, cuboid_height];

	offset_x = NEGATIVE_FACTOR * half(cuboid_length);
	offset_z = NEGATIVE_FACTOR * half(cuboid_height);
	offset = [offset_x, 0, offset_z];

	translate(offset)
		cube(dimensions);
}

module halfTorus(diameter, tubeDiameter){
	difference() {
            torus(diameter, tubeDiameter);
            cuboid(diameter, tubeDiameter);
        }
}

module hook() {
    union() {
        halfTorus(TORUS_DIAMETER, HOOK_DIAMETER);
        translate([radius(TORUS_DIAMETER), 0, 0]) 
				sphere(r = radius(HOOK_DIAMETER));
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
    translate([0,l-3+h-radius(TORUS_DIAMETER)-HOOK_DIAMETER/2,radius(TORUS_DIAMETER)+h/2+R*2])
    rotate([180,0,0]) 
    rotate([0,90,0]) 
    hook();
}

mirror([0,1,0]) rotate([0,-90,0]) hanger();




