.equ TIMER,     0x2020
.equ BUTTONS,   0x2030
.equ LEDS,      0x2000

_start:
br      main ; jump to the main function

interrupt_handler:

addi     sp,     sp,     -28; save the registers to the stack
stw      ra,     0(sp)
stw      t1,     4(sp)
stw      t2,     8(sp)
stw      t3,     12(sp)
stw      t4,     16(sp)
stw      t5,     20(sp)
stw      t6,     24(sp)

rdctl		t0,		ipending ; read the ipending register to identify the source
slli		t0,		t0,		29
blt		    t0,		zero,		buttons_routine ; call the corresponding routine
slli		t0,		t0,		2
blt		    t0,		zero,		timer_routine

br		return_from_exception

buttons_routine:

    addi    t3,      zero,   3
    ldw     t0,     4+BUTTONS(zero)
    stw		zero,	4+BUTTONS(zero)
    bge     t0,    t3,   return_from_exception

    slli		t0,		t0,		30
    blt		t0,		zero,		increment
    slli		t0,		t0,		1
    blt		t0,		zero,		decrement

    br return_from_exception
    
    increment:
    ldw      t1,         LEDS(zero)
    addi     t1,         t1,   1
    stw      t1,         LEDS(zero)
    br		return_from_exception
    
    decrement:
    ldw     t1,         LEDS(zero)
    addi    t1,         t1,   -1
    stw     t1,        LEDS(zero)
    br		return_from_exception

timer_routine:
    
    ldw      t1,         4+LEDS(zero)
    addi     t1,         t1,   1
    stw      t1,         4+LEDS(zero)

return_from_exception:

    ldw      ra,     0(sp) ; restore the registers from the stack
    ldw      t1,     4(sp)
    ldw      t2,     8(sp)
    ldw      t3,     12(sp)
    ldw      t4,     16(sp)
    ldw      t5,     20(sp)
    ldw      t6,     24(sp)
    addi     sp,     sp,     28
    
    addi    ea,     ea,     -4 ; correct the exception return address
    eret

main:

    addi		sp,		zero,		LEDS ; TODO: initialize stack
    
    addi		t0,		zero,		999
    stw		    t0,		TIMER+4(zero)

    stw		zero,		LEDS(zero)
    stw		zero,		LEDS+4(zero)
    stw		zero,		LEDS+8(zero)

    addi		t0,		zero,		1
    wrctl		status,		t0
    addi		t0,		zero,		5
    wrctl	    ienable,		t0
    
    
    counter_loop:
    ldw      t1,        8+LEDS(zero)
    addi     t1,        t1,   1
    stw      t1,        8+LEDS(zero)
    br		counter_loop
    
; main procedure here