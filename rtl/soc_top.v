// SoC top level: CPU + Instruction ROM + Data RAM
module soc_top #(
    parameter ROM_FILE = "sw/rom.mem"
) (
    input  wire clk,
    input  wire rst,
    output wire halted
);
    wire [7:0]  rom_addr;
    wire [15:0] rom_data;
    wire [5:0]  ram_addr;
    wire [15:0] ram_wdata;
    wire        ram_we;
    wire [15:0] ram_rdata;

    rom #(.ROM_FILE(ROM_FILE)) u_rom (
        .addr (rom_addr),
        .data (rom_data)
    );

    ram u_ram (
        .clk   (clk),
        .we    (ram_we),
        .addr  (ram_addr),
        .wdata (ram_wdata),
        .rdata (ram_rdata)
    );

    cpu_core u_cpu (
        .clk       (clk),
        .rst       (rst),
        .halted    (halted),
        .rom_addr  (rom_addr),
        .rom_data  (rom_data),
        .ram_addr  (ram_addr),
        .ram_wdata (ram_wdata),
        .ram_we    (ram_we),
        .ram_rdata (ram_rdata)
    );
endmodule
