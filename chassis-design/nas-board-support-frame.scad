
use <support.scad>
use <board-support.scad>
include <params.scad>

pr = support_properties(num_disks, disk_dims);
back_connector_frame(dims = [pr[0][0] - 4.5, disk_dims[2] + 3.5], th = 2, length = 80);
