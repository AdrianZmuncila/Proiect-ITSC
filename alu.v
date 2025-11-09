
module alu (
    input  [15:0] A, B,          
    input  [5:0]  opcode,         // Cod operatie (6 biti)
    output reg [15:0] result,  
    output reg Z, N, C, O         // Flaguri: Zero, Negative, Carry, Overflow
);

    reg [16:0] tmp; // pentru detectare Carry/Overflow


localparam ADD    = 6'b000000;
localparam SUB    = 6'b000001;
localparam MUL    = 6'b000010;
localparam DIV    = 6'b000011;
localparam MOD    = 6'b000100;
localparam INC    = 6'b000101;
localparam DEC    = 6'b000110;
localparam AND_OP = 6'b000111;
localparam OR_OP  = 6'b001000;
localparam XOR_OP = 6'b001001;
localparam NOT_OP = 6'b001010;
localparam CMP    = 6'b001011;
localparam TST    = 6'b001100;
localparam MOV    = 6'b001101;
localparam LSL    = 6'b001110;
localparam LSR    = 6'b001111;
localparam RSL    = 6'b010000;
localparam RSR    = 6'b010001;
localparam BRZ    = 6'b010010;
localparam BRN    = 6'b010011;
localparam BRC    = 6'b010100;
localparam BRO    = 6'b010101;
localparam BRA    = 6'b010110;
localparam JMP    = 6'b010111;
localparam RET    = 6'b011000;

//====================================================
// Logica principala ALU
//====================================================
always @(*) begin
    result = 16'b0;
    C = 0; O = 0;

    case (opcode)
        // ------------------- ARITMETICE -------------------
        ADD: begin
            tmp = A + B;
            result = tmp[15:0];
            C = tmp[16];
            O = (~A[15] & ~B[15] & result[15]) | (A[15] & B[15] & ~result[15]);
        end

        SUB: begin
            tmp = A - B;
            result = tmp[15:0];
            C = (A < B);
            O = (A[15] & ~B[15] & ~result[15]) | (~A[15] & B[15] & result[15]);
        end

        MUL: result = A * B;
        DIV: result = (B != 0) ? A / B : 16'hFFFF;
        MOD: result = (B != 0) ? A % B : 16'hFFFF;
        INC: result = A + 1;
        DEC: result = A - 1;

        // ------------------- LOGICE -------------------
        AND_OP: result = A & B;
        OR_OP:  result = A | B;
        XOR_OP: result = A ^ B;
        NOT_OP: result = ~A;
        CMP: begin
            tmp = A - B;
            result = 0;
            C = (A < B);
            O = (A[15] & ~B[15] & ~tmp[15]) | (~A[15] & B[15] & tmp[15]);
        end
        TST: result = A & B;

        // ------------------- DEPLASARI / ROTIRI -------------------
        LSL: result = A << 1;
        LSR: result = A >> 1;
        RSL: result = {A[14:0], A[15]}; // rotire la stanga
        RSR: result = {A[0], A[15:1]};  // rotire la dreapta

        // ------------------- TRANSFER -------------------
        MOV: result = B;

        // ------------------- CONTROL / BRANCH -------------------
        BRZ: result = (Z == 1) ? 16'd1 : 16'd0;
        BRN: result = (N == 1) ? 16'd1 : 16'd0;
        BRC: result = (C == 1) ? 16'd1 : 16'd0;
        BRO: result = (O == 1) ? 16'd1 : 16'd0;
        BRA: result = 16'd1;
        JMP: result = B;          // adresa de salt
        RET: result = 16'hFFFF;   // cod simbolic pentru return

        default: result = 16'b0;
    endcase

    // --------- FLAGURI --------------
    Z = (result == 0);
    N = result[15];
end

endmodule
