# Timing constraints for f4pga.
# Supposedly Xilinx syntax, but it barfs on many simple things

# Main clock bufg.O
create_clock -period 8 clk125

# Free tools don't automatically derive clocks from PLL/MMCM
# These could technically be generated_clocks, but I don't think
# that's important.  But I really don't know what I'm doing.

# vid-pll
#	clk_pixel, // 74.25 (73.75) MHz bufgpix.O
create_clock -period 13.468 clk_pixel
#	clk_shift  // 371.25 (368.75) MHz
# Note: constraining clk_shift will cuase VPR to fail:
#Message: Can not find any logic block that can implement molecule.
#        Atom genblk1[1].ddr (ODDR_VPR) bufgshift.O
#create_clock -period 2.6936 clk_shift

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
