// Регистровый файл: 8 x 16 бит, 3 комбинаторных порта чтения
// R0 аппаратно равен 0: сброс обнуляет всё, запись в адрес 0 игнорируется
module regfile (
    input  wire        clk,
    input  wire        rst,
    input  wire        we,
    input  wire [2:0]  waddr,
    input  wire [15:0] wdata,
    input  wire [2:0]  raddr1,
    input  wire [2:0]  raddr2,
    input  wire [2:0]  raddr3,
    output wire [15:0] rdata1,
    output wire [15:0] rdata2,
    output wire [15:0] rdata3
);
    reg [15:0] regs [0:7];
    integer i;

    always @(posedge clk) begin
        if (rst) begin
            for (i = 0; i < 8; i = i + 1)
                regs[i] <= 16'h0000;
        end else if (we && (waddr != 3'd0)) begin
            regs[waddr] <= wdata;
        end
    end

    assign rdata1 = regs[raddr1];
    assign rdata2 = regs[raddr2];
    assign rdata3 = regs[raddr3];
endmodule
