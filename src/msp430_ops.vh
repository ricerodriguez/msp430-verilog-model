// OPCODE DEFINITIONS
// Format I:
`define OP_MOV   4'h4
`define OP_ADD   4'h5
`define OP_ADDC  4'h6
`define OP_SUBC  4'h7
`define OP_SUB   4'h8
`define OP_CMP   4'h9
`define OP_DADD  4'hA
`define OP_BIT   4'hB
`define OP_BIC   4'hC
`define OP_BIS   4'hD
`define OP_XOR   4'hE
`define OP_AND   4'hF
// Format II:
`define OP_RRC   9'b0001_0000_0
`define OP_SWPB  9'b0001_0000_1
`define OP_RRA   9'b0001_0001_0
`define OP_SXT   9'b0001_0001_1
`define OP_PUSH  9'b0001_0010_0
`define OP_CALL  9'b0001_0010_1
`define OP_RETI  9'b0001_0011_0
// Format III (Jumps):
`define OP_JUMP  3'b001

// C Definitions (for Jumps)
`define C_JNE    3'b000
`define C_JNZ    3'b000
`define C_JEQ    3'b001
`define C_JZ     3'b001
`define C_JNC    3'b010
`define C_JC     3'b011
`define C_JN     3'b100
`define C_JGE    3'b101
`define C_JL     3'b110
`define C_JMP    3'b111

// FS Definitions
`define FS_MOV   6'b000000
`define FS_ADD   6'b000001
`define FS_ADDC  6'b001001
`define FS_SUB   6'b000110
`define FS_SUBC  6'b001110
`define FS_CMP   6'b000110
`define FS_DADD  6'b001001
`define FS_BIT   6'b010000
`define FS_BIC   6'b011000
`define FS_BIS   6'b010001
`define FS_XOR   6'b010010
`define FS_AND   6'b010000
`define FS_RRC   6'b100000
`define FS_RRA   6'b100001
`define FS_PUSH  6'b110000
`define FS_SWPB  6'b100010
`define FS_CALL  6'b110001
`define FS_RETI  6'b110010
`define FS_SXT   6'b100011


