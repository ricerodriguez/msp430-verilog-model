ORG 0xC000

StartProgram
        mov R3, R3              ; Nop
        mov #0x0400, SP         ; Initialize stack pointer
        mov #0x0300, R15        ; Initialize R15 with 0x0300
        push R15                ; Push R15 before we change it
        mov #0x0200, R14        ; Initialize R14 with 0x0200
        add R14, R15            ; Add the numbers
        pop R15                 ; Pop off the stack
        addc R12, R13           ;
        sub R10, R11
        subc R8, R9
        cmp R6, R7
        bit R4, R5
        bic R15, R14
        bis R13, R12
        xor R11, R10
        and R9, R8
        rrc R7, R6
        rra R5, R4
END
        
