// CPSC 355 - Assignment 2
// Part (a)

// int macros defined below:
define(multiplier1, w20)	// multiplier1 register
define(multiplicand1, w21)	// multiplicand1 register
define(product1, w22)		// product1 register
define(flag, w26)		// flag register
define(boolean, w27)		// boolean (1 or 0) register
define(i, w19)			// loop counter assigned to w19

// long int macros defined below:
define(final, x23)		// final result register
define(var1, x24)		// register to store value 1
define(var2, x25)		// register to store value 2

// all the output string defined below:

output_1:	.string "multiplier = 0x%08x (%d) multiplicand = 0x%08x (%d)\n\n"
output_2:	.string "product = 0x%08x multiplier = 0x%08x \n"
output_3:	.string "64_bit result = 0x%016lx (%ld)\n"


            .balign 4
            .global main

main:       stp         x29, x30, [sp, -16]!
            mov         x29, sp

            mov         i, 0                       	// initialize loop counter to 0
            mov         multiplier1, 200		// initialize multiplier1 to given value
            mov         multiplicand1, 522133279	// initialize multiplicand1 to given value
            mov         product1, 0			// initialize product1 to 0
            mov         flag, 0				// initialize flag to 0

            adrp        x0, output_1                     // bringing the output_1 string into x0 register
            add         x0, x0, :lo12:output_1           // bringing the last 12 bits of the print statement
            mov         w1, multiplier1			// moving multiplier1 value into print statement
            mov         w2, multiplier1			// moving multiplier1 value into print statement
            mov         w3, multiplicand1		// moving multiplicand1 value into print statement
            mov         w4, multiplicand1		// moving multiplicand1 value into print statement

            bl          printf                          // print the string with all values


            cmp         multiplier1, 0			// check if multiplier1 is negative by comparing with 0
            b.ge        zero                        	// If multiplier1 >= 0, it will return zero
            mov         boolean, 1                  	// If it is one, make one/zero register to 1
            b           one

zero:      mov         boolean, 0                  	// If it is zero, make one/zero register to 0


one:
            b           check                       	// Branch to loop check at bottom

loopmain:
            ands        flag, multiplier1, 0x1
            b.eq        body                        	// If = 0, go to body
            add         product1, product1, multiplicand1


body:       // right shift the combined product1 & multiplier1
            asr         multiplier1, multiplier1, 1
            ands        flag, product1, 0x1
            b.eq        body1

            orr         multiplier1, multiplier1, 0x80000000
            b           skip

body1:      and         multiplier1, multiplier1, 0x7FFFFFFF



skip:       asr         product1, product1, 1

            add         i, i, 1               		// loop counter incremented


check:       cmp         i, 32				// check whether i (loop counter) less than 32
            b.lt        loopmain                             // If i >= 32, exits loop and jumps to "end" branch

end:        // Determine if multiplier1 is negative
            cmp         boolean, 0
            b.eq        else                      	// If boolean == 0 (false condition), branch to else
            sub         product1, product1, multiplicand1 	// run if it is one

else:       // Print out product1 and multiplier1
            adrp        x0, output_2                  	// bringing the output_2 string into the x0 register
            add         x0, x0, :lo12:output_2        	// bringing the last 12 bits of the print statement
            mov         w1, product1			// moving product1 value into print statement
            mov         w2, multiplier1			// moving multiplier1 value into print statement

            bl          printf                       	// print the string with all values

            // Combine product1 and multiplier1 together
            sxtw        x28, w22
            and         var1, x28, 0xFFFFFFFF
            lsl         var1, var1, 32
            sxtw        x28, w20
            and         var2, x28, 0xFFFFFFFF
            add         final, var1, var2

            // Print out 64-bit result
            adrp        x0, output_3                  	// bringing the output_3 string into the x0 register
            add         x0, x0, :lo12:output_3         	// bringing the last 12 bits of the print statement
            mov         x1, final			// moving the final result value into print statement
            mov         x2, final			// moving the final result value into print statement

            bl          printf                          // print the string with all values

            mov         w0, 0

            // finishing code with load pair and return instructions
            ldp         x29, x30, [sp], 16
            ret
