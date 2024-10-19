// CPSC 355 - Assignment 1
// part (b)


define(minvalue, x19)	// setting a macro for the minimum value of y
define(count, x22) 	// setting a macro for the loop counter register
define(y_v, x25)	// setting a macro for the value of y at each loop iteration

output1:	.string "value of x: %d\nvalue of y: %d\ncurrent minimum y value: %d\n\n"

	.balign 4
	.global main

main:
	stp 	x29, x30, [sp, -16]!
	mov 	x29, sp

	mov 	minvalue, 10000 	// minvalue = 10000
	mov 	count, -10 		// setting loop counter to -10, to start from range of -10<=x<=4

	b	check

loop:
	mul	x23, count, count	// x23 = x * x = x^2
	mul	x23, x23, count		// x23 = (x^2) * x = x^3
	mov	x24, 3			// x24 = 3
	mul	y_v, x23, x24		// x25 = 3 * (x^3)
	mul	x23, count, count	// x23 = x * x = x^2
	mov	x24, 31			// x24 = 31
	mul	x24, x24, x23		// x24 = 31 * (x^2)
	add 	y_v, y_v, x24		// x25 = 3(x^3) + 31(x^2)
	mov	x23, -15		// x23 = -15
	mul	x23, x23, x22		// x23 = -15 * x = -15x
	add	y_v, y_v, x23		// x25 = 3(x^3) + 31(x^2) - 15x
	add	y_v, y_v, -127		// x25 = 3(x^3) + 31(x^2) - 15x - 127

	// the above code just formed the function
	// x25 register contains the value of y with each input of x (x22 register)

	cmp	minvalue, y_v		// if minvalue > y-value, do body code
	b.le	next			// else move down to 'next' branch

	mov	minvalue, y_v		// minvalue = y-value

next:
	adrp	x0, output1		// bringing the output print statement into x0 register
	add	x0, x0, :lo12:output1	//bringing the last 12 bits of the print statement
	mov	x1, count		// moving counter value into print statement
	mov	x2, y_v			// moving y value into print statement
	mov	x3, minvalue		// moving minimum y value into print statement

	bl	printf			// print the string with all values

	add	count, count, 1		// x += 1 (incrementing the loop counter by 1)

check:
	cmp 	count, 4 			// comparing the loop counter with 4 as it's the end of range
	b.le 	loop 			// once loop counter exceeds 4, the loop exits and goes to 'endLoop'

endLoop:
	ldp	x29, x30, [sp], 16
	ret
