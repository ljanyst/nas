#!/bin/bash

function compile() {
    NAME=$1
    echo "Compiling ${NAME}.scad to ${NAME}.stl"
    openscad ${NAME}.scad -o ${NAME}.stl
}

compile nas-support-bottom
compile nas-support-top
compile nas-recorder-support-left
compile nas-recorder-support-right
compile nas-recorder-top-left
compile nas-recorder-top-right
compile nas-support-bolt-short
compile nas-support-bolt-long
compile nas-support-leg-front-left
compile nas-support-leg-front-right
compile nas-support-leg-back-left
compile nas-support-leg-back-right
compile nas-board-support-frame
compile nas-board-support-base
compile nas-board-support-foot
compile nas-board-leg-short
compile nas-board-leg-long
