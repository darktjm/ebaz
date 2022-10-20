`ifndef EBAZ_ETH_V
`define EBAZ_ETH_V

`include "zynq-ps7.v"
// Does not include setting CLK25 to 25MHz if xtal not present
// (no way to really tell if it's necessary, so I'd have to always generate it)

// Does not include ENET0 config such as 100Mbit mode and clock (25MHz
// instead of 125, presumably).
`define EBAZ_ETH_Ports \
inout wire ETH_MDIO, \
input wire ETH_RXCLK, ETH_TXCLK, ETH_RXDV, \
input wire [3:0] ETH_RXD, \
output wire [3:0] ETH_TXD, \
output wire ETH_TXEN, ETH_MDC

`define EBAZ_ETH_VLOG \
  `PS7_ENET_WIRES(0); \
  /* PS7 IP has hidden registers */ \
  reg [3:0] ETH_RXD_reg; \
  reg ETH_RXDV_reg; \
  reg [3:0] ETH_TXD_reg; \
  reg ETH_TXEN_reg; \
  assign ETH_TXD = ETH_TXD_reg; \
  assign ETH_TXEN = ETH_TXEN_reg; \
  always @(posedge ETH_RXCLK) begin \
    ETH_RXD_reg <= ETH_RXD; \
    ETH_RXDV_reg <= ETH_RXDV; \
  end \
  always @(posedge ETH_TXCLK) begin \
    ETH_TXD_reg <= ENET0GMIITXD[3:0]; \
    ETH_TXEN_reg <= ENET0GMIITXEN; \
  end \
  assign \
    ENET0GMIIRXD[3:0] = ETH_RXD_reg, \
    ENET0GMIIRXD[7:4] = 4'h0, \
    ENET0GMIIRXCLK = ETH_RXCLK, \
    ENET0GMIIRXDV = ETH_RXDV_reg, \
    ENET0GMIITXCLK = ETH_TXCLK, \
    ETH_MDC = ENET0MDIOMDC, \
    /* Defaults from cells_map.v */ \
    ENET0GMIICOL = 1'b0, \
    ENET0GMIICRS = 1'b0, \
    ENET0GMIIRXER = 1'b0, \
    /* manual seems to call this ENET0IRQF2P{5,13} */ \
    ENET0EXTINTIN = 1'b0; \
  IOBUF ethio (.IO(ETH_MDIO), .I(ENET0MDIOO), .O(ENET0MDIOI), \
               .T(~ENET0MDIOTN));

`define EBAZ_ETH_PS7 `PS7_ENET(0)
`endif
