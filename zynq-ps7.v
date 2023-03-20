`ifndef _ZYNQ_PS7_V_
`define _ZYNQ_PS7_V_

// Simplified grouping of PS7 interfaces.  For each group, there is
// a PS7_<group>_WIRES() define to create a wire named after each pin in
// the group (with EMIO removed), and PS7_<group>() for mapping the wires
// into the PS7:
//  `PS7_ENET_WIRES(0);  // define wires for each pin for ENET0
//  `PS7 cpu (`PS7_ENET(0)); // connect to PS7
// To ease passing an entire group into a submodule, there are two macros:
// PS7_<group>_PORTS() to declare ports in the module, and
// PS7_<group>_PASS() to pass wires down, similar to the above:
//   module x(`PS7_ENET_PORTS(0)); // simelar to `PS7_ENET_WIRES(0)
//   x y(`PS7_ENET_PASS(0)); // in upper module; pass wires down.
// The reason for PS7_<group>_PASS rather than just PS7_<group> is the
// stripping of EMIO from the name.
// The macros below take more (optional) arguments, but they are meant to
// be used with their default value.  In other words, use PS7_ENET_WIRES(n)
// rather than PS7_ENET_WIRES(n, input, output, sep), PS7_JTAG_WIRES() rather
// than PS7_JTAG_WIRES(input, output, sep).  For consistency, all macros
// taking no arguments still use ().
// Note that I didn't provide a PORTS with the opposite direction; you can
// always just copy the PORTS macro definition and reverse input and output.

// I assume that unspecified inputs will end up grounded.  Otherwise I'd have
// to develop a way to easily ground everything manually (e.g. a `define at
// the end of every PS7_<group> macro to indicate it was used, followed by
// a "PS7_zero" macro that conditionally sets unused groups to gnd).  Not
// sure if that would even work, though.

// `` and default values are technically SystemVerilog, but yosys' default
// Verilog supports them.  Vivado seems to complain about it, though.
// On the other hand, it's not really possible/supported to use `` to
// create preprocessor symbols, and yosys doesn't support `define within
// macros (since newlines are suppressed).  So this is harder than it
// should be.  I wish this were just cpp.
`define _PS7_EMIO_(x, EMIO) .EMIO``x(x)
`define _COMMA_ ,
// The free tools and Gowin tools support ; directly, but Vivado barfs
`define _SEMI_ ;
// Note sure if it's worth supporting 2017.2.  It complains about my use
// of input and output as parameter names ("illegal macro parameter") (easy
// enough to work around) and also complains about something else ("illegal
// character in macro parameter") (not sure which char).  Maybe the use of
// default values (i.e., =)?  2022.[12] doesn't complain, but eventually
// crashes.

// n == 0,1
`define PS7_ENET_WIRES(n, input =, output =, sep =`_SEMI_) \
  input wire [7:0] \
    ENET``n``GMIIRXD``sep \
  input wire \
    ENET``n``GMIIRXCLK, \
    ENET``n``GMIIRXDV, \
    ENET``n``GMIITXCLK``sep \
   output wire [7:0] \
    ENET``n``GMIITXD``sep \
   output wire \
    ENET``n``GMIITXEN, \
    ENET``n``MDIOMDC``sep \
  /* inout in the form of i/o/tn */ \
  input wire \
    ENET``n``MDIOI``sep \
   output wire \
    ENET``n``MDIOO, ENET``n``MDIOTN``sep \
  input wire \
    ENET``n``GMIICOL, \
    ENET``n``GMIICRS, \
    ENET``n``GMIIRXER, \
    ENET``n``EXTINTIN``sep \
  output wire \
    ENET``n``GMIITXER, \
    ENET``n``PTPDELAYREQRX, \
    ENET``n``PTPDELAYREQTX, \
    ENET``n``PTPPDELAYREQRX, \
    ENET``n``PTPPDELAYREQTX, \
    ENET``n``PTPPDELAYRESPRX, \
    ENET``n``PTPPDELAYRESPTX, \
    ENET``n``PTPSYNCFRAMERX, \
    ENET``n``PTPSYNCFRAMETX, \
    ENET``n``SOFRX, \
    ENET``n``SOFTX
`define PS7_ENET_PORTS(n) `PS7_ENET_WIRES(n, output, input, `_COMMA_)
`define PS7_ENET_PASS(n, EMIO=) \
  `_PS7_EMIO_(ENET``n``GMIIRXD, EMIO), \
  `_PS7_EMIO_(ENET``n``GMIIRXCLK, EMIO), \
  `_PS7_EMIO_(ENET``n``GMIIRXDV, EMIO), \
  `_PS7_EMIO_(ENET``n``GMIITXCLK, EMIO), \
  `_PS7_EMIO_(ENET``n``GMIITXD, EMIO), \
  `_PS7_EMIO_(ENET``n``GMIITXEN, EMIO), \
  `_PS7_EMIO_(ENET``n``MDIOMDC, EMIO), \
  `_PS7_EMIO_(ENET``n``MDIOO, EMIO), \
  `_PS7_EMIO_(ENET``n``MDIOTN, EMIO), \
  `_PS7_EMIO_(ENET``n``MDIOI, EMIO), \
  `_PS7_EMIO_(ENET``n``GMIICOL, EMIO), \
  `_PS7_EMIO_(ENET``n``GMIICRS, EMIO), \
  `_PS7_EMIO_(ENET``n``GMIIRXER, EMIO), \
  `_PS7_EMIO_(ENET``n``EXTINTIN, EMIO), \
  `_PS7_EMIO_(ENET``n``GMIITXER, EMIO), \
  `_PS7_EMIO_(ENET``n``PTPDELAYREQRX, EMIO), \
  `_PS7_EMIO_(ENET``n``PTPDELAYREQTX, EMIO), \
  `_PS7_EMIO_(ENET``n``PTPPDELAYREQRX, EMIO), \
  `_PS7_EMIO_(ENET``n``PTPPDELAYREQTX, EMIO), \
  `_PS7_EMIO_(ENET``n``PTPPDELAYRESPRX, EMIO), \
  `_PS7_EMIO_(ENET``n``PTPPDELAYRESPTX, EMIO), \
  `_PS7_EMIO_(ENET``n``PTPSYNCFRAMERX, EMIO), \
  `_PS7_EMIO_(ENET``n``PTPSYNCFRAMETX, EMIO), \
  `_PS7_EMIO_(ENET``n``SOFRX, EMIO), \
  `_PS7_EMIO_(ENET``n``SOFTX, EMIO)
