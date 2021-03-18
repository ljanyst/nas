
module sector(radius, angles, fn = 24) {
    r = radius / cos(180 / fn);
    difference() {
        circle(radius, $fn = fn);
        polygon(
            concat(
                [
                    for(a = [angles[0] : -360 / fn : angles[1] - 360])
                        [r * cos(a), r * sin(a)]
                ],
                [[r * cos(angles[1]), r * sin(angles[1])], [0, 0]]
            )
        );
    }
}

module arc(radius, angles, width = 1, fn = 24) {
    difference() {
        sector(radius + width, angles, fn);
        sector(radius, [angles[0] - 1, angles[1] + 1], fn);
    }
}

arc(20, [45, 135], 1, 24);
