# Timing constraints for f4pga.
# Supposedly Xilinx syntax, but it barfs on many simple things

# Main clock
create_clock -period 8 clk125 # bufg.O

# Free tools don't automatically derive clocks from PLL/MMCM
# These could technically be generated_clocks, but I don't think
# that's important.  But I really don't know what I'm doing.

# vid-pll
#	clk_pixel, // 74.25 (73.75) MHz
create_clock -period 13.468 clk_pixel # bufgpix.O
#	clk_shift  // 371.25 (368.75) MHz
create_clock -period 2.6936 clk_shift # bufgshift.O

# Ethernet clocks don't need special handling
#  Netlist Clock 'ENET0GMIIRXCLK' Fanout: 6 pins (0.1%), 6 blocks (0.3%)
#  Netlist Clock 'ENET0GMIITXCLK' Fanout: 6 pins (0.1%), 6 blocks (0.3%)
#  Netlist Clock '$abc$11985$iopadmap$CLK25' Fanout: 1 pins (0.0%), 1 blocks (0.1%)

# direct pll->bufg connections don't need special handling
#  Netlist Clock 'pll25.clk25' Fanout: 1 pins (0.0%), 1 blocks (0.1%)
#  Netlist Clock 'vpll.clk_pixel' Fanout: 1 pins (0.0%), 1 blocks (0.1%)
#  Netlist Clock 'vpll.clk_shift' Fanout: 1 pins (0.0%), 1 blocks (0.1%)

# direct pll feedback connections don't need special handling
#  Netlist Clock 'pll25._fbclk_' Fanout: 1 pins (0.0%), 1 blocks (0.1%)
#  Netlist Clock 'vpll._fbclk_' Fanout: 1 pins (0.0%), 1 blocks (0.1%)
