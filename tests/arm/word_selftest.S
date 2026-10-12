.syntax unified
.arch armv7-a
.thumb
.text
.global _start
.type _start, %function
.thumb_func
_start:
        ldr r4, =word_test_vectors
        ldr r5, =word_test_vectors_end
        movs r6, #0
next_word_test:
        cmp r4, r5
        beq word_test_pass
        ldr r0, [r4, #0]
        ldr r1, [r4, #4]
        ldr r3, [r4, #12]
        blx r3
        sub sp, sp, #8
        str r0, [sp]
        movs r0, #1
        mov r1, sp
        movs r2, #4
        movs r7, #4
        svc #0
        cmp r0, #4
        bne word_write_fail
        ldr r0, [sp]
        add sp, sp, #8
        ldr r2, [r4, #8]
        cmp r0, r2
        bne word_test_fail
        adds r6, r6, #1
        adds r4, r4, #16
        b next_word_test
word_test_pass:
        cmp r6, #229
        bne word_test_fail
        movs r0, #0
        b word_test_exit
word_test_fail:
        movs r0, #43
        b word_test_exit
word_write_fail:
        add sp, sp, #8
        movs r0, #44
word_test_exit:
        movs r7, #1
        svc #0
.size _start, .-_start
.section .note.GNU-stack,"",%progbits