`define PS7_ENET(n) `PS7_ENET_PASS(n, EMIO)

// n == 0,1
`define PS7_I2C_WIRES(n, input =, output =, sep =`_SEMI_) \
  /* inouts in the form of i/o/tn */ \
  input wire \
    I2C``n``SCLI, I2C``n``SDAI``sep \
  output wire \
    I2C``n``SCLO, I2C``n``SDAO, \
    I2C``n``SCLTN, I2C``n``SDATN
`define PS7_I2C_PORTS(n) `PS7_I2C_WIRES(n, output, input, `_COMMA_)
`define PS7_I2C_PASS(n, EMIO=) \
   `_PS7_EMIO_(I2C``n``SCLI, EMIO), `_PS7_EMIO_(I2C``n``SDAI, EMIO), \
   `_PS7_EMIO_(I2C``n``SCLO, EMIO), `_PS7_EMIO_(I2C``n``SDAO, EMIO), \
   `_PS7_EMIO_(I2C``n``SCLTN, EMIO), `_PS7_EMIO_(I2C``n``SDATN, EMIO)
`define PS7_I2C(n) `PS7_I2C_PASS(n,EMIO)

// n == 0,1
`define PS7_CAN_WIRES(n, input =, output =, sep =`_SEMI_) \
  input wire CAN``n``PHYRX``sep \
  output wire CAN``n``PHYTX
`define PS7_CAN_PORTS(n) `PS7_CAN_WIRES(n, output, input, `_COMMA_)
`define PS7_CAN_PASS(n, EMIO=) \
  `_PS7_EMIO_(CAN``n``PHYRX, EMIO), `_PS7_EMIO_(CAN``n``PHYTX, EMIO)
`define PS7_CAN(n) `PS7_CAN_PASS(n,EMIO)

// n == 0,1
`define PS7_UART_WIRES(n, input =, output =, sep =`_SEMI_) \
  input wire UART``n``CTSN, UART``n``DCDN, UART``n``DSRN, UART``n``RIN, \
             UART``n``RX``sep \
  output wire UART``n``DTRN, UART``n``RTSN, UART``n``TX
