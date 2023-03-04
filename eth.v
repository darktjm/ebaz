`default_nettype none
`include "ebaz-eth.v"

module top(
  output wire LED_RED, LED_GREEN,
  output wire CLK25,
  `EBAZ_ETH_PORTS
);

  `EBAZ_ETH_VLOG
  
  /* SD boot expects LED_[RG] forwarded through FPGA GPIO[1:0] */
  `PS7_GPIO_WIRES();
  assign LED_RED = GPIOO[0];
  assign LED_GREEN = GPIOO[1];
  assign GPIOI[63:0] = 64'b0;

  // I have a 25MHz crystal, so this is untested/unneeded for me.
  // The default ebaz firmware uses a 125MHz clock on fclk[0], but seems to
  // have a 25MHz clock on fclk[1], so no PLL or divider is necessary,
  wire[3:0] fclk;
  assign CLK25 = fclk[1];

  PS7 arm (
      .FCLKCLK(fclk),
      `PS7_GPIO,
      `EBAZ_ETH_PS7
  );
endmodule
