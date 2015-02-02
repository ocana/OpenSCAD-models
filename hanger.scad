use <MCAD/boxes.scad>

NEGATIVE_FACTOR = -1;

HOOK_DIAMETER = 5;
TORUS_DIAMETER = 12;

DELTA = 0.1;

HANGER_HEIGHT = 13.5;
HANGER_WIDTH = 10;

CUBE_LENGTH = 16.25;

HANGER_INTERNAL_THICKNESS = 3;
HANGER_INTERNAL_HEIGHT = HANGER_HEIGHT - 2*HANGER_INTERNAL_THICKNESS;

$fs = 0.05;

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

module hookRoundedEnd(diameter, tubeDiameter){
	translate([radius(diameter), 0, 0]) 
				sphere(r = radius(tubeDiameter));
}

module hook() {
    union() {
        halfTorus(TORUS_DIAMETER, HOOK_DIAMETER);
        hookRoundedEnd(TORUS_DIAMETER, HOOK_DIAMETER);
    };
}

module hangerCentralExternalBox() {
	rounded_box_offset = [0, 0, -0.75];
	rounded_box_length = 20;
	rounded_box_dimensions = [HANGER_HEIGHT, HANGER_WIDTH, rounded_box_length];

	translate(rounded_box_offset) 
		roundedBox(rounded_box_dimensions, radius=1);
}

module hangerCentralInternalBox() {
	cylinder_rotation = [90, 0, 0];

	cube_offset = [half(HANGER_INTERNAL_HEIGHT), 0, 0];
	cube_dimensions = [HANGER_INTERNAL_HEIGHT, HANGER_WIDTH + DELTA, HANGER_INTERNAL_HEIGHT];

	rotate(cylinder_rotation) 
		cylinder(r= half(HANGER_INTERNAL_HEIGHT), h= HANGER_WIDTH + DELTA, center=true);
	translate(cube_offset) 
		cube(cube_dimensions, center=true);
}

module hangerCentralBox() {
	offset = [0, 0, half(HANGER_WIDTH + HANGER_HEIGHT)];

	translate(offset) 
		difference() {
			hangerCentralExternalBox();
			hangerCentralInternalBox();
		}
}

module hangerCornerBox() {
	dimensions = [HANGER_HEIGHT, HANGER_WIDTH, HANGER_WIDTH];

	roundedBox(dimensions, radius=1, sidesonly=true);
}

module hangerBox() {
	offset = [0, CUBE_LENGTH -HANGER_INTERNAL_THICKNESS + half(HANGER_WIDTH), 0];

	translate(offset) {
    	hangerCentralBox();
		hangerCornerBox();
    }
}

module externalCurvedPart() {
	dimensions = [HANGER_HEIGHT, CUBE_LENGTH, HANGER_WIDTH];
	
	union() {
		cylinder(r= half(HANGER_HEIGHT), h= HANGER_WIDTH, center=true);

		translate([0, half(CUBE_LENGTH), 0]) 
			cube(dimensions, center=true);
	}
}

module internalCurvedPart() {
	cylinder(r= half(HANGER_INTERNAL_HEIGHT), h= HANGER_WIDTH + DELTA, center=true);
	
	first_cuboid_dimensions = [HANGER_INTERNAL_HEIGHT, CUBE_LENGTH + DELTA, HANGER_WIDTH + DELTA];
	first_cuboid_offset = [0, half(CUBE_LENGTH), 0];
    translate(first_cuboid_offset) 
		cube(first_cuboid_dimensions, center=true);
	
	second_cuboid_length = 15.6;
	second_cuboid_dimensions = [HANGER_HEIGHT, second_cuboid_length, HANGER_WIDTH + DELTA];
	second_cuboid_offset = [3, 11.5, 0];
	translate(second_cuboid_offset) 
		cube(second_cuboid_dimensions, center=true);
}

module hangerRoundedEnd() {
	offset = [half(HANGER_INTERNAL_HEIGHT) + half(HANGER_INTERNAL_THICKNESS), half(HANGER_INTERNAL_HEIGHT), 0];
	length = 2;
	dimensions = [HANGER_INTERNAL_THICKNESS, length, HANGER_WIDTH];

	translate(offset) 
		roundedBox(dimensions, radius=1, sidesonly=true);
}

module hangerCurvedPart() {
	difference() {
        externalCurvedPart();
        internalCurvedPart();
    }

    hangerRoundedEnd();
}

module hanger() {
    hangerCurvedPart();
    hangerBox();

	offset = [0, 14.75, 24.5];
	
    translate(offset)
		rotate([180, 0, 0]) 
    		rotate([0, 90, 0]) 
    			hook();
}

mirror([0, 1, 0]) 
	rotate([0, -90, 0]) 
		hanger();