`define PS7_UART_PORTS(n) `PS7_UART_WIRES(n, output, input, `_COMMA_)
`define PS7_UART_PASS(n, EMIO=) \
  `_PS7_EMIO_(UART``n``CTSN, EMIO), `_PS7_EMIO_(UART``n``DCDN, EMIO), \
  `_PS7_EMIO_(UART``n``DSRN, EMIO), `_PS7_EMIO_(UART``n``RIN, EMIO), \
  `_PS7_EMIO_(UART``n``RX, EMIO), `_PS7_EMIO_(UART``n``TX, EMIO), \
  `_PS7_EMIO_(UART``n``DTRN, EMIO), `_PS7_EMIO_(UART``n``RTSN, EMIO)
`define PS7_UART(n) `PS7_UART_PASS(n,EMIO)

// n == 0,1
`define PS7_SDIO_WIRES(n, input =, output =, sep =`_SEMI_) \
  input wire \
    SDIO``n``CDN, SDIO``n``CLKFB, SDIO``n``WP``sep \
  output wire \
    SDIO``n``BUSPOW, SDIO``n``CLK, SDIO``n``LED``sep \
  output wire [2:0] \
    SDIO``n``BUSVOLT``sep \
  /* inout as i/o/tn */ \
  input wire \
    SDIO``n``CMDI``sep \
  output wire \
    SDIO``n``CMDO``sep \
  input wire [3:0] \
    SDIO``n``DATAI``sep \
  output wire [3:0] \
    SDIO``n``DATAO, SDIO``n``DATATN
`define PS7_SDIO_PORTS(n) `PS7_SDIO_WIRES(n, output, input, `_COMMA_)
`define PS7_SDIO_PASS(n, EMIO=) \
  `_PS7_EMIO_(SDIO``n``CDN, EMIO), `_PS7_EMIO_(SDIO``n``CLKFB, EMIO), `_PS7_EMIO_(SDIO``n``WP, EMIO), \
  `_PS7_EMIO_(SDIO``n``BUSPOW, EMIO), `_PS7_EMIO_(SDIO``n``CLK, EMIO), `_PS7_EMIO_(SDIO``n``LED, EMIO), \
  `_PS7_EMIO_(SDIO``n``BUSVOLT, EMIO), \
  `_PS7_EMIO_(SDIO``n``CMDI, EMIO), \
  `_PS7_EMIO_(SDIO``n``CMDO, EMIO), \
  `_PS7_EMIO_(SDIO``n``DATAI, EMIO), \
  `_PS7_EMIO_(SDIO``n``DATAO, EMIO), `_PS7_EMIO_(SDIO``n``DATATN, EMIO)
`define PS7_SDIO(n) `PS7_SDIO_PASS(n,EMIO)

// n == 0,1
`define PS7_SPI_WIRES(n, input =, output =, sep =`_SEMI_) \
  input wire \
    SPI``n``SSIN``sep \
  output wire \
    SPI``n``SSNTN``sep \
  /* inout as i/o/tn */ \
  input wire \
    SPI``n``MI, SPI``n``SCLKI, SPI``n``SI``sep \
  output wire \
    SPI``n``MO, SPI``n``MOTN, SPI``n``SCLKO, SPI``n``SCLKTN, \
    SPI``n``SO, SPI``n``STN``sep \
  output wire [2:0] \
    SPI``n``SSON
