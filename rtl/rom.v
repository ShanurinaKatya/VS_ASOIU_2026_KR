// Instruction ROM: 256 x 16, чтение комбинаторное, загрузка через $readmemb
module rom #(
    parameter ROM_FILE = "sw/rom.mem"
) (
    input  wire [7:0]  addr,
    output wire [15:0] data
);
    reg [15:0] mem [0:255];
    integer k;

    initial begin
        for (k = 0; k < 256; k = k + 1)
            mem[k] = 16'h0000;      // NOP
        $readmemb(ROM_FILE, mem);
    end

    assign data = mem[addr];
endmodule
