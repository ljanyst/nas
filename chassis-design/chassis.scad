
use <recorder.scad>
use <legs.scad>
use <support.scad>
use <board-support.scad>
include <params.scad>

element_distance = 5;
rec_supp_width = 15;
rec_supp_thickness = 4;
frame_width = 12;
disk_supp_size = support_properties(num_disks, disk_dims)[0];
z_base = rec_dims[2] + rec_supp_thickness + element_distance +rec_supp_thickness
    + element_distance + 13 + element_distance + 35 + element_distance;

translate([rec_dims[4] + rec_supp_width, -element_distance, 0])
    rotate([0, 0, 180]) {
        recorder_support(rec_dims, rec_supp_width, rec_supp_thickness, true);
        translate([0, 0, rec_dims[2] + rec_supp_thickness + element_distance]) {
            recorder_top(rec_dims, rec_supp_width, rec_supp_thickness, true);
            translate([rec_supp_width/2, rec_dims[0]/2 + rec_supp_width, rec_supp_thickness + element_distance]) {
                cylinder(r = 0.2 * 15 - 0.1, h = 13, $fn = 96);
                translate([0, 0, 13 + element_distance])
                    support_leg(leg_off_x, leg_off_y, 15, 12, 30, false, false);
                translate([rec_dims[4]/2, 0, 0])
                    cylinder(r = 0.2 * 15 - 0.1, h = 9, $fn = 96);
                translate([rec_dims[4], 0, 0]) {
                    cylinder(r = 0.2 * 15 - 0.1, h = 13, $fn = 96);
                    translate([0, 0, 13 + element_distance])
                        support_leg(leg_off_x, leg_off_y, 15, 12, 30, false, true);
                }
            }
        }
    }

translate([0, 5, 0]) {
    recorder_support(rec_dims, rec_supp_width, rec_supp_thickness, false);
    translate([0, 0, rec_dims[2] + rec_supp_thickness + element_distance]) {
        recorder_top(rec_dims, rec_supp_width, rec_supp_thickness, false);
        translate([rec_supp_width/2, rec_dims[0]/2 + rec_supp_width, rec_supp_thickness + element_distance]) {
            cylinder(r = 0.2 * 15 - 0.1, h = 13, $fn = 96);
            translate([0, 0, 13 + element_distance])
                support_leg(leg_off_x, leg_off_y, 15, 12, 30, false, false);
            translate([rec_dims[4]/2, 0, 0])
                cylinder(r = 0.2 * 15 - 0.1, h = 9, $fn = 96);
            translate([rec_dims[4], 0, 0]) {
                cylinder(r = 0.2 * 15 - 0.1, h = 13, $fn = 96);
                translate([0, 0, 13 + element_distance])
                    support_leg(leg_off_x, leg_off_y, 15, 12, 30, false, true);
            }
        }
    }
}

translate([0, 0, z_base]) {
    translate([disk_supp_size[0] - 10, -disk_supp_size[1]/2, 0])
        rotate([0, 0, 90]) {
            bottom_support(num_disks, disk_dims);
            translate([0, 0, disk_dims[2] - 4])
                top_support(num_disks, disk_dims);
        }

    translate([-19 - element_distance, disk_supp_size[1]/2 + 1, 0])
        rotate([90, 0, -90])
            back_connector_frame(dims = [disk_supp_size[0] - 4.5, disk_dims[2] + 3.5],
                                  th = 2, length = 80);
    translate([-130 - 2 * element_distance, -disk_supp_size[1]/2 + 1, 0])
        rotate([90, 0, 90])
            back_connector_base(dims = [disk_supp_size[0] - 4.5, disk_dims[2] + 3.5],
                                th = 2, board_screws = [80, 51], height = 5);

}

translate([-130 - 2 * element_distance, -disk_supp_size[1]/2, 0]) {
    board_support_foot(4);
    translate([2, 0, 7 + element_distance]) {
        leg(58);
        translate([0, 2*frame_width, 0])
            leg(58);
        translate([2*frame_width, 0, 0])
            leg(60);
    }
}

translate([-130 - 2 * element_distance, disk_supp_size[1]/2, 0]) {
    rotate([0, 0, -90]) {
        board_support_foot(4);
        translate([2, 0, 7 + element_distance]) {
            leg(58);
            translate([2*frame_width, 0, 0])
                leg(58);
            translate([0, 2*frame_width, 0])
                leg(60);
        }
    }
}
