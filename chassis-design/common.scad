
use <polyline.scad>

module frame(left_down, right_up, thickness) {
    th = thickness / 2;
    polyline([
        [left_down[0] - th, left_down[1] - th],
        [right_up[0] + th, left_down[1] - th],
        [right_up[0] + th, right_up[1] + th],
        [left_down[0] - th, right_up[1] + th],
        [left_down[0] - th, left_down[1] - th]
    ], width = thickness);
}
