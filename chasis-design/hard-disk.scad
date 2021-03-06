
use <screws.scad>

hd35_dims = [25.5, 147, 101.5];
hd35_screws_offset_front = 19.15;
hd35_screws_offset_top = 16.9;

module hd35_screw(height = 5, head_height = 2.8, head_radius = 4) {
    screw_6_32(height, head_height, head_radius);
}

module hd35_side_screws(height = 5, head_height = 2.8, head_radius = 4) {
    hd35_screw(height, head_height, head_radius);
    translate([0, 59.8, 0]) hd35_screw(height, head_height, head_radius);
    translate([0, 101.6, 0]) hd35_screw(height, head_height, head_radius);
}

module hd35(dims = hd35_dims, screws_offset_top = hd35_screws_offset_front,
            screws_offset_front = hd35_screws_offset_top) {

    difference() {
        cube(dims);
        translate([screws_offset_top, screws_offset_front, 0]) hd35_side_screws();
        translate([screws_offset_top, screws_offset_front, dims[2]]) rotate([0, 180, 0])
            hd35_side_screws();
        translate(dims - [8, 8, 55]) cube([9, 9, 46]);
    }
}
