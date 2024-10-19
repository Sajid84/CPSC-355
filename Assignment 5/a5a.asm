// CPSC 355 - Assignment 5
// Global Variables and Separate Compilation

// Setting all the output strings to print
prt_overflow:       .string "\nQueue overflow! Cannot enqueue into a full queue.\n"
prt_underflow:      .string "\nQueue underflow! Cannot dequeue from an empty queue.\n"
prt_contents:       .string "\nCurrent queue contents:\n"
prt_empty:          .string "\nEmpty queue\n"
prt_head:           .string " <-- head of queue"
prt_tail:           .string " <-- tail of queue"
prt_line:           .string "\n"
prt_format:         .string " %d"

define(QUEUESIZE, 8)
define(MODMASK, 0x7)
define(FALSE, 0)
define(TRUE, 1)

.data
        head: .word -1
        tail: .word -1
.bss
        queue: .skip QUEUESIZE * 4
.text


// Macros defined for each of the 5 functions
// enqueue()
define(enValue, w9)
define(enTail, w10)
// dequeue()
define(deValue, w11)
define(deHead, w12)
define(deTail, w13)
// queueFull()
define(fullHead, w14)
define(fullTail, w15)
// queueEmpty()
define(emptyHead, w19)
// display()
define(displayI, w20)
define(displayJ, w21)
define(displayCount, w22)
define(displayTail, w23)
define(displayHead, w24)
define(displayBase, x25)


        .balign 4               // align code instructions by 4 bytes
        .global enqueue         // making enqueue() function accessible to system
        .global dequeue         // making dequeue() function accessible to system
        .global queueFull       // making queueFull() function accessible to system
        .global queueEmpty      // making queueEmpty() function accessible to system
        .global display         // making display() function accessible to system

define(fp, x29)
define(lr, x30)

enqueue:
    stp fp, lr, [sp, -16]!                                              // storing fp and lr to stack
    mov fp, sp                                                          // moving stack pointer to fp
    mov enValue, w0                                                     // store function parameter in w0
    bl queueFull                                                        // check that queue isn't full using queueFull function
    cmp w0, TRUE                                                        // check whether queueFull returns true
    b.ne enqueue2                                                       // if not full, move to enqueue2
    adrp x0, prt_overflow                                               // if full, print overflow statement
    add x0, x0, :lo12:prt_overflow                                      // bring the last 12 bits
    bl printf                                                           // call print function to print
    b enqueueClose                                                      // then move to enqueueClose and end function

enqueue2:
    bl queueEmpty                                                       // check if queue is empty using queueEmpty function
    cmp w0, TRUE                                                        // check whether queueEmpty returns true
    b.ne enqueue3                                                       // if not empty, move to enqueue3
    adrp displayBase, head                                              // add the head's address into base array
    add displayBase, displayBase, :lo12:head                            // bring the last 12 bits
    str wzr, [displayBase]
    adrp displayBase, tail                                              // add the tail's address into base array
    add displayBase, displayBase, :lo12:tail                            // bring the last 12 bits
    str wzr, [displayBase]                                              // Sets tail = 0
    b enqueue4                                                          // move to enqueue4 branch

enqueue3:
    adrp displayBase, tail                                              // add the tail's address into base array
    add displayBase, displayBase, :lo12:tail                            // bring the last 12 bits
    ldr enTail, [displayBase]                                           // load the tail's value into enTail
    add enTail, enTail, 1                                               // increment enTail by 1
    and enTail, enTail, MODMASK                                         // enTail = (entail && modmask)
    str enTail, [displayBase]                                           // store new tail value back into displayBase

enqueue4:
    ldr enTail, [displayBase]                                           // load the tail's value into enTail
    adrp displayBase, queue                                             // add the queue's address into base array
    add displayBase, displayBase, :lo12:queue                           // bring the last 12 bits
    str enValue, [displayBase, enTail, SXTW 2]

enqueueClose:
    ldp fp, lr, [sp], 16                                                // restore fp and lr
    ret                                                                 // return


