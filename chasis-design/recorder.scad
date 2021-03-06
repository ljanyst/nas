
function recorder_leg_dist(rec_dims, width) = [
    rec_dims[0] + width, // x distanme
    rec_dims[4]          // y distance
];

module stripe_connector_m(width, length, height) {
    difference() {
        cube([width, length, height]);
        translate([0, 0, height/2]) cube([width, width, height/2]);
    }
    translate([width/2, width/2, height/2])
        cylinder(r = 0.3 * width, h = height/2, $fn = 96);
}

module stripe_connector_f(width, length, height) {
    difference() {
        cube([width, length, height]);
        cube([width, width, height/2]);
        translate([width/2, width/2, height/2])
            cylinder(r = 0.3 * width + 0.25, h = height/2, $fn = 96);
    }
}

module recorder_support(rec_dims, width, thickness, left = true) {
    module leg(rec_dims, width, thickness, left = true) {
        bolt_depth = 5;

        difference() {
            if (left) stripe_connector_m(width, rec_dims[0]/2 + 1.5 * width, thickness);
            else stripe_connector_f(width, rec_dims[0]/2 + 1.5 * width, thickness);
            translate([width/2, rec_dims[3]/2 + width/2, thickness - rec_dims[6]])
                cylinder(r = rec_dims[5], h = rec_dims[6], $fn = 96);
        }
        translate([0, rec_dims[0]/2 + width/2, 0]) {
            difference() {
                cube([width, width, rec_dims[2] + thickness]);
                translate([width/2, width/2, rec_dims[2] + thickness - bolt_depth])
                    cylinder(r = 0.2 * width, h = 5, $fn = 96);
            }
        }
    }

    leg(rec_dims, 15, thickness);
    translate([rec_dims[4], 0, 0])
        leg(rec_dims, 15, thickness, left = false);
    translate([rec_dims[4]/2, 0, 0])
        leg(rec_dims, 15, thickness, left);
    translate([width, rec_dims[0]/6 + width/2, 0]) cube([rec_dims[4] - width, width, thickness]);
    translate([width, rec_dims[0]/2 + 1.5 * width, 0]) {
        translate([0, -width, 0]) cube([rec_dims[4] - width, width, thickness]);
        translate([0, -thickness, 0]) cube([rec_dims[4] - width, thickness, width]);
    }
}

module recorder_top(rec_dims, width, thickness, left = true) {
    module w_connector(rec_dims, width, thickness, left = true) {
        difference() {
            if (left) stripe_connector_m(width, rec_dims[0]/2 + 1.5 * width, thickness);
            else stripe_connector_f(width, rec_dims[0]/2 + 1.5 * width, thickness);
            translate([width/2, rec_dims[0]/2 + width, 0])
                cylinder(r = 0.2 * width, h = thickness, $fn = 96);
        }
    }

    supp_space = (rec_dims[4] - 2*width)/2;

    w_connector(rec_dims, 15, thickness);
    translate([rec_dims[4], 0, 0])
        w_connector(rec_dims, 15, thickness, left = false);
    translate([rec_dims[4]/2, 0, 0])
        w_connector(rec_dims, 15, thickness, left);
    translate([width, rec_dims[0]/6 + width/2, 0]) cube([rec_dims[4] - width, width, thickness]);
    translate([0, rec_dims[0]/2 + width/2, 0]) {
        translate([width, 0, 0]) cube([supp_space, width, thickness]);
        translate([2*width + supp_space, 0, 0]) cube([supp_space, width, thickness]);
    }
}

module recorder(rec_dims) {
    leg_x_off = (rec_dims[0] - rec_dims[3])/2;
    leg_y_off = (rec_dims[1] - rec_dims[4])/2;
    translate([0, 0, rec_dims[6]])
        cube([rec_dims[0], rec_dims[1], rec_dims[2]]);
    translate([leg_x_off, leg_y_off, 0]) cylinder(r = 5, h = 2);
    translate([rec_dims[0] - leg_x_off, leg_y_off, 0]) cylinder(r = 5, h = 2);
    translate([leg_x_off, rec_dims[1] - leg_y_off, 0]) cylinder(r = 5, h = 2);
    translate([rec_dims[0] - leg_x_off, rec_dims[1] - leg_y_off, 0])
        cylinder(r = 5, h = 2);
}
