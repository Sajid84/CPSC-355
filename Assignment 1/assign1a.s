// CPSC 355 - Assignment 1
// part (a)

output1:	.string "value of x: %d\nvalue of y: %d\ncurrent minimum y value: %d\n\n"

	.balign 4
	.global main

main:
	stp 	x29, x30, [sp, -16]!
	mov 	x29, sp

	mov 	x19, 10000 	// minvalue = 10000
	mov 	x20, 0 		// x = 0
	mov 	x21, 0 		// y = 0
	mov 	x22, -10 	// setting loop counter to -10, to start from range of -10<=x<=4

loop:
	cmp 	x22, 4 		// comparing the loop counter with 4 as it's the end of range
	b.gt 	endLoop 	// once loop counter exceeds 4, the loop exits and goes to 'endLoop'

	// while loop code block

	mul	x23, x22, x22	// x23 = x * x = x^2
	mul	x23, x23, x22	// x23 = (x^2) * x = x^3
	mov	x24, 3		// x24 = 3
	mul	x25, x23, x24	// x25 = 3 * (x^3)
	mul	x23, x22, x22	// x23 = x * x = x^2
	mov	x24, 31		// x24 = 31
	mul	x24, x24, x23	// x24 = 31 * (x^2)
	add 	x25, x25, x24	// x25 = 3(x^3) + 31(x^2)
	mov	x23, -15	// x23 = -15
	mul	x23, x23, x22	// x23 = -15 * x = -15x
	add	x25, x25, x23	// x25 = 3(x^3) + 31(x^2) - 15x
	add	x25, x25, -127	// x25 = 3(x^3) + 31(x^2) - 15x - 127

	// the above code just formed the function
	// x25 register contains the value of y with each input of x (x22 register)

	cmp	x19, x25	// if minvalue > value, do body code
	b.le	next		// else move down to 'next' branch

	mov	x19, x25	// minvalue = value
	mov	x20, x22	// x = i
	mov	x21, x25	// y = value

	adrp	x0, output1	// bringing the output print statement into x0 register
	add	x0, x0, :lo12:output1	//bringing the last 12 bits of the print statement
	mov	x1, x22		// moving 'x' value into print statement
	mov	x2, x25		// moving 'y' value into print statement
	mov	x3, x19		// moving minimum y value into print statement

	bl	printf		// print the string with all values

	add	x22, x22, 1	// x += 1 (incrementing the loop counter by 1)

	b	loop

next:
	adrp	x0, output1	// bringing the output print statement into x0 register
	add	x0, x0, :lo12:output1	//bringing the last 12 bits of the print statement
	mov	x1, x22		// moving 'x' value into print statement
	mov	x2, x25		// moving 'y' value into print statement
	mov	x3, x19		// moving minimum y value into print statement

	bl	printf		// print the string with all values

	add	x22, x22, 1	// x += 1 (incrementing the loop counter by 1)

	b	loop

endLoop:
	ldp	x29, x30, [sp], 16
	ret