dequeue:
    stp fp, lr, [sp, -16]!                                              // storing fp and lr to stack
    mov fp, sp                                                          // moving stack pointer to fp
    bl queueEmpty                                                       // check if queue is empty using queueEmpty function
    cmp w0, TRUE                                                        // check whether queueEmpty returns true
    b.ne dequeue2                                                       // if not empty, move to dequeue2
    adrp x0, prt_underflow                                              // if empty, print underflow statment
    add x0, x0, :lo12:prt_underflow                                     // bring the last 12 bits
    bl printf                                                           // call print function to print
    mov w0, -1                                                          // store -1 as the return value in w0
    b dequeueClose                                                      // move to dequeueClose and end function

dequeue2:
    adrp displayBase, head                                              // add the head's address into base array
    add displayBase, displayBase, :lo12:head                            // bring the last 12 bits
    ldr deHead, [displayBase]                                           // load the head's value into deHead
    adrp displayBase, tail                                              // add the tail's address into base array
    add displayBase, displayBase, :lo12:tail                            // bring the last 12 bits
    ldr deTail, [displayBase]                                           // load the tail's value into deTail
    adrp displayBase, queue                                             // add the queue's address into base array
    add displayBase, displayBase, :lo12:queue                           // bring the last 12 bits
    ldr deValue, [displayBase, deHead, SXTW 2]
    cmp deHead, deTail                                                  // compare head and tail values
    b.ne dequeue3                                                       // if not equal, move to dequeue3
    mov w28, -1                                                         // if equal, store -1 value in w28
    adrp displayBase, head                                              // add the head's address into base array
    add displayBase, displayBase, :lo12:head                            // bring the last 12 bits
    str w28, [displayBase]                                              // store -1 as head value in displayBase
    adrp displayBase, tail                                              // add the tail's address into base array
    add displayBase, displayBase, :lo12:tail                            // bring the last 12 bits
    str w28, [displayBase]                                              // store -1 as tail value in displayBase
    b dequeue4                                                          // move to dequeue4 branch

dequeue3:
    add deHead, deHead, 1                                               // increment deHead by 1
    and deHead, deHead, MODMASK                                         // deHead = (deHead && modmask)
    adrp displayBase, head                                              // add the head's address into base array
    add displayBase, displayBase, :lo12:head                            // bring the last 12 bits
    str deHead, [displayBase]                                           // store new head value back into displayBase

dequeue4:
    mov w0, deValue                                                     // store deValue as the return value in w0

dequeueClose:
    ldp fp, lr, [sp], 16                                                // restore fp and lr
    ret                                                                 // return


queueFull:
    stp fp, lr, [sp, -16]!                                              // storing fp and lr to stack
    mov fp, sp                                                          // moving stack pointer to fp
    adrp displayBase, tail                                              // add the tail's address into base array
    add displayBase, displayBase, :lo12:tail                            // bring the last 12 bits
    ldr fullTail, [displayBase]                                         // load the tail's value into fullTail
    add fullTail, fullTail, 1                                           // increment fullTail by 1
    and fullTail, fullTail, MODMASK                                     // fullTail = (fullTail && modmask)
    adrp displayBase, head                                              // add the head's address into base array
    add displayBase, displayBase, :lo12:head                            // bring the last 12 bits
    ldr fullHead, [displayBase]                                         // load the head's value in fullHead
    mov w0, TRUE                                                        // set return value to true in w0
    cmp fullTail, fullHead                                              // compare fullTail and fullHead value
    b.eq queueFullClose                                                 // if both values are equal, move to queueFullClose
    mov w0, FALSE                                                       // if not equal, set return value to false in w0

queueFullClose:
    ldp fp, lr, [sp], 16                                                // restore fp and lr
    ret                                                                 // return


queueEmpty:
    stp fp, lr, [sp, -16]!                                              // storing fp and lr to stack
    mov fp, sp                                                          // moving stack pointer to fp
    adrp displayBase, head                                              // add the head's address into base array
    add displayBase, displayBase, :lo12:head                            // bring the last 12 bits
    mov w0, TRUE                                                        // set return value to true in w0
    ldr emptyHead, [displayBase]                                        // load the head's value into emptyHead
    cmp emptyHead, -1                                                   // check if emptyHead value is equal to -1
    b.eq queueEmptyClose                                                // if equal, move to queueEmptyClose branch
    mov w0, FALSE                                                       // if not equal, set return value to false in w0

