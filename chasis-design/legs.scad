
use <extrude.scad>
use <support.scad>
use <recorder.scad>

module support_leg(offx, offy, rec_leg, disk_leg, height, left, front) {
    module body(x_off, y_off) {
        distort_extrude(height = height, scale = disk_leg/rec_leg, translate = [x_off, y_off])
            square(rec_leg, center = true);
    }

    x_sign = front ? -1 : 1;
    y_sign = left ? 1 : -1;
    x_off = x_sign * offx;
    y_off = y_sign * offy;

    difference() {
        body(x_off, y_off);
        cylinder(r = 0.2 * rec_leg, h = 5, $fn = 96);
    }
    translate([x_off, y_off, height])
        cylinder(r = 2.4, h = 4, $fn = 96);
}

module leg(height, frame_width = 12) {
    difference() {
        cube([frame_width, frame_width, height]);
        translate([frame_width/2, frame_width/2, 0]) {
            cylinder(r = 0.21 * frame_width, h = 6, $fn = 96);
            translate([0, 0, height - 6])
                cylinder(r = 0.21 * frame_width, h = 6, $fn = 96);
        }
    }
}
