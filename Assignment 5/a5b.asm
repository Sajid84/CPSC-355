// CPSC 355 - Assignment 5
// Global Variables and Separate Compilation

// Setting all the prtResult strings to print
// Months
jan:        .string "January"
feb:        .string "February"
mar:        .string "March"
apr:        .string "April"
may:        .string "May"
jun:        .string "June"
jul:        .string "July"
aug:        .string "August"
sep:        .string "September"
oct:        .string "October"
nov:        .string "November"
dec:        .string "December"
// Suffixes
th:         .string "th"
st:         .string "st"
nd:         .string "nd"
rd:         .string "rd"
// Seasons
spring:     .string "Spring"
summer:     .string "Summer"
fall:       .string "Fall"
winter:     .string "Winter"
// Result and errors
usage:      .string "usage: a5b mm dd\n"
inputError: .string "Error: Invalid input\n"
dayError:   .string "Error: This month doesn't have this number of days\n"
result:     .string "%s %d%s is %s\n"

// Defining macros for various registers
// Arguments
define(numArg, w19)
define(arrArg, x20)
// User input
define(season, w23)
define(months, w21)
define(day, w22)
define(suffix, w24)
// Array base address
define(baseSeason, x26)
define(baseMonth, x25)
define(baseSuffix, x27)

// Create pointer arrays
arrMonth:  .dword jan, feb, mar, apr, may, jun, jul, aug, sep, oct, nov, dec
arrSeason: .dword winter, spring, summer, fall
arrSuffix: .dword th, st, nd, rd

    .text
    .balign 4           // align code instructions by 4 bytes
    .global main        // making main branch accessible to system

main:
    stp x29, x30, [sp, -16]!                // storing fp and lr to stack
    mov x29, sp                             // moving stack pointer to fp

    mov numArg, w0
    mov arrArg, x1

    cmp numArg, 3
    b.eq initialCheck
    adrp x0, usage
    add x0, x0, :lo12:usage
    bl printf
    b closing

initialCheck:
    mov suffix, 1
    ldr x0, [arrArg, suffix, SXTW 3]
    bl atoi
    mov months, w0
    mov suffix, 2
    ldr x0, [arrArg, suffix, SXTW 3]
    bl atoi
    mov day, w0
    cmp months, 0
    b.le input_error
    cmp months, 12
    b.gt input_error
    cmp day, 31
    b.gt input_error
    cmp day, 0
    b.le input_error
    b february

input_error:
    adrp x0, inputError
    add x0, x0, :lo12:inputError
    bl printf
    b closing

february:
    cmp months, 2
    b.ne checkMonth
    cmp day, 28
    b.gt day_error

checkMonth:
    cmp months, 4
    b.eq check
    cmp months, 6
    b.eq check
    cmp months, 9
    b.eq check
    cmp months, 11
    b.eq check
    b winter

checkDay:
    cmp day, 31
    b.ne winter

day_error:
    adrp x0, dayError
    add x0, x0, :lo12:dayError
    bl printf
    b closing

winter:
    cmp months, 2
    b.gt april_may
    mov season, 0
    b checkSuffix

april_may:
    cmp months, 4
    b.lt march
    cmp months, 5
    b.gt july_august
    mov season, 1
    b checkSuffix

july_august:
    cmp months, 7
    b.lt june
    cmp months, 8
    b.gt oct_nov
    mov season, 2
    b checkSuffix

oct_nov:
    cmp months, 10
    b.lt september
    cmp months, 11
    b.gt december
    mov season, 3
    b checkSuffix

march:
    mov season, 0
    cmp day, 20
    b.le checkSuffix
    mov season, 1
    b checkSuffix

june:
    mov season, 1
    cmp day, 20
    b.le checkSuffix
    mov season, 2
    b checkSuffix

september:
    mov season, 2
    cmp day, 20
    b.le checkSuffix
    mov season, 3
    b checkSuffix

december:
    mov season, 3
    cmp day, 20
    b.le checkSuffix
    mov season, 0

checkSuffix:
    // if day equals to (1, 21, or 31) move to suffix_st branch
    cmp day, 1
    b.eq suffix_st
    cmp day, 21
    b.eq suffix_st
    cmp day, 31
    b.eq suffix_st

    // if day equals to (2 or 22) move to suffix_nd branch
    cmp day, 2
    b.eq suffix_nd
    cmp day, 22
    b.eq suffix_nd

    // if day equals to (3 or 23) move to suffix_rd branch
    cmp day, 3
    b.eq suffix_rd
    cmp day, 23
    b.eq suffix_rd

    // if day not equal to any of the above, set suffix to 'th'
    mov suffix, 0
    b prtResult                             // move to prtResult branch
suffix_st:
    mov suffix, 1                           // set suffix to 'st'
    b prtResult                             // move to prtResult branch
suffix_nd:
    mov suffix, 2                           // set suffix to 'nd'
    b prtResult                             // move to prtResult branch
suffix_rd:
    mov suffix, 3                           // set suffix to 'rd'

prtResult:
    adrp baseMonth, arrMonth
    add baseMonth, baseMonth, :lo12:arrMonth
    adrp baseSeason, arrSeason
    add baseSeason, baseSeason, :lo12:arrSeason
    adrp baseSuffix, arrSuffix
    add baseSuffix, baseSuffix, :lo12:arrSuffix
    sub months, months, 1
    adrp x0, result
    add x0, x0, :lo12:result
    ldr x1, [baseMonth, months, SXTW 3]
    mov w2, day
    ldr x3, [baseSuffix, suffix, SXTW 3]
    ldr x4, [baseSeason, season, SXTW 3] 
    bl printf

closing:
    mov w0, 0
    ldp x29, x30, [sp], 16                  // restore fp and lr
    ret                                     // return
