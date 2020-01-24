ORG 0xC000

StartProgram
	mov R15, R14
        mov #0x0400, SP
        add R14, R13
        addc R14, R13
        sub R12, R11
        subc R12, R10
        cmp R4, R5
        dadd R6, R7
        bit R8, R9
        bic R10, R11
        bis R12, R13
        xor R14, R15
        and R14, R15

END
