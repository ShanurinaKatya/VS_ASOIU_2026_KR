// Data RAM: 64 x 16, чтение комбинаторное, запись синхронная
module ram (
    input  wire        clk,
    input  wire        we,
    input  wire [5:0]  addr,
    input  wire [15:0] wdata,
    output wire [15:0] rdata
);
    reg [15:0] mem [0:63];

    assign rdata = mem[addr];

    always @(posedge clk) begin
        if (we)
            mem[addr] <= wdata;
    end
endmodule
