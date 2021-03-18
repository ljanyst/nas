
use <octacomb.scad>
use <polyline.scad>
use <hard-disk.scad>
use <screws.scad>
use <recorder.scad>
use <common.scad>

include <params.scad>

disk_leg_size = 12;

comb_edge = 5.08;
comb_size = 4 * comb_edge;
support_thickness = 4;
frame_height = 12;
frame_thickness = 2;

function support_properties(num_disks, disk_dims) = [
    [
        (num_disks - 1) * 2 * comb_size + disk_dims[0] + 2 * frame_thickness,
        disk_dims[1] + 2 * frame_thickness,
        frame_height
    ],
    frame_thickness,
    support_thickness
];

function support_leg_dist(num_disks, disk_dims, width) =
    let(dims = support_properties(num_disks, disk_dims)) [
        dims[0][0] - 2 * dims[1] - width, // x distanme
        dims[0][1] - 2 * dims[1] - width  // y distance
];

module support(top, num_disks, disk_dims) {
    screws_offset = [5.5 * comb_edge, 7.5 * comb_edge, 2];
    screw_rotation = top ? 180 : 0;
    support_offset = top ? frame_height - support_thickness : 0;
    screws_offset_top = disk_dims[4];
    screws_offset_front = disk_dims[3];
    ft = [frame_thickness, frame_thickness, 0];

    module comb() {
        difference() {
            linear_extrude(support_thickness)
                octacomb(numx = 2 * num_disks + 1, numy = 9, edge = comb_edge, thread_thickness = 2);
            for(i = [0 : num_disks - 1]) {
                translate(screws_offset + [2 * i * comb_size, 0, 0])
                    rotate([0, screw_rotation, 0])
                        hd35_side_screws();
            }
        }
    }

    start = screws_offset - [screws_offset_top, screws_offset_front, 2];
    size = support_properties(num_disks, disk_dims)[0] - 2 * ft;

    translate(ft + [0, 0, support_offset])
        intersection() {
            translate(-start) comb();
            cube(size);
        }
    linear_extrude(frame_height)
        frame(ft, size + ft, frame_thickness);
}

module connectors(top, num_disks, disk_dims) {
    module connector() {
        difference() {
            translate([0, -3, 0]) cube([8, 11, 1.5]);
            translate([4, 4, 0]) screw_4_40();
        }
    }

    size = support_properties(num_disks, disk_dims)[0];
    left = [frame_thickness, size[1], 0];
    right = [size[0] - frame_thickness, size[1] , 0];
    horizontal_z = top ? frame_height - 1.5 : 0;
    vertical_z = top ? frame_height - 9.5 - frame_thickness : 3.5;

    translate(left + [1.5, 2, vertical_z]) rotate([0, -90, 0]) connector();
    translate(right + [0, 2, vertical_z]) rotate([0, -90, 0]) connector();
    translate(left + [1.5, 2, horizontal_z]) connector();
    translate(right + [-9.5, 2, horizontal_z]) connector();
}

module top_support(num_disks, disk_dims) {
    support(true, num_disks, disk_dims);
    connectors(true, num_disks, disk_dims);
}

module bottom_support(num_disks, disk_dims, screws_offset_front, screws_offset_top) {
    module sq1() {
        cube([disk_leg_size, disk_leg_size, support_thickness]);
    }
    module sq2() {
        difference() {
            cube([disk_leg_size, disk_leg_size, support_thickness]);
            translate([disk_leg_size/2, disk_leg_size/2, 0]) cylinder(r = 2.5, h = 5, $fn = 96);
        }
    }

    module legs() {
        size = support_properties(num_disks, disk_dims)[0];
        left = [frame_thickness, frame_thickness, 0];
        right_offset = size[0] - 2 * frame_thickness - disk_leg_size;
        top_offset = size[1] - 2 * frame_thickness - disk_leg_size;

        translate(left) children(0);
        translate(left + [right_offset, 0, 0]) children(0);
        translate(left + [right_offset, top_offset, 0]) children(0);
        translate(left + [0, top_offset, 0]) children(0);
    }

    union() {
        difference() {
            support(false, num_disks, disk_dims);
            legs() sq1();
        }
        legs() sq2();
    }
    connectors(false, num_disks, disk_dims);
}
