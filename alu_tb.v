//====================================================
// Testbench complet pentru ALU 16-bit cu verificarea flagurilor
//====================================================
module alu_tb();

    reg [15:0] A, B;
    reg [5:0] opcode;
    wire [15:0] result;
    wire Z, N, C, O;

    alu uut (
        .A(A),
        .B(B),
        .opcode(opcode),
        .result(result),
        .Z(Z),
        .N(N),
        .C(C),
        .O(O)
    );

    initial begin
        $display("==== TEST ALU COMPLET CU FLAGURI ====");

        // ---------- Aritmetice ----------
        A=12; B=8; opcode=6'b000000; #10;
        $display("ADD: %d + %d = %d | Z=%b N=%b C=%b O=%b", A,B,result,Z,N,C,O);

        A=20; B=5; opcode=6'b000001; #10;
        $display("SUB: %d - %d = %d | Z=%b N=%b C=%b O=%b", A,B,result,Z,N,C,O);

        A=7; B=6; opcode=6'b000010; #10;
        $display("MUL: %d * %d = %d | Z=%b N=%b", A,B,result,Z,N);

        A=40; B=5; opcode=6'b000011; #10;
        $display("DIV: %d / %d = %d | Z=%b N=%b", A,B,result,Z,N);

        A=41; B=8; opcode=6'b000100; #10;
        $display("MOD: %d %% %d = %d | Z=%b N=%b", A,B,result,Z,N);

        A=9; opcode=6'b000101; #10;
        $display("INC: %d -> %d | Z=%b N=%b", A,result,Z,N);

        A=9; opcode=6'b000110; #10;
        $display("DEC: %d -> %d | Z=%b N=%b", A,result,Z,N);

        // ---------- Logice ----------
        A=12; B=10; opcode=6'b000111; #10;
        $display("AND: %d & %d = %d (bin=%016b) | Z=%b N=%b", A,B,result,result,Z,N);

        A=12; B=10; opcode=6'b001000; #10;
        $display("OR:  %d | %d = %d (bin=%016b) | Z=%b N=%b", A,B,result,result,Z,N);

        A=12; B=10; opcode=6'b001001; #10;
        $display("XOR: %d ^ %d = %d (bin=%016b) | Z=%b N=%b", A,B,result,result,Z,N);

        A=71; opcode=6'b001010; #10;
        $display("NOT: A=%d -> %d (bin=%016b) | Z=%b N=%b", A,result,result,Z,N);

        A=15; B=20; opcode=6'b001011; #10;
        $display("CMP: A=%d, B=%d -> Z=%b N=%b C=%b O=%b", A,B,Z,N,C,O);

        A=12; B=10; opcode=6'b001100; #10;
        $display("TST: A=%d, B=%d -> Result=%d | Z=%b N=%b", A,B,result,Z,N);

        // ---------- Transfer ----------
        B=55; opcode=6'b001101; #10;
        $display("MOV: B=%d -> A=%d | Z=%b N=%b", B,result,Z,N);

        // ---------- Deplasari / Rotiri ----------
        A=71; opcode=6'b001110; #10;
        $display("LSL: A=%d -> %d (bin=%016b) | Z=%b N=%b", A,result,result,Z,N);

        A=71; opcode=6'b001111; #10;
        $display("LSR: A=%d -> %d (bin=%016b) | Z=%b N=%b", A,result,result,Z,N);

        A=71; opcode=6'b010000; #10;
        $display("RSL: A=%d -> %d (bin=%016b) | Z=%b N=%b", A,result,result,Z,N);

        A=71; opcode=6'b010001; #10;
        $display("RSR: A=%d -> %d (bin=%016b) | Z=%b N=%b", A,result,result,Z,N);

        // ---------- Branch / Control ----------
        // CMP seteaza flagurile pentru urmatoarele teste
        A=15; B=20; opcode=6'b001011; #10;
        $display("\nFlaguri actuale dupa CMP: Z=%b N=%b C=%b O=%b\n", Z,N,C,O);

        opcode=6'b010010; #10; $display("BRZ: Z=%b -> result=%d", Z,result);
        opcode=6'b010011; #10; $display("BRN: N=%b -> result=%d", N,result);
        opcode=6'b010100; #10; $display("BRC: C=%b -> result=%d", C,result);
        opcode=6'b010101; #10; $display("BRO: O=%b -> result=%d", O,result);
        opcode=6'b010110; #10; $display("BRA: Always branch -> result=%d", result);
        B=1024; opcode=6'b010111; #10; $display("JMP: Jump to address %d", result);
        opcode=6'b011000; #10; $display("RET: Return instruction -> result=%h", result);

        $display("==== TEST FINALIZAT ====");
        $finish;
    end

endmodule


/*

ADD  - Aduna valorile din A si B -> A + B
SUB  - Scade valoarea lui B din A -> A - B
MUL  - Inmulteste A cu B -> A * B
DIV  - Imparte A la B -> A / B (daca B != 0)
MOD  - Returneaza restul impartirii -> A % B
INC  - Incrementeaza valoarea lui A cu 1 -> A + 1
DEC  - Decrementeaza valoarea lui A cu 1 -> A - 1

AND  - "SI" logic bit cu bit -> rezultatul e 1 doar daca ambii biti sunt 1
OR   - "SAU" logic bit cu bit -> rezultatul e 1 daca cel putin un bit e 1
XOR  - "SAU exclusiv" -> rezultatul e 1 doar daca bitii difera
NOT  - Inverseaza toti bitii lui A (1 devine 0, 0 devine 1)
CMP  - Compara A si B (seteaza flagurile Z, N, C, O fara rezultat direct)
TST  - Testeaza bitii comuni (A & B) fara modificarea registrelor



LSL  - Logical Shift Left -> deplaseaza bitii la stanga, adauga 0 la dreapta
LSR  - Logical Shift Right -> deplaseaza bitii la dreapta, adauga 0 la stanga
RSL  - Rotate Shift Left -> roteste bitii la stanga (MSB revine pe LSB)
RSR  - Rotate Shift Right -> roteste bitii la dreapta (LSB revine pe MSB)



MOV  - Copiaza valoarea din B in A -> A <- B


BRZ - Branch if Zero        -> Sari daca flagul Z = 1
BRN - Branch if Negative    -> Sari daca flagul N = 1
BRC - Branch if Carry       -> Sari daca flagul C = 1
BRO - Branch if Overflow    -> Sari daca flagul O = 1
BRA - Branch Always         -> Sari neconditionat
JMP - Jump / Call Procedure -> Sari la adresa specificata in B
RET - Return from Procedure -> Revenire la adresa salvata



*/
