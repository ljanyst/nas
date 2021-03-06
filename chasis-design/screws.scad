
module screw(height, radius, head_height, head_radius) {
    cylinder(h = height, r = radius, $fn = 90);
    translate([0, 0, -head_height]) cylinder(h = head_height, r = head_radius, $fn = 90);
}

module nut(width, height, thickness) {
    linear_extrude(thickness)
        polygon([
            [0, height/2],
            [-width/2, 0.3 * height],
            [-width/2, -0.3 * height],
            [0, -height/2],
            [width/2, -0.3 * height],
            [width/2, 0.3 * height],
            [0, height/2]
        ]);
}

module screw_6_32(height = 5, head_height = 2.8, head_radius = 4) {
    screw(height, 2, head_height, head_radius);
}

module screw_4_40(height = 5, head_height = 2.3, head_radius = 2.8) {
    screw(height, 1.6, head_height, head_radius);
}

module nut_4_40(width = 4.7, height = 5.2, thickness = 1.5) {
    nut(width, height, thickness);
}

