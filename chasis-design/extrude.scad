
module distort_extrude(height = 10, scale = 1, translate = [0, 0], steps = 500) {
    extrude_unit = height / steps;
    scale_unit = (1 - scale) / steps;
    translate_unit = translate / steps;
    for (i = [0 : steps - 1]) {
        translate([i * translate_unit[0], i * translate_unit[1], i * extrude_unit])
        linear_extrude(height = extrude_unit)
            scale(1 - i * scale_unit)
                children(0);
    }
}
