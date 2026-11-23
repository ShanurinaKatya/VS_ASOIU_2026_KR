// Control Unit: декодер opcode -> управляющие сигналы
module control_unit (
    input  wire [3:0] opcode,
    output reg        reg_we,     // запись в регистровый файл
    output reg        mem_re,     // чтение RAM (для LOAD)
    output reg        mem_we,     // запись в RAM (для STORE)
    output reg [1:0]  wd_sel,     // мультиплексор данных на вход RF: 00=ALU, 01=imm9, 10=RAM
    output reg        alu_b_imm,  // 1: второй операнд ALU = imm6 (адресная арифметика)
    output reg        is_branch_eq,
    output reg        is_branch_ne,
    output reg        is_jump,
    output reg        is_halt,
    output reg  [3:0] alu_op
);
    localparam OP_NOP  = 4'b0000;
    localparam OP_ADD  = 4'b0001;
    localparam OP_SUB  = 4'b0010;
    localparam OP_AND  = 4'b0011;
    localparam OP_OR   = 4'b0100;
    localparam OP_XOR  = 4'b0101;
    localparam OP_NOT  = 4'b0110;
    localparam OP_SHL  = 4'b0111;
    localparam OP_SHR  = 4'b1000;
    localparam OP_LI   = 4'b1001;
    localparam OP_LOAD = 4'b1010;
    localparam OP_STORE= 4'b1011;
    localparam OP_BEQ  = 4'b1100;
    localparam OP_BNE  = 4'b1101;
    localparam OP_JUMP = 4'b1110;
    localparam OP_HALT = 4'b1111;

    always @* begin
        reg_we       = 1'b0;
        mem_re       = 1'b0;
        mem_we       = 1'b0;
        wd_sel       = 2'b00;
        alu_b_imm    = 1'b0;
        is_branch_eq = 1'b0;
        is_branch_ne = 1'b0;
        is_jump      = 1'b0;
        is_halt      = 1'b0;
        alu_op       = opcode;

        case (opcode)
            OP_ADD, OP_SUB, OP_AND, OP_OR, OP_XOR, OP_NOT, OP_SHL, OP_SHR: begin
                reg_we = 1'b1;
                wd_sel = 2'b00;
            end
            OP_LI: begin
                reg_we = 1'b1;
                wd_sel = 2'b01;
            end
            OP_LOAD: begin
                reg_we    = 1'b1;
                mem_re    = 1'b1;
                wd_sel    = 2'b10;
                alu_b_imm = 1'b1;
                alu_op    = OP_ADD;
            end
            OP_STORE: begin
                mem_we    = 1'b1;
                alu_b_imm = 1'b1;
                alu_op    = OP_ADD;
            end
            OP_BEQ:  is_branch_eq = 1'b1;
            OP_BNE:  is_branch_ne = 1'b1;
            OP_JUMP: is_jump      = 1'b1;
            OP_HALT: is_halt      = 1'b1;
            default: ; // NOP
        endcase
    end
endmodule
