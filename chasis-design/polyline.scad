
module line(point1, point2, width = 1, rounded = true) {
    angle = 90 + atan((point2[1] - point1[1]) / (point2[0] - point1[0]));
    polygon([
        [point1[0] + 0.5 * width * cos(angle), point1[1] + 0.5 * width * sin(angle)],
        [point1[0] - 0.5 * width * cos(angle), point1[1] - 0.5 * width * sin(angle)],
        [point2[0] - 0.5 * width * cos(angle), point2[1] - 0.5 * width * sin(angle)],
        [point2[0] + 0.5 * width * cos(angle), point2[1] + 0.5 * width * sin(angle)],
    ]);
    translate(point1) circle(d = width, $fn = 96);
    translate(point2) circle(d = width, $fn = 96);
}

module polyline(points, width = 1) {
    module inner(index) {
        if(index < len(points)) {
            line(points[index - 1], points[index], width);
            inner(index + 1);
        }
    }
    inner(1);
}

polyline([[10, 10], [50, 50], [30, 0], [50, 10]]);
