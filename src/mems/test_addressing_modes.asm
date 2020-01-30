ORG 0xC000

StartProgram
	mov R15, R14            ; Register mode
        mov 0(R14), R13         ; Indexed mode (src)
        mov #0x0400, R12        ; Immediate mode
        decd R12                ; Trying a double decrement
        mov R11, 0(R12)         ; Indexed mode (dst)
        mov @R12, R10           ; Indirect register mode
        mov @R12+, R9           ; Indirect autoincrement mode
        mov #0x0500, R5         ; Immediate mode again
END