`define PS7_SPI_PORTS(n) `PS7_SPI_WIRES(n, output, input, `_COMMA_)
`define PS7_SPI_PASS(n, EMIO=) \
    `_PS7_EMIO_(SPI``n``SSIN, EMIO), \
    `_PS7_EMIO_(SPI``n``MI, EMIO), `_PS7_EMIO_(SPI``n``SCLKI, EMIO), `_PS7_EMIO_(SPI``n``SI, EMIO), \
    `_PS7_EMIO_(SPI``n``MO, EMIO), `_PS7_EMIO_(SPI``n``MOTN, EMIO), `_PS7_EMIO_(SPI``n``SCLKO, EMIO), `_PS7_EMIO_(SPI``n``SCLKTN, EMIO), \
    `_PS7_EMIO_(SPI``n``SO, EMIO), `_PS7_EMIO_(SPI``n``STN, EMIO), \
    `_PS7_EMIO_(SPI``n``SSON, EMIO)
`define PS7_SPI(n) `PS7_SPI_PASS(n,EMIO)

`define PS7_PJTAG_WIRES(input =, output =, sep =`_SEMI_) \
  input wire PJTAGTCK, PJTAGTDI, PJTAGTMS``sep \
  /* not sure what TDTN is for (input and output should be separate) */ \
  output wire PJTAGTDO, PJTAGTDTN
`define PS7_PJTAG_PORTS(dummy=) `PS7_PJTAG_WIRES(output, input, `_COMMA_)
`define PS7_PJTAG_PASS(EMIO=) \
  `_PS7_EMIO_(PJTAGTCK, EMIO), `_PS7_EMIO_(PJTAGTDI, EMIO), `_PS7_EMIO_(PJTAGTMS, EMIO), \
  /* not sure what TDTN is for (input and output should be separate) */ \
  `_PS7_EMIO_(PJTAGTDO, EMIO), `_PS7_EMIO_(PJTAGTDTN, EMIO)
`define PS7_PJTAG(dummy=) `PS7_PJTAG_PASS(EMIO)

`define PS7_TRACE_WIRES(input =, output =, sep =`_SEMI_) \
  input wire TRACECLK``sep \
  output wire TRACECTL``sep \
  output wire [31:0] TRACEDATA
`define PS7_TRACE_PORTS(dummy=) `PS7_TRACE_WIRES(output, input, `_COMMA_)
`define PS7_TRACE_PASS(EMIO=) \
  `_PS7_EMIO_(TRACECLK, EMIO), `_PS7_EMIO_(TRACECTL, EMIO), `_PS7_EMIO_(TRACEDATA, EMIO)
`define PS7_TRACE(dummy=) `PS7_TRACE_PASS(EMIO)

// Not worth it for USB, since most signals aren't available
// output EMIOUSB``n``VBUSPWRSELECT;
// output [1:0] EMIOUSB``n``PORTINDCTL;
// input EMIOUSB``n``VBUSPWRFAULT;

// Can't do these individually
// not much point for a PORTS macro for GPIO, but I prefer consistency
`define PS7_GPIO_WIRES(input =, output =, sep =`_SEMI_) \
  input wire [63:0] GPIOI``sep \
  output wire [63:0] GPIOO, GPIOTN
`define PS7_GPIO_PORTS(dummy=) `PS7_GPIO_WIRES(output, input, `_COMMA_)
`define PS7_GPIO_PASS(EMIO=) \
  `_PS7_EMIO_(GPIOI, EMIO), `_PS7_EMIO_(GPIOO, EMIO), `_PS7_EMIO_(GPIOTN, EMIO)
`define PS7_GPIO(dummy=) `PS7_GPIO_PASS(EMIO)

// input EMIOSRAMINTIN;  alert PL that static memory has intr?? (input?)

// n = 0..1
`define PS7_TTC_WIRES(n, input =, output =, sep =`_SEMI_) \
  input wire [2:0] TTC``n``CLKI``sep \
  output wire [2:0] TTC``n``WAVEO
`define PS7_TTC_PORTS(n) `PS7_TTC_WIRES(n, output, input, `_COMMA_)
`define PS7_TTC_PASS(n, EMIO=) \
  `_PS7_EMIO_(TTC``n``CLKI, EMIO), `_PS7_EMIO_(TTC``n``WAVEO, EMIO)
`define PS7_TTC(n) `PS7_TTC_PASS(n,EMIO)

`define PS7_WDT_WIRES(input =, output =, sep =`_SEMI_) \
  input wire WDTCLKI``sep \
  output wire WDTRSTO
