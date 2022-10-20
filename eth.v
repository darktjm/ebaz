`default_nettype none
`include "ebaz-eth.v"

module top(
  output wire CLK25,
  `EBAZ_ETH_Ports
);

  `EBAZ_ETH_VLOG

  // I have a 25MHz crystal, so this is untested/unneeded for me.
  // The default ebaz firmware uses a 125MHz clock.
  // A /5 BUFR would probably be less expensive, but is unsupported by
  // the free toolchain, as far as I can tell.
  wire[3:0] fclk;
  pll pll25 (.fclk(fclk[0]), .clk25(CLK25));

  PS7 arm (
      .FCLKCLK(fclk),
      `EBAZ_ETH_PS7
  );
endmodule
