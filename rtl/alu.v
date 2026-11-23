// ALU: арифметико-логическое устройство, 16 бит
// op совпадает с полем opcode инструкции
module alu (
    input  wire [15:0] a,
    input  wire [15:0] b,
    input  wire [3:0]  op,
    output reg  [15:0] y
);
    always @* begin
        case (op)
            4'b0001: y = a + b;              // ADD
            4'b0010: y = a - b;              // SUB
            4'b0011: y = a & b;              // AND
            4'b0100: y = a | b;              // OR
            4'b0101: y = a ^ b;              // XOR
            4'b0110: y = ~a;                 // NOT
            4'b0111: y = a << b[3:0];        // SHL
            4'b1000: y = a >> b[3:0];        // SHR
            default: y = 16'h0000;
        endcase
    end
endmodule
