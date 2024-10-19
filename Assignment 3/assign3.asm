// CPSC 355 - Assignment 3
// Sorting array using insertion sort

// Setting all the output strings to print
output1: .string "v[%d]: %d\n"
output2: .string "\nSorted Array:\n"
output3: .string "\nUnsorted Array:\n"

size        = 50        // set array size to 50
v_s         = 4 * size  // 4 bytes for each slot in the array being allocated (4 x 50 = 200 bytes)
i_s         = 4         // set integer i size to 4
j_s         = 4         // set integer j size to 4
temp_s      = 4         // set temp variable size to 4

// Allocating the memory
alloc       = -(16 + i_s + j_s + temp_s + v_s) & -16
dealloc     = -alloc

// Stack variable offsets from frame pointer
v_off       = 28        // array v will be offset by 28
i_off       = 16        // i will be offset by 16
j_off       = 20        // j will be offset by 20
temp_off    = 24        // temp will be offset by 24

// Defining the macros
define(base, x19)       // defining x19 as the base of the array
define(index, w22)      // defining w22 to use for loading index values (also loop counter)
define(temp, w21)       // defining w21 to hold temporary values

        .balign 4       // align code instructions by 4 bytes
        .global main    // making main branch accessible to system

main:
    stp x29, x30, [sp, alloc]!          // storing x29 and x30 (fp and lr) to stack
    mov x29, sp                         // moving stack pointer to x29
    add base, x29, v_off

    adrp x0, output3                    // bringing the output3 string into x0 register
    add x0, x0, :lo12:output3           // bringing the last 12 bits of print statement

    bl printf                           // print the output3 string

    mov index, 0                        // set index value to 0
    str index, [x29, i_off]             // store index value in fp, offset by i
    b firsttest                         // branch to firsttest

firstloop:
    bl rand                             // use built-in rand function to get a random number
    and temp, w0, 0xFF                  // AND the random number with 0xFF to get value within 0-255
    str temp, [base, index, SXTW 2]     // store temp value in array v

    adrp x0, output1                    // bringing the output1 string into x0 register
    add x0, x0, :lo12:output1           // bringing the last 12 bits of print statement
    mov w1, index                       // moving the index value into print statement
    ldr w2, [base, index, SXTW 2]       // moving the memory value into print statement

    bl printf                           // print the output1 string with all values

    add index, index, 1                 // incrementing the index value
    str index, [x29, i_off]             // store index value in fp, offset by i

firsttest:
    cmp index, size                     // comparing index value to array size
    b.lt firstloop                      // if index less than array size, branch back to firstloop

    mov index, 1                        // set index value to 1
    str index, [x29, i_off]             // store index value in fp, offset by i
    b secondtest                        // branch to secondtest

secondloop:
    ldr temp, [base, index, SXTW 2]     // load memory value into temp variable
    str temp, [x29, temp_off]           // store temp value in fp, offset by temp

    ldr index, [x29, i_off]             // load index value from fp, offset by j
    str index, [x29, j_off]             // store index value in fp, offset by j
    b thirdtest                         // branch to thirdtest

thirdloop:
    ldr index, [x29, j_off]             // load index value from fp, offset by j
    sub index, index, 1                 // decrementing index value
    ldr temp, [base, index, SXTW 2]     // load memory value into temp variable
    add index, index, 1                 // incrementing index value
    str temp, [base, index, SXTW 2]     // store temp value in array v
    sub index, index, 1                 // decrementing index value
    str index, [x29, j_off]             // store index value in fp, offset by j

thirdtest:
    ldr index, [x29, j_off]             // load index value from fp, offset by j
    cmp index, 0                        // comparing index value to 0
    b.le innerloop                      // if less than or equal to 0, branch to innerloop

    ldr temp, [x29, temp_off]           // load temp value from fp, offset by temp
    sub w22, index, 1                   // decrementing index value
    ldr w23, [base, w22, SXTW 2]        // load w22 array value into w23
    cmp w23, temp                       // comparing w23 with the temp value
    b.ge innerloop                      // if greater than or equal, then branch to innerloop
    b thirdloop                         // branch to thirdloop

innerloop:
    ldr index, [x29, temp_off]          // load index value from fp, offset by temp
    ldr temp, [x29, j_off]              // load temp value from fp, offset by j
    str index, [base, temp, SXTW 2]     // store index value in array v

    ldr index, [x29, i_off]             // load index value from fp, offset by i
    add index, index, 1                 // incrementing index value
    str index, [x29, i_off]             // store index value in fp, offset by i

secondtest:
    cmp index, size                     // comparing index value to array size
    b.lt secondloop                     // if index less than array size, branch back to secondloop

    adrp x0, output2                    // bringing the output2 string into x0 register
    add x0, x0, :lo12:output2           // bringing the last 12 bits of print statement

    bl printf                           // print the output2 string

    mov index, 0                        // set index value to 0
    str index, [x29, i_off]             // store index value in fp, offset by i
    b finaltest                         // branch to finaltest

finalloop:
    adrp x0, output1                    // bringing the output1 string into x0 register
    add x0, x0, :lo12:output1           // bringing the last 12 bits of print statement
    mov w1, index                       // moving the index value into print statement
    ldr w2, [base, index, SXTW 2]       // moving the memory value into print statement

    bl printf                           // print the output1 string with all values

    add index, index, 1                 // incrementing the index value
    str index, [x29, i_off]             // store index value in fp, offset by i

finaltest:
    cmp index, size                     // compareing index value to array size
    b.lt finalloop                      // if less than array size, branch back to finalloop

finish:                                 // finishing code by deallocating stack and return main
    mov w0, 0
    ldp x29, x30, [sp], dealloc
    ret