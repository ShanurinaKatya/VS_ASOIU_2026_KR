RTL = rtl/alu.v rtl/regfile.v rtl/control_unit.v rtl/rom.v rtl/ram.v rtl/cpu_core.v rtl/soc_top.v
TB  = tb/tb_soc.v

.PHONY: sim wave clean

sim: sim/tb_soc.vvp
	vvp sim/tb_soc.vvp

sim/tb_soc.vvp: $(RTL) $(TB) sw/rom.mem
	iverilog -g2005 -o $@ $(RTL) $(TB)

wave: sim
	gtkwave -a sim/tb_soc.gtkw sim/tb_soc.vcd &

clean:
	rm -f sim/tb_soc.vvp sim/tb_soc.vcd
