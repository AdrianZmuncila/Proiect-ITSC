
// Decodifica opcode-ul si genereaza semnale de control
// pentru ALU, registre, memorie si salturi.
//
// Suporta: instructiuni aritmetice, logice, deplasare,
// transfer, branch si jump.
//


module control_unit (
    input wire clk,
    input wire reset,

    // Intrari
    input wire [5:0] opcode,      // codul operatiei din instructiune
    input wire Z, N, C, O,        // flaguri de la ALU

    // Semnale de iesire (control)
    output reg alu_enable,        // activeaza ALU-ul
    output reg reg_write,         // permite scrierea in registru
    output reg mem_read,          // citire din memorie
    output reg mem_write,         // scriere in memorie
    output reg pc_enable,         // activeaza incrementarea PC
    output reg branch_taken,      // indica daca se face salt
    output reg [1:0] alu_src,     // sursa pentru ALU (00: reg, 01: immediate, 10: mem)
    output reg [2:0] state        // starea curenta FSM
);


    // DEFINIREA STARILOR FSM
   
    localparam FETCH   = 3'b000;
    localparam DECODE  = 3'b001;
    localparam EXECUTE = 3'b010;
    localparam BRANCH  = 3'b011;
    localparam HALT    = 3'b111;

    // REGISTRE INTERNE

    reg [2:0] next_state;

 
    // FSM: STARE URMATOARE
 
    always @(posedge clk or posedge reset) begin
        if (reset)
            state <= FETCH;
        else
            state <= next_state;
    end

  
    // LOGICA DE CONTROL PRINCIPALA
    
    always @(*) begin
    
        alu_enable   = 0;
        reg_write    = 0;
        mem_read     = 0;
        mem_write    = 0;
        pc_enable    = 0;
        branch_taken = 0;
        alu_src      = 2'b00;
        next_state   = FETCH;

        case (state)
         
            // FETCH: citeste instructiunea
    
            FETCH: begin
                pc_enable  = 1;           // PC -> +1
                next_state = DECODE;
            end

          
            // DECODE: decodifica opcode
          
            DECODE: begin
                alu_enable = 1;
                next_state = EXECUTE;
            end

     
            // EXECUTE: in functie de opcode
         
            EXECUTE: begin
                case (opcode)
                    // Aritmetice
                    6'b000000, 6'b000001, 6'b000010, 6'b000011,
                    6'b000100, 6'b000101, 6'b000110: begin
                        alu_enable = 1;
                        reg_write  = 1;
                        next_state = FETCH;
                    end

                    // Logice
                    6'b000111, 6'b001000, 6'b001001, 6'b001010,
                    6'b001011, 6'b001100: begin
                        alu_enable = 1;
                        reg_write  = 1;
                        next_state = FETCH;
                    end

                    // TRANSFER
                    6'b001101: begin // MOV
                        alu_enable = 1;
                        reg_write  = 1;
                        next_state = FETCH;
                    end

                    // Deplasari / Rotiri
                    6'b001110, 6'b001111, 6'b010000, 6'b010001: begin
                        alu_enable = 1;
                        reg_write  = 1;
                        next_state = FETCH;
                    end

                    // Salturi conditionate
                    6'b010010: begin // BRZ
                        if (Z) branch_taken = 1;
                        next_state = BRANCH;
                    end

                    6'b010011: begin // BRN
                        if (N) branch_taken = 1;
                        next_state = BRANCH;
                    end

                    6'b010100: begin // BRC
                        if (C) branch_taken = 1;
                        next_state = BRANCH;
                    end

                    6'b010101: begin // BRO
                        if (O) branch_taken = 1;
                        next_state = BRANCH;
                    end

                    6'b010110: begin // BRA (always)
                        branch_taken = 1;
                        next_state = BRANCH;
                    end

                    6'b010111: begin // JMP
                        branch_taken = 1;
                        next_state = BRANCH;
                    end

                    6'b011000: begin // RET
                        branch_taken = 1;
                        next_state = BRANCH;
                    end

                    default: begin
                        next_state = FETCH;
                    end
                endcase
            end

        
            // BRANCH: actualizeaza PC
          
            BRANCH: begin
                if (branch_taken)
                    pc_enable = 1;
                next_state = FETCH;
            end

         
            // HALT: oprire (optional)
         
            HALT: begin
                alu_enable = 0;
                reg_write  = 0;
                pc_enable  = 0;
                next_state = HALT;
            end
        endcase
    end

endmodule

// iverilog -o alu_test alu.v control_unit.v alu_tb.v
// vvp alu_test