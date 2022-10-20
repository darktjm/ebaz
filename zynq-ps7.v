`ifndef _ZYNQ_PS7_V_
`define _ZYNQ_PS7_V_

// Simplified grouping of PS7 interfaces.  For each group, there is
// a PS7_<group>_WIRES define for the wires, and PS7_<group> for mapping the
// wires into the PS7.  There is also a PS7_<group>_PORTS for defining
// pass-through ports.  The macros below take more arguments, but they
// are meant to be used with their default value.  In other words,
// use PS7_ENET_WIRES(n) rather than PS7_ENET_WIRES(n, input, output, sep),
// and PS7_JTAG_WIRES() rather than PS7_JTAG_WIRES(input, output, sep).

// I assume that unspecified inputs will end up grounded.  Otherwise I'd have
// to develop a way to easily ground everything manually (e.g. a `define at
// the end of every PS7_<group> macro to indicate it was used, followed by
// a "PS7_zero" macro that conditionally sets unused groups to gnd).  Not
// sure if that would even work, though.

// `` and default values are technically SystemVerilog, but yosys' default
// Verilog supports them.  Vivado seems to complain about it, though.
// On the other hand, it's not really possible/supportd to use `` to
// create preprocessor symbols, and yosys doesn't support `define within
// macros (since newlines are suppressed).  So this is harder than it
// should be.  I wish this were just cpp.
`define _PS7_EMIO_(x) .EMIO``x(x)
`define _COMMA_ ,
// The free tools and Gowin tools support ; directly, but Vivado barfs
`define _SEMI_ ;

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
`define PS7_ENET_PORTS(n) `PS7_ENET_WIRES(n, input, output, `_COMMA_)
`define PS7_ENET(n) \
  `_PS7_EMIO_(ENET``n``GMIIRXD), \
  `_PS7_EMIO_(ENET``n``GMIIRXCLK), \
  `_PS7_EMIO_(ENET``n``GMIIRXDV), \
  `_PS7_EMIO_(ENET``n``GMIITXCLK), \
  `_PS7_EMIO_(ENET``n``GMIITXD), \
  `_PS7_EMIO_(ENET``n``GMIITXEN), \
  `_PS7_EMIO_(ENET``n``MDIOMDC), \
  `_PS7_EMIO_(ENET``n``MDIOO), \
  `_PS7_EMIO_(ENET``n``MDIOTN), \
  `_PS7_EMIO_(ENET``n``MDIOI), \
  `_PS7_EMIO_(ENET``n``GMIICOL), \
  `_PS7_EMIO_(ENET``n``GMIICRS), \
  `_PS7_EMIO_(ENET``n``GMIIRXER), \
  `_PS7_EMIO_(ENET``n``EXTINTIN), \
  `_PS7_EMIO_(ENET``n``GMIITXER), \
  `_PS7_EMIO_(ENET``n``PTPDELAYREQRX), \
  `_PS7_EMIO_(ENET``n``PTPDELAYREQTX), \
  `_PS7_EMIO_(ENET``n``PTPPDELAYREQRX), \
  `_PS7_EMIO_(ENET``n``PTPPDELAYREQTX), \
  `_PS7_EMIO_(ENET``n``PTPPDELAYRESPRX), \
  `_PS7_EMIO_(ENET``n``PTPPDELAYRESPTX), \
  `_PS7_EMIO_(ENET``n``PTPSYNCFRAMERX), \
  `_PS7_EMIO_(ENET``n``PTPSYNCFRAMETX), \
  `_PS7_EMIO_(ENET``n``SOFRX), \
  `_PS7_EMIO_(ENET``n``SOFTX)

// n == 0,1
`define PS7_I2C_WIRES(n, input =, output =, sep =`_SEMI_) \
  /* inouts in the form of i/o/tn */ \
  input wire \
    I2C``n``SCLI, I2C``n``SDAI``sep \
  output wire \
    I2C``n``SCLO, I2C``n``SDAO, \
    I2C``n``SCLTN, I2C``n``SDATN