`define PS7_WDT_PORTS(dummy=) `PS7_WDT_WIRES(output, input, `_COMMA_)
`define PS7_WDT_PASS(EMIO=) \
  `_PS7_EMIO_(WDTCLKI, EMIO), `_PS7_EMIO_(WDTRSTO, EMIO)
`define PS7_WDT(dummy=) `PS7_WDT_PASS(EMIO)

// end of EMIO
`define _PS7_RAW_(x) .x(x)

// n = 0..3
`define PS7_DMA_WIRES(n, input =, output =, sep =`_SEMI_) \
  input wire \
    DMA``n``ACLK, DMA``n``DAREADY, DMA``n``DRLAST, DMA``n``DRVALID``sep \
  input wire [1:0] \
    DMA``n``DRTYPE``sep \
  output wire \
    DMA``n``DAVALID, DMA``n``DRREADY, DMA``n``RSTN``sep \
  output wire [1:0] \
    DMA``n``DATYPE
`define PS7_DMA_PORTS(n) `PS7_DMA_WIRES(n, output, input, `_COMMA_)
`define PS7_DMA(n) \
    `_PS7_RAW_(DMA``n``ACLK), `_PS7_RAW_(DMA``n``DAREADY), `_PS7_RAW_(DMA``n``DRLAST), `_PS7_RAW_(DMA``n``DRVALID), \
    `_PS7_RAW_(DMA``n``DRTYPE), \
    `_PS7_RAW_(DMA``n``DAVALID), `_PS7_RAW_(DMA``n``DRREADY), `_PS7_RAW_(DMA``n``RSTN), \
    `_PS7_RAW_(DMA``n``DATYPE)
`define PS7_DMA_PASS(n) `PS7_DMA(n)

// ms=M/S n=GP0..GP1(M/S) ACP(S) HP0..HP3(S) io=M:output,S:input oi=inverse
// dlen=32(GP)/64(other) idlen=3(ACP)/6(other-S)/12(M)
`define _AXI_COMMON_WIRES(ms, n, io, oi, out, dlen, idlen, sep) \
  out wire /* stupid surelog */``ms``AXI``n``ARESETN``sep \
  io wire \
    /**/``ms``AXI``n``ARVALID, /**/``ms``AXI``n``AWVALID, \
    /**/``ms``AXI``n``BREADY, /**/``ms``AXI``n``RREADY, \
    /**/``ms``AXI``n``WLAST, /**/``ms``AXI``n``WVALID, \
    /**/``ms``AXI``n``ACLK``sep \
  io wire [idlen-1:0] \
    /**/``ms``AXI``n``ARID, /**/``ms``AXI``n``AWID, /**/``ms``AXI``n``WID``sep \
  io wire [1:0] \
    /**/``ms``AXI``n``ARBURST, /**/``ms``AXI``n``ARLOCK, \
    /**/``ms``AXI``n``ARSIZE, /**/``ms``AXI``n``AWBURST, \
    /**/``ms``AXI``n``AWLOCK, /**/``ms``AXI``n``AWSIZE``sep \
  io wire [2:0] \
    /**/``ms``AXI``n``ARPROT, /**/``ms``AXI``n``AWPROT``sep \
  io wire [31:0] \
    /**/``ms``AXI``n``ARADDR, /**/``ms``AXI``n``AWADDR``sep \
  io wire [dlen-1:0] \
    /**/``ms``AXI``n``WDATA``sep \
  io wire [dlen/8-1:0] \
    /**/``ms``AXI``n``WSTRB``sep \
  io wire [3:0] \
    /**/``ms``AXI``n``ARCACHE, /**/``ms``AXI``n``ARLEN, \
    /**/``ms``AXI``n``ARQOS, /**/``ms``AXI``n``AWCACHE, \
    /**/``ms``AXI``n``AWLEN, /**/``ms``AXI``n``AWQOS``sep \
  oi wire \
    /**/``ms``AXI``n``ARREADY, /**/``ms``AXI``n``AWREADY, \
    /**/``ms``AXI``n``BVALID, /**/``ms``AXI``n``RLAST, \
    /**/``ms``AXI``n``RVALID, /**/``ms``AXI``n``WREADY``sep \
  oi wire [1:0] \
    /**/``ms``AXI``n``BRESP, /**/``ms``AXI``n``RRESP``sep \
  oi wire [dlen-1:0] \
    /**/``ms``AXI``n``RDATA``sep \
  oi wire [idlen-1:0] \
    /**/``ms``AXI``n``BID, /**/``ms``AXI``n``RID

// n == 0,1
`define PS7_MAXIGP_WIRES(n, input=, output=, sep=`_SEMI_) \
  `_AXI_COMMON_WIRES(M, GP``n, output, input, output, 32, 12, sep)
`define PS7_MAXIGP_PORTS(n) `PS7_MAXIGP_WIRES(n, output, input, `_COMMA_)

// n == 0,1
`define PS7_SAXIGP_WIRES(n, input=, output=, sep=`_SEMI_) \
  `_AXI_COMMON_WIRES(S, GP``n, input, output, output, 32, 6, sep)
`define PS7_SAXIGP_PORTS(n) `PS7_SAXIGP_WIRES(n, output, input, `_COMMA_)

`define PS7_SAXIACP_WIRES(input=, output=, sep=`_SEMI_) \
  `_AXI_COMMON_WIRES(S, ACP, input, output, output, 64, 3, sep)``sep \
  input wire [4:0] SAXIACPARUSER, SAXIACPAWUSER
`define PS7_SAXIACP_PORTS(dummy=) `PS7_SAXIACP_WIRES(output, input, `_COMMA_)

// n == 0..3
`define PS7_SAXIHP_WIRES(n, input=, output=, sep=`_SEMI_) \
  `_AXI_COMMON_WIRES(S, HP``n, input, output, output, 64, 6, sep)``sep \
  output wire [2:0] SAXIHP``n``RACOUNT``sep \
  output wire [5:0] SAXIHP``n``WACOUNT``sep \
  output wire [7:0] SAXIHP``n``RCOUNT, SAXIHP``n``WCOUNT``sep \
  input wire SAXIHP``n``RDISSUECAP1EN, SAXIHP``n``WRISSUECAP1EN
`define PS7_SAXIHP_PORTS(n) `PS7_SAXIHP_WIRES(n, output, input, `_COMMA_)

`define _AXI_COMMON(ms, n) \
  `_PS7_RAW_(/**/``ms``AXI``n``ARESETN), \
  `_PS7_RAW_(/**/``ms``AXI``n``ARVALID), `_PS7_RAW_(/**/``ms``AXI``n``AWVALID), \
  `_PS7_RAW_(/**/``ms``AXI``n``BREADY), `_PS7_RAW_(/**/``ms``AXI``n``RREADY), \
  `_PS7_RAW_(/**/``ms``AXI``n``WLAST), `_PS7_RAW_(/**/``ms``AXI``n``WVALID), \
  `_PS7_RAW_(/**/``ms``AXI``n``ACLK), \
  `_PS7_RAW_(/**/``ms``AXI``n``ARID), `_PS7_RAW_(/**/``ms``AXI``n``AWID), `_PS7_RAW_(/**/``ms``AXI``n``WID), \
  `_PS7_RAW_(/**/``ms``AXI``n``ARBURST), `_PS7_RAW_(/**/``ms``AXI``n``ARLOCK), \
  `_PS7_RAW_(/**/``ms``AXI``n``ARSIZE), `_PS7_RAW_(/**/``ms``AXI``n``AWBURST), \
  `_PS7_RAW_(/**/``ms``AXI``n``AWLOCK), `_PS7_RAW_(/**/``ms``AXI``n``AWSIZE), \
  `_PS7_RAW_(/**/``ms``AXI``n``ARPROT), `_PS7_RAW_(/**/``ms``AXI``n``AWPROT), \
  `_PS7_RAW_(/**/``ms``AXI``n``ARADDR), `_PS7_RAW_(/**/``ms``AXI``n``AWADDR), \
  `_PS7_RAW_(/**/``ms``AXI``n``WDATA), \
  `_PS7_RAW_(/**/``ms``AXI``n``WSTRB), \
  `_PS7_RAW_(/**/``ms``AXI``n``ARCACHE), `_PS7_RAW_(/**/``ms``AXI``n``ARLEN), \
  `_PS7_RAW_(/**/``ms``AXI``n``ARQOS), `_PS7_RAW_(/**/``ms``AXI``n``AWCACHE), \
  `_PS7_RAW_(/**/``ms``AXI``n``AWLEN), `_PS7_RAW_(/**/``ms``AXI``n``AWQOS), \
  `_PS7_RAW_(/**/``ms``AXI``n``ARREADY), `_PS7_RAW_(/**/``ms``AXI``n``AWREADY), \
  `_PS7_RAW_(/**/``ms``AXI``n``BVALID), `_PS7_RAW_(/**/``ms``AXI``n``RLAST), \
  `_PS7_RAW_(/**/``ms``AXI``n``RVALID), `_PS7_RAW_(/**/``ms``AXI``n``WREADY), \
  `_PS7_RAW_(/**/``ms``AXI``n``BRESP), `_PS7_RAW_(/**/``ms``AXI``n``RRESP), \
  `_PS7_RAW_(/**/``ms``AXI``n``RDATA), \
  `_PS7_RAW_(/**/``ms``AXI``n``BID), `_PS7_RAW_(/**/``ms``AXI``n``RID)
`define PS7_MAXIGP(n) `_AXI_COMMON(M, GP``n)
`define PS7_SAXIGP(n) `_AXI_COMMON(S, GP``n)
`define PS7_SAXIACP(dummy=) \
  `_AXI_COMMON(S, ACP), \
  `_PS7_RAW_(SAXIACPARUSER), `_PS7_RAW_(SAXIACPAWUSER)
`define PS7_SAXIHP(n) \
  `_AXI_COMMON(S, HP``n), \
  `_PS7_RAW_(SAXIHP``n``RACOUNT), `_PS7_RAW_(SAXIHP``n``WACOUNT), \
  `_PS7_RAW_(SAXIHP``n``RCOUNT), `_PS7_RAW_(SAXIHP``n``WCOUNT), \
  `_PS7_RAW_(SAXIHP``n``RDISSUECAP1EN), `_PS7_RAW_(SAXIHP``n``WRISSUECAP1EN)
// input FPGAIDLEN; indicates to CPU that AXI is idle
// input [3:0] DDRARB; indicates to AXIHP port of urgent DDR need
`define PS7_MAXIGP_PASS(n) `PS7_MAXIGP(n)
`define PS7_SAXIGP_PASS(n) `PS7_SAXIGP(n)
`define PS7_SAXIACP_PASS(dummy=) `PS7_SAXIACP()
`define PS7_SAXIHP_PASS(n) `PS7_SAXIHP(n)

// No point for a macro for the clocks.  Just use individually
// output [3:0] FCLKCLK;
// output [3:0] FCLKRESETN;
// input [3:0] FCLKCLKTRIGN;

// Same with interrupts.  Having these as vectors is actually inconvenient.
// input [19:0] IRQF2P;
// output [28:0] IRQP2F;
// input EVENTEVENTI;
// output EVENTEVENTO;
// output [1:0] EVENTSTANDBYWFE;
// output [1:0] EVENTSTANDBYWFI;

// Hmmm... Fabric Trace Module -- not sure if it's worth it
// output [31:0] FTMTP2FDEBUG;
// output [3:0] FTMTF2PTRIGACK;
// output [3:0] FTMTP2FTRIG;
// input FTMDTRACEINCLOCK;
// input FTMDTRACEINVALID;
// input [31:0] FTMDTRACEINDATA;
// input [31:0] FTMTF2PDEBUG;
// input [3:0] FTMDTRACEINATID;
// input [3:0] FTMTF2PTRIG;
// input [3:0] FTMTP2FTRIGACK;

// Not sure what these are even for.  They aren't in the FPGA logic, as far
// as I know.  Do I have to explicitly map these to the PS pins?  Some of the
// "raw ethernet passthrough" examples on the 'net seem to do this for
// DDR at least (but, oddly enough, nothing else).  I have never seen the
// EBAZ on-board RAM fail as a result of doing nothing with these.
// inout PSCLK;
// inout [53:0] MIO;
// inout DDRCASB;
// inout DDRCKE;
// inout DDRCKN;
// inout DDRCKP;
// inout DDRCSB;
// inout DDRDRSTB;
// inout DDRODT;
// inout DDRRASB;
// inout DDRVRN;
// inout DDRVRP;
// inout DDRWEB;
// inout [14:0] DDRA;
// inout [2:0] DDRBA;
// inout [31:0] DDRDQ;
// inout [3:0] DDRDM;
// inout [3:0] DDRDQSN;
// inout [3:0] DDRDQSP;
// inout PSPORB;
// inout PSSRSTB;

`endif
