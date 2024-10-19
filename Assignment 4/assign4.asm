// CPSC 355 - Assignment 4
// Structures and Subroutines

// Setting all the output strings to print
first:      .string "first"
second:     .string "second"
output1:    .string "Initial cuboid values:\n"
output2:    .string "Changed cuboid values:\n"
output3:    .string "Cuboid %s origin = (%d, %d)\n\tBase width = %d  Base length = %d\n\tHeight = %d\n\tVolume = %d\n\n"

// Defining the boolean values
define(FALSE, 0)
define(TRUE, 1)

// Defining macros for some frequently used registers
define(pointx_r, w2)
define(pointy_r, w3)
define(width_r, w4)
define(length_r, w5)
define(height_r, w6)
define(volume_r, w7)
define(factor_r, w19)
define(deltax_r, w20)
define(deltay_r, w21)

// Allocating the memory
alloc       = -(16 + (cuboid_off * 2)) & -16
dealloc     = -alloc

// Stack variable offsets
first_off   = 16
second_off  = 40
pointx_off  = 0
pointy_off  = 4
width_off   = 8
length_off  = 12
height_off  = 16
volume_off  = 20
cuboid_off  = 24

    .global main
    .balign 4


main:
    stp     x29, x30, [sp, -16]!            // storing x29 and x30 (fp and lr) to stack
    mov     x29, sp                         // moving stack pointer to x29

    // create first cuboid struct
    add     x11, x29, first_off
    bl      newCuboid

    // create second cuboid struct
    add     x11, x29, second_off
    bl      newCuboid

    // print "initial values" heading
    ldr     w0, =output1
    bl      printf

    // print first cuboid details
    add     x0, x29, first_off
    ldr     w1, =first
    bl      printCuboid

    // print second cuboid details
    add     x0, x29, second_off
    ldr     w1, =second
    bl      printCuboid

    mov     x19, FALSE

    // check if both cuboids are equal in size
    add     x20, x29, first_off
    add     x21, x29, second_off
    bl      equalSize

    cmp x19, FALSE
    b.eq    done

    // scale second cuboid
    mov     x10, x21
    mov     factor_r, 4
    bl      scale

    // move first cuboid
    add     x0, x29, first_off
    mov     deltax_r, 3
    mov     deltay_r, -6
    bl      move

done:
    // print "changed values" heading
    ldr     w0, =output2
    bl      printf

    // print first cuboid new details
    add     x0, x29, first_off
    ldr     w1, =first
    bl      printCuboid

    // print second cuboid new details
    add     x0, x29, second_off
    ldr     w1, =second
    bl      printCuboid

    ldp     x29, x30, [sp], 16
    ret

newCuboid:
    stp     x29, x30, [sp, alloc]!          // storing x29 and x30 (fp and lr) to stack
    mov     x29, sp                         // moving stack pointer to x29
    add     x9, x29, 16                     // address of the new cuboid struct

    // initialize the cuboid with given values
    mov     pointx_r, 0
    str     pointx_r, [x9, pointx_off]
    mov     pointy_r, 0
    str     pointy_r, [x9, pointy_off]
    mov     width_r, 2
    str     width_r, [x9, width_off]
    mov     length_r, 2
    str     length_r, [x9, length_off]
    mov     height_r, 3
    str     height_r, [x9, height_off]

    // calculate volume of cuboid
    mul     volume_r, width_r, length_r
    mul     volume_r, volume_r, height_r

    // store volume value
    str     volume_r, [x9, volume_off]

    // copy all values from first cuboid to second
    ldr     x10, [x9, pointx_off]
    str     x10, [x11, pointx_off]
    ldr     x10, [x9, pointy_off]
    str     x10, [x11, pointy_off]
    ldr     x10, [x9, width_off]
    str     x10, [x11, width_off]
    ldr     x10, [x9, length_off]
    str     x10, [x11, length_off]
    ldr     x10, [x9, height_off]
    str     x10, [x11, height_off]
    ldr     x10, [x9, volume_off]
    str     x10, [x11, volume_off]

    ldp     x29, x30, [sp], -alloc          // restore fp and lr
    ret

printCuboid:
    stp     x29, x30, [sp, -16]!            // storing x29 and x30 (fp and lr) to stack
    mov     x29, sp                         // moving stack pointer to x29
    mov     x11, x0                         // load the cuboid's pointer

    ldr     w0, =output3
    ldr     pointx_r, [x11, pointx_off]     // load the origin point's x-coordinate
    ldr     pointy_r, [x11, pointy_off]     // load the origin point's y-coordinate
    ldr     width_r, [x11, width_off]       // load the cuboid's base width
    ldr     length_r, [x11, length_off]     // load the cuboid's base length
    ldr     height_r, [x11, height_off]     // load the cuboid's height
    ldr     volume_r, [x11, volume_off]     // load the cuboid's volume
    bl      printf

    ldp     x29, x30, [sp], 16              // restore fp and lr
    ret

equalSize:
    stp     x29, x30, [sp, -16]!            // storing x29 and x30 (fp and lr) to stack
    mov     x29, sp                         // moving stack pointer to x29
    mov     x11, x20                        // load the first cuboid's pointer
    mov     x13, x21                        // load the second cuboid's pointer

    // Compare width of cuboids
    ldr     x10, [x11, width_off]
    ldr     x12, [x13, width_off]
    cmp     x10, x12
    b.eq    ifWidthEq
    b       equalSize_done

ifWidthEq:
    // Compare length of cuboids
    ldr     x10, [x11, length_off]
    ldr     x12, [x13, length_off]
    cmp     x10, x12
    b.eq    ifLengthEq
    b       equalSize_done

ifLengthEq:
    // Compare height of cuboids
    ldr     x10, [x11, height_off]
    ldr     x12, [x13, height_off]
    cmp     x10, x12
    b.eq    ifHeightEq
    b       equalSize_done

ifHeightEq:
    mov     x19, TRUE
    b       equalSize_done

equalSize_done:
    ldp     x29, x30, [sp], 16              // restore fp and lr
    ret

scale:
    stp     x29, x30, [sp, -16]!            // storing x29 and x30 (fp and lr) to stack
    mov     x29, sp                         // moving stack pointer to x29
    mov     x11, x10                        // load the cuboid's pointer

    // Calculate new width
    ldr     width_r, [x11, width_off]
    mul     width_r, width_r, factor_r
    str     width_r, [x11, width_off]

    // Calculate new length
    ldr     length_r, [x11, length_off]
    mul     length_r, length_r, factor_r
    str     length_r, [x11, length_off]

    // Calculate new height
    ldr     height_r, [x11, height_off]
    mul     height_r, height_r, factor_r
    str     height_r, [x11, height_off]

    // Recalculate volume
    mul     volume_r, width_r, length_r
    mul     volume_r, volume_r, height_r

    // Store new volume
    str     volume_r, [x11, volume_off]

    ldp     x29, x30, [sp], 16              // restore fp and lr
    ret

move:
    stp     x29, x30, [sp, -16]!            // storing x29 and x30 (fp and lr) to stack
    mov     x29, sp                         // moving stack pointer to x29
    mov     x11, x0                         // load the cuboid's pointer

    // modify origin x coordinate
    ldr     pointx_r, [x11, pointx_off]
    add     pointx_r, pointx_r, deltax_r
    str     pointx_r, [x11, pointx_off]

    // modify origin y coordinate
    ldr     pointy_r, [x11, pointy_off]
    add     pointy_r, pointy_r, deltay_r
    str     pointy_r, [x11, pointy_off]

    ldp     x29, x30, [sp], 16              // restore fp and lr
    ret