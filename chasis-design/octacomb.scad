
use <polyline.scad>

module octaunit(edge, thickness) {
    polyline([
        [edge, 0],
        [2*edge, 0],
        [3*edge, edge],
        [3*edge, 2*edge],
        [2*edge, 3*edge],
        [edge, 3*edge],
        [0, 2*edge],
        [0, edge],
        [edge, 0]
    ], width = thickness);
}

module octacomb(numx, numy, edge, thread_thickness) {
    module comb() {
        for(iy = [0 : 2 * numy - 1]) {
            for(ix = [0 : numx]) {
                translate([(ix - 1) * 4 * edge + (iy % 2 == 0 ? 0 : 2*edge), iy * 2 * edge, 0]) {
                    octaunit(edge, thread_thickness);
                    translate([(iy % 2 == 0 ? 3 * edge : -edge), edge, 0])
                        square([edge, edge]);
                }
            }
        }
    }

    intersection() {
        comb();
        square([(4 * numx - 1) * edge, (4 * numy - 1) * edge]);
    }
    polyline([
        [0, 0],
        [(4 * numx - 1) * edge, 0],
        [(4 * numx - 1) * edge, (4 * numy - 1) * edge],
        [0, (4 * numy - 1) * edge],
        [0, 0]
    ], width = thread_thickness);
}

