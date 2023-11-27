.equ TIMER,     0x2020
.equ BUTTONS,   0x2030
.equ LEDS,      0x2000

_start:
br      main ; jump to the main function

interrupt_handler:

addi    sp,     sp,     -28; save the registers to the stack
sw      ra,     0(sp)
sw      t1,     4(sp)
sw      t2,     8(sp)
sw      t3,     12(sp)
sw      t4,     16(sp)
sw      t5,     20(sp)
sw      t6,     24(sp)

rdctl		t1,		status
beq		    t1,		zero,		return_from_exception

rdctl		t0,		ipending ; read the ipending register to identify the source
slli		t0,		t0,		29
blt		    t0,		zero,		buttons_routine ; call the corresponding routine
slli		t0,		t0,		2
blt		    t0,		zero,		timer_routine

br		return_from_exception

buttons_routine:

    addi    t2,      zero,   4
    addi    t3,      zero,   3
    wrctl	ienable,		t2

    lw      t0,     4+BUTTONS(zero)
    bge     t0,     t3,   return_from_exception

    sll		t0,		t0,		30
    blt		t0,		zero,		increment
    sll		t0,		t0,		1
    blt		t0,		zero,		decrement

    br return_from_exception
    
    increment:
    lw      t1,         LEDS(zero)
    addi    t1,         t1,   1
    sw      t1,         LEDS(zero)
    br		return_from_exception
    
    decrement:
    lw      t1,         LEDS(zero)
    addi    t1,         t1,   -1
    sw      t1,         4+LEDS(zero)
    br		return_from_exception

timer_routine:

    addi    t2,      zero,   5
    wrctl	ienable,		t2
    
    lw      t1,         4+LEDS(zero)
    addi    t1,         t1,   1
    sw      t1,         4+LEDS(zero)


return_from_exception:
    lw      ra,     0(sp) ; restore the registers from the stack
    lw      t1,     4(sp)
    lw      t2,     8(sp)
    lw      t3,     12(sp)
    lw      t4,     16(sp)
    lw      t5,     20(sp)
    lw      t6,     24(sp)
    addi    sp,     sp,     28
    
    addi    ea,     ea,     -4 ; correct the exception return address
    eret

main:

    addi		sp,		zero,		LEDS ; TODO: initialize stack
    
    addi		t0,		zero,		999
    stw		    t0,		TIMER+4(register)

    stw		zero,		LEDS(zero)
    stw		zero,		LEDS+4(zero)
    stw		zero,		LEDS+8(zero)

    addi		t0,		zero,		5
    wrctl	ienable,		t0
    
    counter_loop:
    lw      t1,         4+LEDS(zero)
    addi    t1,         t1,   1
    sw      t1,         4+LEDS(zero)
    br		counter_loop
    
; main procedure here