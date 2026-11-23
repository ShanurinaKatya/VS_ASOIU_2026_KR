// Тестбенч: выполняет программу побитовой раскладки и проверяет RAM[0..15]
`timescale 1ns / 1ps
module tb_soc;
    localparam [15:0] N = 16'hACE1;   // входное число (константа в программе)

    reg clk = 1'b0;
    reg rst = 1'b1;
    wire halted;

    soc_top #(.ROM_FILE("sw/rom.mem")) dut (
        .clk    (clk),
        .rst    (rst),
        .halted (halted)
    );

    always #5 clk = ~clk;

    // выгрузка содержимого RAM в отдельные провода:
    // VCD-формат не хранит массивы памяти, GTKWave их не отображает
    wire [15:0] ram0  = dut.u_ram.mem[0];
    wire [15:0] ram1  = dut.u_ram.mem[1];
    wire [15:0] ram2  = dut.u_ram.mem[2];
    wire [15:0] ram3  = dut.u_ram.mem[3];
    wire [15:0] ram4  = dut.u_ram.mem[4];
    wire [15:0] ram5  = dut.u_ram.mem[5];
    wire [15:0] ram6  = dut.u_ram.mem[6];
    wire [15:0] ram7  = dut.u_ram.mem[7];
    wire [15:0] ram8  = dut.u_ram.mem[8];
    wire [15:0] ram9  = dut.u_ram.mem[9];
    wire [15:0] ram10 = dut.u_ram.mem[10];
    wire [15:0] ram11 = dut.u_ram.mem[11];
    wire [15:0] ram12 = dut.u_ram.mem[12];
    wire [15:0] ram13 = dut.u_ram.mem[13];
    wire [15:0] ram14 = dut.u_ram.mem[14];
    wire [15:0] ram15 = dut.u_ram.mem[15];

    integer i;
    reg [15:0] expected;
    integer errors;

    initial begin
        $dumpfile("sim/tb_soc.vcd");
        $dumpvars(0, tb_soc);

        repeat (4) @(posedge clk);
        rst = 1'b0;

        // ожидание завершения с защитой от зависания
        for (i = 0; i < 5000 && !halted; i = i + 1)
            @(posedge clk);

        if (!halted) begin
            $display("FAIL: процессор не остановился (HALT) за 5000 тактов");
            $finish;
        end

        errors = 0;
        $display("=====================================================");
        $display(" N = 16'h%h, процессор остановился (HALT)", N);
        $display(" i : RAM[i] | expected | (N>>i)&1");
        for (i = 0; i < 16; i = i + 1) begin
            expected = (N >> i) & 16'h0001;
            $display(" %2d:   %d    |    %d     |   %d",
                     i, dut.u_ram.mem[i], expected, (N >> i) & 1);
            if (dut.u_ram.mem[i] !== expected)
                errors = errors + 1;
        end
        $display("-----------------------------------------------------");
        if (errors == 0)
            $display(" PASS: все 16 бит в RAM[0..15] корректны");
        else
            $display(" FAIL: ошибок = %0d", errors);
        $display("=====================================================");
        $finish;
    end

    // трассировка PC (для отчёта / отладки)
    always @(posedge clk) begin
        if (!rst)
            $display("t=%0t PC=%0d instr=%b", $time, dut.u_cpu.pc, dut.u_cpu.rom_data);
    end
endmodule
