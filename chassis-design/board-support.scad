
use <polyline.scad>
use <arc.scad>
use <common.scad>

module back_connector_frame(dims, th, length, frame_width = 12) {
    sq = [9, 1.5, 10];
    bolt_support_thickness = 1;
    bolt_thickness = 1.5;
    bolt_width = 8;
    convex_offset = bolt_thickness - (sq[0] - bolt_width)/2;

    module sq() {
        cube(sq);
        translate([sq[0]/2, 0, 6])
            rotate([0, 90, 90])
                translate([0, 0, -25])
                    cylinder(r = 1.6, h = 50, $fn = 96);
    }

    module sq1() {
        translate([sq[1], 0, 0])
            rotate([0, 0, 90])
                sq();
    }

    module fr() {
        translate([th, th, 0])
            linear_extrude(frame_width + th)
               frame([0, 0], dims, th);
        translate([th, th, 0])
            cube([15, bolt_support_thickness, 12]);
        translate([th, th + dims[1] - bolt_support_thickness, 0])
            cube([15, bolt_support_thickness, 12]);
        translate([th + dims[0] - 15, th, 0])
            cube([15, bolt_support_thickness, 12]);
        translate([th + dims[0] - 15, th + dims[1] - bolt_support_thickness, 0])
            cube([15, bolt_support_thickness, 12]);
    }

    module column(width, length, vertical_support = false) {
        cube([width, width, length]);
        translate([width/2, width/2, length]) cylinder(r = 0.2 * width, h = 5, $fn = 96);
        if (vertical_support) {
            translate([width/2, 0, length - 1.5 * frame_width])
                rotate([90, 0, 0])
                    cylinder(r = 0.2 * width, h = 5, $fn = 96);
        }
    }

    difference() {
        fr();
        translate([th + convex_offset, 0, 0]) sq();
        translate([th, th + bolt_thickness, 0]) sq1();
        translate([th + convex_offset, th + dims[1] + th - sq[1], 0]) sq();
        translate([th, th + dims[1] - bolt_width - bolt_thickness, 0]) sq1();

        translate([th + dims[0] - sq[0] - convex_offset, 0, 0]) sq();
        translate([th + dims[0] - sq[1], th + bolt_thickness, 0]) sq1();
        translate([th + dims[0] - sq[0] - convex_offset, th + dims[1] + th - sq[1], 0]) sq();
        translate([th + dims[0] - sq[1], th + dims[1] - bolt_width - bolt_thickness, 0]) sq1();
    }
    translate([th, th, frame_width]) cube([dims[0], frame_width, th]);
    translate([th, th + dims[1] - frame_width, frame_width]) cube([dims[0], frame_width, th]);
    translate([th + dims[0] - frame_width, th, frame_width]) cube([frame_width, dims[1], th]);
    translate([th, th, frame_width]) cube([frame_width, dims[1] - frame_width - 50, th]);

    translate([th, th, th + frame_width])
        column(frame_width, length, vertical_support = true);
    translate([th + dims[0] - frame_width, th, th + frame_width])
        column(frame_width, length, vertical_support = true);
    translate([th, th + dims[1] - frame_width, th + frame_width]) column(frame_width, length);
    translate([th + dims[0] - frame_width, th + dims[1] - frame_width, th + frame_width]) column(frame_width, length);
}

module back_connector_base(dims, th, board_screws, height, frame_width = 12, screw_support_height = 15) {
    screws_x = (dims[0] - board_screws[0]) / 2;
    screws_y = (dims[1] - board_screws[1]) / 2;
    c = [
        [frame_width/2, frame_width/2, 0],
        [frame_width/2, dims[1] - frame_width/2, 0],
        [dims[0] - frame_width/2, frame_width/2, 0],
        [dims[0] - frame_width/2, dims[1] - frame_width/2, 0]
    ];
    s = [
        [screws_x, screws_y, 0],
        [screws_x, screws_y + board_screws[1], 0],
        [screws_x + board_screws[0], screws_y, 0],
        [screws_x + board_screws[0], screws_y + board_screws[1], 0]
    ];

    module base_frame() {
        cube([dims[0], frame_width, height]);
        translate([0, dims[1] - frame_width, 0]) cube([dims[0], frame_width, height]);
        translate([dims[0] - frame_width, 0, 0]) cube([frame_width, dims[1], height]);
        cube([frame_width, dims[1], height]);

        linear_extrude(height) {
            for(i = [0 : 3]) polyline(points = [c[i], s[i]], width = frame_width);
        }
        for(i = [0 : 3]) {
           translate(s[i]) cylinder(r = 3, h = screw_support_height, $fn = 96);
           translate(c[i] + [0, 0, frame_width/2])
               cube([frame_width, frame_width, frame_width], center = true);
        }
    }

    module bolt() {
        rotate([90, 0, 0]) cylinder(r = 0.2 * frame_width, h = 5, $fn = 96);
    }

    module anthena_handle() {
        rotate([0, 90, 0])
            linear_extrude(1.5)
                arc(radius = 1.5, angles = [-130, 130], width = 1.5, fn = 96);
    }

    module power_handle() {
        translate([-12, -4.5, 0]) linear_extrude(height) frame([0, 0], [24, 9], 1.5);
    }

    translate([th, th, 0]) {
        difference() {
            base_frame();
            for(i = [0 : 3]) translate(s[i]) cylinder(r = 1.75, h = 15, $fn = 96);
            for(i = [0 : 3])
                translate(c[i] + [0, 0, frame_width - 6])
                    cylinder(r = 0.225 * frame_width, h = 6, $fn = 96);
        }

        linear_extrude(frame_width)
            frame([0, 0], dims, th);
    }
    translate([th, 0, frame_width/2]) {
        translate([frame_width/2, 0, 0]) bolt();
        translate([2.5 * frame_width, 0, 0]) bolt();
        translate([dims[0] - frame_width/2, 0, 0]) bolt();
        translate([dims[0] - 2.5 * frame_width, 0, 0]) bolt();
    }
    translate([dims[0]/2 + th, th + frame_width/2, height + 2]) {
        anthena_handle();
        translate([0, dims[1] - frame_width, 0]) anthena_handle();
    }
    translate([th + dims[0] - frame_width - 4.5, th + dims[1]/2, 0]) {
        rotate([0, 0, 90])
        power_handle();
    }
}

module board_support_foot(thickness, frame_width = 12, th = 2) {
    module base() {
        cube([3 * frame_width, frame_width, thickness]);
        cube([frame_width, 3 * frame_width, thickness]);
        translate([frame_width, frame_width, 0])
            cube([th/2, th/2, thickness]);
        translate([frame_width/2, frame_width/2, thickness]) {
            cylinder(r = 0.2 * frame_width, h = 5, $fn = 96);
            translate([2 * frame_width, 0, 0])
                cylinder(r = 0.2 * frame_width, h = 5, $fn = 96);
            translate([0, 2 * frame_width, 0])
                cylinder(r = 0.2 * frame_width, h = 5, $fn = 96);
        }
    }

    module frame() {
        dt = th/2;
        linear_extrude(thickness)
            polyline(points = [
                [0 - dt, 0 - dt],
                [0 - dt, 3 * frame_width + dt],
                [frame_width + dt, 3 * frame_width + dt],
                [frame_width + dt, frame_width + dt],
                [3 * frame_width + dt, frame_width + dt],
                [3 * frame_width + dt, 0 - dt],
                [0 - dt, 0 - dt]
            ], width = th);
    }

    translate([th, th, 0]) {
        base();
        frame();
    }
}
