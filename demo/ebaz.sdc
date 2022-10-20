# Timing constraints for f4pga.
# Supposedly Xilinx syntax, but it barfs on that.
# I can't really figure out what it wants, so I'll skip the source clock
# create_clock -period 10 ebaz_collatz_text.ARM.FCLKCLK[0]
# Free tools don't automatically derive clocks from PLL/MMCM
# These could technically be generated_clocks, but I don't think
# that's important.  But I really don't know what I'm doing.
#create_clock -period 8 uart.clk # bufg.O
create_clock -period 8 vga2dvid_instance.clk_shift # clk125 = bufg.O
create_clock -period 40 vga_instance.clk_pixel # CLK25 = buf24.O
#create_clock -period 13.47 vga_instance.clk_pixel # bufgpix.O
#create_clock -period 2.69 vga2dvid_instance.clk_shift # bufgshift.O
#create_clock -period 40 pll25.clk25
