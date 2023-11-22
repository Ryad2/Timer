_start:
br main ; jump to the main function


interrupt_handler:

addi    sp,     sp,     -28; save the registers to the stack
sw      ra,     0(sp)
sw      t1,     4(sp)
sw      t2,     8(sp)
sw      t3,     12(sp)
sw      t4,     16(sp)
sw      t5,     20(sp)
sw      t6,     24(sp)


rdct ; read the ipending register to identify the source
; call the corresponding routine
; restore the registers from the stack

addi ea, ea, -4 ; correct the exception return address

eret ; return from exception

main:
; main procedure here