`define PS7_I2C_PORTS(n) `PS7_I2C_WIRES(n, input, output, `_COMMA_)
`define PS7_I2C(n) \
  input wire \
    `_PS7_EMIO_(I2C``n``SCLI), `_PS7_EMIO_(I2C``n``SDAI), \
  output wire \
    `_PS7_EMIO_(I2C``n``SCLO), `_PS7_EMIO_(I2C``n``SDAO), \
    `_PS7_EMIO_(I2C``n``SCLTN), `_PS7_EMIO_(I2C``n``SDATN)

// n == 0,1
`define PS7_CAN_WIRES(n, input =, output =, sep =`_SEMI_) \
  input wire CAN``n``PHYRX``sep \
  output wire CAN``n``PHYTX
`define PS7_CAN_PORTS(n) `PS7_CAN_WIRES(n, input, output, `_COMMA_)
`define PS7_CAN(n) \
  `PS7_EMIO(CAN``n``PHYRX), `PS7_EMIO(CAN``n``PHYTX)

// n == 0,1
`define PS7_UART_WIRES(n, input =, output =, sep =`_SEMI_) \
  input wire UART``n``CTSN, UART``n``DCDN, UART``n``DSRN, UART``n``RIN, \
             UART``n``RX``sep \
  output wire UART``n``DTRN, UART``n``RTSN, UART``n``TX
