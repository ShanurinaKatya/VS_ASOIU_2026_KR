// CPU Core: одноцикловый процессор
// PC -> ROM -> Control Unit -> Register File -> ALU -> RAM / блок ветвлений
module cpu_core (
    input  wire        clk,
    input  wire        rst,
    output wire        halted,
    // интерфейс Instruction ROM
    output wire [7:0]  rom_addr,
    input  wire [15:0] rom_data,
    // интерфейс Data RAM
    output wire [5:0]  ram_addr,
    output wire [15:0] ram_wdata,
    output wire        ram_we,
    input  wire [15:0] ram_rdata
);
    // --- Program Counter ---
    reg  [7:0] pc;
    wire [7:0] pc_next;
    wire       halt_int;

    assign rom_addr = pc;
    assign halted   = halt_int;

    // --- Извлечение полей инструкции ---
    wire [15:0] instr     = rom_data;
    wire [3:0]  opcode    = instr[15:12];
    wire [2:0]  f_rd      = instr[11:9];
    wire [2:0]  f_rs      = instr[8:6];
    wire [2:0]  f_rt      = instr[5:3];
    wire [8:0]  imm9_raw  = instr[8:0];
    wire [5:0]  imm6_raw  = instr[5:0];
    wire [7:0]  jmp_addr  = instr[7:0];
    wire [5:0]  br_off    = instr[5:0];

    wire [15:0] imm9_sext = {{7{imm9_raw[8]}},  imm9_raw};
    wire [15:0] imm6_sext = {{10{imm6_raw[5]}}, imm6_raw};
    wire [15:0] off_sext  = {{10{br_off[5]}},   br_off};

    // --- Control Unit ---
    wire       reg_we, mem_re, mem_we, alu_b_imm;
    wire [1:0] wd_sel;
    wire       is_branch_eq, is_branch_ne, is_jump, is_halt;
    wire [3:0] alu_op;

    control_unit u_ctrl (
        .opcode       (opcode),
        .reg_we       (reg_we),
        .mem_re       (mem_re),
        .mem_we       (mem_we),
        .wd_sel       (wd_sel),
        .alu_b_imm    (alu_b_imm),
        .is_branch_eq (is_branch_eq),
        .is_branch_ne (is_branch_ne),
        .is_jump      (is_jump),
        .is_halt      (is_halt),
        .alu_op       (alu_op)
    );

    assign halt_int = is_halt;

    // --- Register File ---
    // порт1: rs (R-тип) / база (LOAD, STORE)
    // порт2: rt (R-тип) / данные STORE
    // порт3: rs ветвления (поле [11:9])
    wire [2:0]  raddr2 = (opcode == 4'b1011) ? f_rd : f_rt; // STORE: данные в [11:9]
    wire [15:0] rs_val, rt_val, rs_br_val;
    wire [15:0] wd_data;

    regfile u_rf (
        .clk    (clk),
        .rst    (rst),
        .we     (reg_we),
        .waddr  (f_rd),
        .wdata  (wd_data),
        .raddr1 (f_rs),
        .raddr2 (raddr2),
        .raddr3 (f_rd),
        .rdata1 (rs_val),
        .rdata2 (rt_val),
        .rdata3 (rs_br_val)
    );

    // --- ALU ---
    wire [15:0] alu_b = alu_b_imm ? imm6_sext : rt_val;
    wire [15:0] alu_y;

    alu u_alu (
        .a  (rs_val),
        .b  (alu_b),
        .op (alu_op),
        .y  (alu_y)
    );

    // --- Data RAM ---
    assign ram_addr  = alu_y[5:0];
    assign ram_wdata = rt_val;
    assign ram_we    = mem_we & ~rst & ~halt_int;

    // --- Мультиплексор записи в RF ---
    assign wd_data = (wd_sel == 2'b01) ? imm9_sext :
                     (wd_sel == 2'b10) ? ram_rdata : alu_y;

    // --- Выбор следующего PC ---
    wire branch_taken = (is_branch_eq && (rs_br_val == rs_val)) ||
                        (is_branch_ne && (rs_br_val != rs_val));
    // rs_br_val = regs[f_rd] (поле [11:9]), rs_val = regs[f_rs] (поле [8:6])

    assign pc_next = halt_int   ? pc :
                     is_jump    ? jmp_addr :
                     branch_taken ? (pc + 8'd1 + off_sext[7:0]) :
                                    (pc + 8'd1);

    always @(posedge clk) begin
        if (rst)
            pc <= 8'h00;
        else
            pc <= pc_next;
    end
endmodule