queueEmptyClose:
    ldp fp, lr, [sp], 16                                                // restore fp and lr
    ret                                                                 // return


display:
    stp fp, lr, [sp, -16]!                                              // storing fp and lr to stack
    mov fp, sp                                                          // moving stack pointer to fp
    bl queueEmpty                                                       // check if queue is empty using queueEmpty function
    cmp w0, TRUE                                                        // check whether queueEmpty returns true
    b.ne display2                                                       // if not empty, move to display2
    adrp x0, prt_empty                                                  // if empty, print the 'empty queue' statement
    add x0, x0, :lo12:prt_empty                                         // bring the last 12 bits
    bl printf                                                           // call print function to print
    b displayClose                                                      // then move to displayClose and end function

display2:
    adrp displayBase, head                                              // add the head's address into base array
    add displayBase, displayBase, :lo12:head                            // bring the last 12 bits
    ldr displayHead, [displayBase]                                      // load the head's value into displayHead
    adrp displayBase, tail                                              // add the tail's address into base array
    add displayBase, displayBase, :lo12:tail                            // bring the last 12 bits
    ldr displayTail, [displayBase]                                      // load the tail's value into displayTail
    sub displayCount, displayTail, displayHead                          // displayCount = (displayTail - displayHead)
    add displayCount, displayCount, 1                                   // increment displayCount by 1
    cmp displayCount, 0                                                 // compare displayCount value with 0
    b.gt display3                                                       // if greater than 0, move to display3
    add displayCount, displayCount, QUEUESIZE                           // else, add QUEUESIZE to displayCount

display3:
    adrp x0, prt_contents                                               // print the 'queue contents' statement
    add x0, x0, :lo12:prt_contents                                      // bring the last 12 bits
    bl printf                                                           // call print function to print
    mov displayI, displayHead                                           // store displayHead value in displayI
    mov displayJ, 0                                                     // store 0 in displayJ
    b loopCheck                                                         // move to loopCheck branch

loop:
    adrp x0, prt_format                                                 // print the string format character
    add x0, x0, :lo12:prt_format                                        // bring the last 12 bits
    adrp displayBase, queue                                             // add the queue's address into base array
    add displayBase, displayBase, :lo12:queue                           // bring the last 12 bits
    ldr w1, [displayBase, displayI, SXTW 2]
    bl printf                                                           // call print function to print
    cmp displayI, displayHead                                           // compate displayI and displayHead values
    b.ne loop2                                                          // if not equal, branch to loop2
    adrp x0, prt_head                                                   // if equal, print the 'head of queue' statement
    add x0, x0, :lo12:prt_head                                          // bring the last 12 bits
    bl printf                                                           // call print function to print

loop2:
    cmp displayI, displayTail                                           // compare displayI and displayTail values
    b.ne loopClose                                                      // if not equal, move to loopClose
    adrp x0, prt_tail                                                   // if equal, print the 'tail of queue' statement
    add x0, x0, :lo12:prt_tail                                          // bring the last 12 bits
    bl printf                                                           // call print function to print

loopClose:
    adrp x0, prt_line                                                   // print the new line character
    add x0, x0, :lo12:prt_line                                          // bring the last 12 bits
    bl printf                                                           // call print function to print
    add displayI, displayI, 1                                           // increment displayI by 1
    and displayI, displayI, MODMASK                                     // displayI = (displayI && modmask)
    add displayJ, displayJ, 1                                           // increment displayJ by 1

loopCheck:
    cmp displayJ, displayCount                                          // compare displayJ and displayCount values
    b.lt loop                                                           // if display J is less than displayCount, move back to loop branch

displayClose:
    ldp fp, lr, [sp], 16                                                // restore fp and lr
    ret                                                                 // return