`define PS7_UART_PORTS(n) `PS7_UART_WIRES(n, input, output, `_COMMA_)
`define PS7_UART(n) \
  `_PS7_EMIO_(UART``n``CTSN), `_PS7_EMIO_(UART``n``DCDN), \
  `_PS7_EMIO_(UART``n``DSRN), `_PS7_EMIO_(UART``n``RIN), \
  `_PS7_EMIO_(UART``n``RX), `_PS7_EMIO_(UART``n``TX), \
  `_PS7_EMIO_(UART``n``DTRN), `_PS7_EMIO_(UART``n``RTSN)

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
`define PS7_SDIO_PORTS(n) `PS7_SDIO_WIRES(n, input, output, `_COMMA_)
`define PS7_SDIO(n) \
  _PS7_EMIO_(SDIO``n``CDN), _PS7_EMIO_(SDIO``n``CLKFB), _PS7_EMIO_(SDIO``n``WP), \
  _PS7_EMIO_(SDIO``n``BUSPOW), _PS7_EMIO_(SDIO``n``CLK), _PS7_EMIO_(SDIO``n``LED), \
  _PS7_EMIO_(SDIO``n``BUSVOLT), \
  _PS7_EMIO_(SDIO``n``CMDI), \
  _PS7_EMIO_(SDIO``n``CMDO), \
  _PS7_EMIO_(SDIO``n``DATAI), \
  _PS7_EMIO_(SDIO``n``DATAO), _PS7_EMIO_(SDIO``n``DATATN

// n == 0,1
`define PS7_SPI_WIRES(n, input =, output =, sep =`_SEMI_) \
  input \
    SPI``n``SSIN``sep \
  /* inout as i/o/tn */ \
  input \
    SPI``n``MI, SPI``n``SCLKI, SPI``n``SI``sep \
  output \
    SPI``n``MO, SPI``n``MOTN, SPI``n``SCLKO, SPI``n``SCLKTN, \
    SPI``n``SO, SPI``n``STN``sep \
  input [2:0] \
    SPI``n``SSI``sep \
  output [2:0] \
    SPI``n``SSO, SPI``n``SSTN
`define PS7_SPI_PORTS(n) `PS7_SPI_WIRES(n, input, output, `_COMMA_)
`define PS7_SPI(n) \
    `_PS7_EMIO_(SPI``n``SSIN), \
    `_PS7_EMIO_(SPI``n``MI), `_PS7_EMIO_(SPI``n``SCLKI), `_PS7_EMIO_(SPI``n``SI), \
    `_PS7_EMIO_(SPI``n``MO), `_PS7_EMIO_(SPI``n``MOTN), `_PS7_EMIO_(SPI``n``SCLKO), `_PS7_EMIO_(SPI``n``SCLKTN), \
    `_PS7_EMIO_(SPI``n``SO), `_PS7_EMIO_(SPI``n``STN), \
    `_PS7_EMIO_(SPI``n``SSI), \
    `_PS7_EMIO_(SPI``n``SSO), `_PS7_EMIO_(SPI``n``SSTN)

`define PS7_PJTAG_WIRES(input =, output =, sep =`_SEMI_) \
  input PJTAGTCK, PJTAGTDI, PJTAGTMS``sep \
  /* not sure what TDTN is for (input and output should be separate) */ \
  output PJTAGTDO, PJTAGTDTN
`define PS7_PJTAG_PORTS `PS7_PJTAG_WIRES(input, output, `_COMMA_)
`define PS7_PJTAG \
  `_PS7_EMIO_(PJTAGTCK), `_PS7_EMIO_(PJTAGTDI), `_PS7_EMIO_(PJTAGTMS), \
  /* not sure what TDTN is for (input and output should be separate) */ \
  `_PS7_EMIO_(PJTAGTDO), `_PS7_EMIO_(PJTAGTDTN)

`define PS7_TRACE_WIRES(input =, output =, sep =`_SEMI_) \
  input wire TRACECLK``sep \
  output wire TRACECTL``sep \
  output wire [31:0] TRACEDATA
`define PS7_TRACE_PORTS `PS7_TRACE_WIRES(input, output, `_COMMA_)
`define PS7_TRACE \
  _PS7_EMIO_(TRACECLK),  _PS7_EMIO_(TRACECTL), _PS7_EMIO_(TRACEDATA)

// Not worth it for USB, since most signals aren't available
// output EMIOUSB``n``VBUSPWRSELECT;
// output [1:0] EMIOUSB``n``PORTINDCTL;
// input EMIOUSB``n``VBUSPWRFAULT;

// Can't do these individually
// not much point for a PORTS macro for GPIO, but I prefer consistency
`define PS7_GPIO_WIRES(input =, output =, sep =`_SEMI_) \
  input wire [63:0] GPIOI``sep \
  output wire [63:0] GPIOO, GPIOTN
`define PS7_GPIO_PORTS `PS7_GPIO_WIRES(input, output, `_COMMA_)
`define PS7_GPIO \
  _PS7_EMIO_(GPIOI), _PS7_GPIO_(GPIOO), _PS7_GPIO_(GPIOTN)

// input EMIOSRAMINTIN;  alert PL that static memory has intr?? (input?)

// n = 0..1
`define PS7_TTC_WIRES(n, input =, output =, sep =`_SEMI_) \
  input wire [2:0] TTC``n``CLKI``sep \
  output wire [2:0] TTC``n``WAVEO
`define PS7_TTC_PORTS(n) `PS7_TTC_WIRES(n, input, output, `_COMMA_)
`define PS7_TTC(n) \
  _PS7_EMIO_(TTC``n``CLKI), _PS7_EMIO_(TTC``n``WAVEO)

`define PS7_WDT_WIRES(input =, output =, sep =`_SEMI_) \
  input wire WDTCLKI``sep \
  output wire WDTRSTO
`define PS7_WDT_PORTS `PS7_WDT_WIRES(input, output, `_COMMA_)
`define PS7_WDT _PS7_EMIO_(WDTCLKI), _PS7_EMIO_(WDTRSTO)

// end of EMIO
`define _PS7_RAW_(x) .x(x)

// n = 0..3
`define PS7_DMA_WIRES(n, input =, output =, sep =`_SEMI_) \
  input \
    DMA``n``ACLK, DMA``n``DAREADY, DMA``n``DRLAST, DMA``n``DRVALID``sep \
  input [1:0] \
    DMA``n``DRTYPE``sep \
  output \
    DMA``n``DAVALID, DMA``n``DRREADY, DMA``n``RSTN``sep \
  output [1:0] \
    DMA``n``DATYPE
`define PS7_DMA_PORTS(n) `PS7_DMA_WIRES(n, input, output, `_COMMA_)
`define PS7_DMA(n) \
    `_PS7_RAW_(DMA``n``ACLK), `_PS7_RAW_(DMA``n``DAREADY), `_PS7_RAW_(DMA``n``DRLAST), `_PS7_RAW_(DMA``n``DRVALID), \
    `_PS7_RAW_(DMA``n``DRTYPE), \
    `_PS7_RAW_(DMA``n``DAVALID), `_PS7_RAW_(DMA``n``DRREADY), `_PS7_RAW_(DMA``n``RSTN), \
    `_PS7_RAW_(DMA``n``DATYPE)

// ms=M/S n=GP0..GP1(M/S) ACP(S) HP0..HP3(S) io=M:output,S:input oi=inverse
// dlen=32(GP)/64(other) idlen=3(ACP)/6(other-S)/12(M)
`define _AXI_COMMON_WIRES(ms, n, io, oi, out, dlen, idlen, sep) \
  out /* stupid surelog */``ms``AXI``n``ARESETN``sep \
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
`define PS7_MAXIGP_WIRES(n, input=, output=, sep=;) \
  `_AXI_COMMON_WIRES(M, GP``n, output, input, output, 32, 12, sep)
`define PS7_MAXIGP_PORTS(n) `PS7_MAXIGP_WIRES(n, input, output, `_COMMA_)
`define PS7_SAXIGP_WIRES(n, input=, output=, sep=;) \
  `_AXI_COMMON_WIRES(S, GP``n, input, output, output, 32, 6, sep)
`define PS7_SAXIGP_PORTS(n) `PS7_SAXIGP_WIRES(n, input, output, `_COMMA_)
`define PS7_SAXIACP_WIRES(input=, output=, sep=;) \
  `_AXI_COMMON_WIRES(S, ACP, input, output, output, 64, 3, sep)``sep \
  input [4:0] SAXIACPARUSER, SAXIACPAWUSER
`define PS7_SAXIACP_PORTS `PS7_SAXIACP_WIRES(input, output, `_COMMA_)
`define PS7_SAXIHP_WIRES(n, input=, output=, sep=;) \
  `_AXI_COMMON_WIRES(S, HP``n, input, output, output, 64, 6, sep)``sep \
  output [2:0] SAXIHP``n``RACOUNT``sep \
  output [5:0] SAXIHP``n``WACOUNT``sep \
  output [7:0] SAXIHP``n``RCOUNT, SAXIHP``n``WCOUNT``sep \
  input SAXIHP``n``RDISSUECAP1EN, SAXIHP``n``WRISSUECAP1EN
`define PS7_SAXIHP_PORTS(n) `PS7_SAXIHP_WIRES(n, input, output, `_COMMA_)
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
`define PS7_SAXIACP \
  `_AXI_COMMON(S, ACP), \
  `_PS7_RAW_(SAXIACPARUSER), `_PS7_RAW_(SAXIACPAWUSER)
`define PS7_SAXIHP(n) \
  `_AXI_COMMON(S, HP``n), \
  `_PS7_RAW_(SAXIHP``n``RACOUNT), `_PS7_RAW_(SAXIHP``n``WACOUNT), \
  `_PS7_RAW_(SAXIHP``n``RCOUNT), `_PS7_RAW_(SAXIHP``n``WCOUNT), \
  `_PS7_RAW_(SAXIHP``n``RDISSUECAP1EN), `_PS7_RAW_(SAXIHP``n``WRISSUECAP1EN)
// input FPGAIDLEN; indicates to CPU that AXI is idle
// input [3:0] DDRARB; indicates to AXIHP port of urgent DDR need

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
