// CPSC 355 - Assignment 6
// File I/O and Floating-Point Numbers

// Setting all the output strings to print
prt_labels:     .string "\n      (x)\t\t   e^(x)\t      e^(-x)\n\n"
prt_values:     .string "%13.10f\t   %16.10f\t  %13.10f\n"
error_args:     .string "Error with provided arguments. Usage example: './a6 input.bin'\n"
error_file:     .string "Error, input couldn't be read successfully.\n"

// Storing the series expansion term's limit
calc_limit:     .double 0r1.0e-10

// Allocating the memory
alloc           = -(16 + 8) & -16
dealloc         = -alloc

// Defining macros:
// for frequently used registers
define(file_desc, w20)
define(read_byte, x21)
define(buffer_base, x22)
// for calculation variables
define(numerator, d21)
define(denominator, d22)
define(exponent, d23)
define(calc4, d24)
define(result, d25)
define(fraction, d26)
define(limitf, d27)
// for command-line arguments
define(numArg, w23)
define(valArg, x24)
// for frame-pointer and link-register
define(fp, x29)
define(lr, x30)

    .balign 4                                   // align code instructions by 4 bytes
    .global main                                // making main branch accessible to system

main:
    stp     fp, lr, [sp, alloc]!                // storing fp and lr to stack
    mov     fp, sp                              // moving stack pointer to fp
    mov     numArg, w0
    mov     valArg, x1
    cmp     numArg, 2                           // check if there's 2 arguments entered
    b.eq    filecheck                           // move to filecheck branch if yes
    adrp    x0, error_args                      // else print the argument error statement
    add     x0, x0, :lo12:error_args
    bl      printf
    b       closing                             // branch to closing to end program

filecheck:
    mov     w0, -100                            // try opening the input file
    ldr     x1, [valArg, 8]
    mov     w2, 0
    mov     w3, 0
    mov     x8, 56
    svc     0
    mov     file_desc, w0
    cmp     file_desc, 0
    b.ge    ifopened                            // move to ifopened branch if file opened successfully
    adrp    x0, error_file                      // else print the file error statement
    add     x0, x0, :lo12:error_file
    bl      printf
    b       closing                             // branch to closing to end program

ifopened:
    adrp    x0, prt_labels                      // print the heading lablers
    add     x0, x0, :lo12:prt_labels
    bl      printf
    add     buffer_base, fp, 16

calculate:
    mov     w0, file_desc                       // read contents of input file
    mov     x1, buffer_base
    mov     w2, 8
    mov     x8, 63
    svc     0
    mov     read_byte, x0
    cmp     read_byte, 8
    b.ne    cleanup
    ldr     d0, [buffer_base]                   // calculate the value of e^(x)
    bl      expansion
    fmov    d1, d0
    ldr     d0, [buffer_base]                   // calculate the value of e^(-x)
    fneg    d0, d0
    bl      expansion
    fmov    d2, d0
    adrp    x0, prt_values                      // print the input and calculated values
    add     x0, x0, :lo12:prt_values
    ldr     d0, [buffer_base]
    bl      printf
    b       calculate                           // loop for each input value of x

cleanup:
    mov     w0, file_desc                       // cleanup and close the file
    mov     x8, 57
    svc     0
    mov     w0, 0

closing:
    ldp     fp, lr, [sp], dealloc               // restore fp and lr
    ret                                         // return


expansion:                                      // compute function according to given series expansion
    stp     fp, lr, [sp, -16]!
    mov     fp, sp
    fmov    exponent, 1.0
    fmov    calc4, 1.0
    fmov    result, 1.0
    fmov    denominator, exponent
    fmov    numerator, d0                       // set input value of x as the numerator
    fdiv    fraction, numerator, denominator
    fadd    result, result, fraction
    adrp    x28, calc_limit                     // store the calculation limit constant (1.0e-10) to x28
    add     x28, x28, :lo12:calc_limit
    ldr     limitf, [x28]

accumulator:                                    // calculate the values for each fraction which will accumulate for final result
    fmul    numerator, numerator, d0
    fadd    exponent, exponent, calc4
    fmul    denominator, denominator, exponent
    fdiv    fraction, numerator, denominator
    fadd    result, result, fraction
    fabs    fraction, fraction
    fcmp    fraction, limitf                    // check if fraction term is within calculation limits
    b.ge    accumulator                         // if yes, loop back to continue series expansion
    fmov    d0, result                          // else return
    ldp     fp, lr, [sp], 16                    // restore fp and lr
    ret                                         // return