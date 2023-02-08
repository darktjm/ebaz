// Exercise ebaz4205 board w/ HDMI expansion board, preferably w/ free tools:
//  Base board FPGA resources:
//    Ethernet (just passthrough for PS7-Linux; no raw ethernet for this)
`define test_eth // probably not a good idea to disable this
//    Red/Green LEDs
//    Optoisolated fan connectors: untested
//    48 signals on 3 2mm DATA ports (to expansion board)
//  CPU GPIO (64 bits; untested), IRQ (20 F->P 29P->F; untested), EV (untested)
//  CPU-attached resources:
//    Rear pushbutton(s) (MIO20/32) (GPIO fwd?  AXI_GP? untested)
//    256MB DDR RAM (16-bit DDR I/F) (AXI_HP?  untested)
//    256KB OCM static RAM, 512KB cache (AXI_ACP? untested)
//    128MB Flash (boot NFL I/F) (AXI_GP?  untested)
//    SD card (SDIO0) (AXI_GP?  untested)
//  CPU EMIO interfaces:
//    Ethernetx2 (ENET0 used in passthrough)
//    I2Cx2 (untested)
//    CANx2 (untested)
//    UARTx2 (untested) (UART1 is also used for console)
//    SDIOx2 (untested) (slow: 25MHz max vs. 50MHz max in hardware) (SDIO0=hw)
//    SPIx2 (untested) (slow: 25MHz max vs. 50MHz max in hardware)
//    ITCx2 (untested)
//    WDT (untested)
//    PJTAG, TRACE not going to touch
//    Note that USB, QSPI can't be done via EMIO (or by hardware due to ebaz)
//  CPU AXI (M/S-GPx2 S-ACP S-HPx4) (untested)
//    S_AXI_ACP 64-bit cache coherent FPGA master (uses CPU L1/L2)
//    S_AXI_HP0-3 32/64-bit high performace FPGA master
//    S_AXI_GP0-1 32-bit async FPGA master
//    M_AXI_GP0-1 32-bit async FPGA slave (DMAx4-capable, XIP-capable)
//  Other clocks (not just fclk0) (untested)
//     Set clocks in boot loader (untested; probably sd boot only)
//  Don't care about fabric trace module atm
//  HDMI expansion board resources:
//    3x LED
//    5x Pushbuttons
//    Bit banging buzzer
//    128x128 SPI LCD screen
`define test_lcd
//    USB UART
//`define test_uart
//    HDMI connector
`define test_hdmi
// f4pga (yosys+vpr) and (yosys+)nextpnr-xilinx do not support MMCM
// (technically f4pga supports MMCM, but not on xc7z010).
`ifndef YOSYS
`define mmcm
`endif
// Only enable 1 resolution.  Changing it requires changing the PLL, since
// I don't do dynamic PLL config (yet).  The C-based PLL generator generates
// a single static PLL for every frequency pair (my old Verilog one was
// easier to use, but too slow w/ yosys and no longer maintained).
// Ideally, I should just have a resolution switcher button and support all
// of the below, at least.  There's no I2C connection, so it's impossible to
// use DDC to find resolutions.
//
// Current progress:
// f4pga (yosys+vpr): (no MMCM, no BUFR)
//   Using hdmi-audio encoder, only 1280x720 gives any video, and it's 4:3
//     with tons of red vertical stripes.  No audio.
//   Using old dvi encoder, only 1024x768, 1280x720 have video, and that's
//     corrupted w/ red vertical stripes (mostly stable, though)
//   Chucked f4pga before finishing the yosys conversion of "hdmi" encoder
// yosys+nextpnr-xilinx: (no MMCM, no BUFR)
//   Fails to build; can't route ODDR to OBUFDS.
// Vivado:
//   Perfect video with dvi, hdmi-audio, "hdmi" encoder up to 1920x1080@30
//     Nothiing past that, even though independent tests of "hdmi" gave
//       video+audio w/ 2560x1440@30 and video at least on 1920x1080@60.
//       I guess it depends on how things get optimized/layed out.
//     No audio on hdmi-audio encoder, but perfect audio on "hdmi".
//`define r640x480
//`define r800x600
//`define r1024x768
//`define r1280x720
`define r1920x1080_30
//`define r2560x1440_30
//`define r1920x1080
//`define r2560x1440
//`define r2560x1440_75
//    18 pins on .100/2.54mm header (H4)
//`define test_h4
///////////////////////////////////////////////////////////////////////

`default_nettype none
`include "ebaz-eth.v" // also includes zynq-ps7.v
`include "ysv-supt.v"

module top(
  output wire LED_RED, LED_GREEN, /* active low */

`ifdef test_h4
  output wire H4_03, H4_04, H4_05, H4_06, H4_07, H4_08,
              H4_09, H4_10, H4_11, H4_12, H4_13, H4_14,
	      H4_15, H4_16, H4_17, H4_18, H4_19, H4_20,
`endif

  output wire [3:1] LED, /* active high */
  input wire [5:1] KEY, /* active low */ /* NWCSE */
  output wire BEEP /* active high */

`ifdef test_lcd,
  output wire LCD_BL, LCD_DC, LCD_RES, LCD_SCL, LCD_SDA
`endif

`ifdef test_uart,
  input wire FPGA_RXD,
  output wire FPGA_TXD
`endif

`ifdef test_hdmi,
  output wire [3:0] HDMI_TX_P, HDMI_TX_N
`endif

`ifdef test_eth,
  output wire CLK25, // For Ethernet, if no on-board XTAL (untested; mine has xtal)
  `EBAZ_ETH_Ports
`endif
);

  // Master clock
  wire clk125;
  // Should't use BUFG for all clocks; just ones with large fanout
  // BUFG needed for PLL input or vpr will spin forever
  BUFG bufg (.I(fclk[0]), .O(clk125));
//  assign clk125 = fclk[0];

  // Ethernet clock, but also for other 25Mhz needs
  // f4pga doesn't support BUFR
  //BUFR #(.BUFR_DIVIDE(5)) buf25 (.I(clk125), .O(CLK25), .CE(1'b1), .CLR(1'b0));
  // so waste a PLL on it.  f4pga also doesn't support MMCM, so there are only
  // 2 plls total as well (rather than 4).  What a waste.
  // Well, since 100MHz gives more accurate video timings, and I currently
  // just use the default supplied 125MHz fclk[0], I guess this has some use
  // now in generating a 100MHz clock.
  wire clk25, clk100, clk100_;
`ifndef test_eth
  wire CLK25;
`endif
  pll pll25 (.fclk(clk125), .clk25(clk25), .clk100(clk100_));
  // BUFG inserted automatically by Vivado, anyway
  BUFG bufg2 (.I(clk25), .O(CLK25));
  // BUFG needed for PLL input or vpr will spin forever
  BUFG bufg3 (.I(clk100_), .O(clk100));

  // ARM/PS7 interface
  // TODO: look at ebaz kernel source and see if anything else needs
  // forwarding.  For example, where do the R/G LEDs get driven from?
  // Do the rear pushbuttons get forwarded?
  // Currently only ethernet forwarding and main system clock
`ifdef test_eth
  `EBAZ_ETH_VLOG
`endif

  wire[3:0] fclk;
  PS7 arm (
      .FCLKCLK(fclk)
`ifdef test_eth,
      `EBAZ_ETH_PS7
`endif
  );

  // Counter for blinky, audio, H4 exercise
  reg [30:0] ctr = 0;
  always @(posedge clk125)
    ctr <= ctr + 1;

`ifdef test_h4
assign { H4_03, H4_04, H4_05, H4_06, H4_07, H4_08,
         H4_09, H4_10, H4_11, H4_12, H4_13, H4_14,
	 H4_15, H4_16, H4_17, H4_18, H4_19, H4_20} = ctr[17:0];
`endif

`ifdef test_uart
  wire txbusy, rxrdy;
  reg urd = 0, uwr = 0;
  wire [7:0] rxd;
  reg [7:0] txd;
  assign LED_RED = ~txbusy, LED_GREEN = ~rxrdy;
  buart #(.CLKFREQ(125000000)) uart(
     .rx(FPGA_RXD), .tx(FPGA_TXD), .baud(115200),
     .resetq(1'b1), .clk(clk125), .rd(urd), .wr(uwr),
     .valid(rxrdy), .rx_data(rxd), .busy(txbusy), .tx_data(txd));

  // Just echo
  reg del = 0;
  always @(posedge clk125) begin
     if(rxrdy)
	txd <= rxd;
     del <= rxrdy;
     uwr <= del;
     urd <= uwr;
  end
`endif

//  assign BEEP = |(ctr[18:14] & ~KEY);
  assign BEEP = ctr[16] & ~KEY[4]; // S
  assign LED[3:1] = ctr[27:25];
`ifndef test_uart
  assign LED_GREEN = ~ctr[28], LED_RED = ~ctr[29];
`endif

`ifdef test_lcd
  wire  [7:0] disp_x;
  wire  [7:0] disp_y;
  wire [15:0] disp_color;
  lcd_video
  #(
    .c_init_file("st7789_linit_xyflip.mem"),
    .c_init_size(35),
    .c_clk_spi_mhz(125)
  )
  lcd_video_inst
  (
    .reset(1'b0),
    .clk_pixel(clk125),
    .clk_spi(clk125),
    .x(disp_x),
    .y(disp_y),
    .color(disp_color),
//    .color(16'hf81f),
//    .spi_csn(spi_csn), // permanently on
    .spi_clk(LCD_SCL),
    .spi_mosi(LCD_SDA),
    .spi_dc(LCD_DC),
    .spi_resn(LCD_RES)
  );
  wire [15:0] color_gs = { disp_x[7:3], disp_x[7:2], disp_x[7:3] };
//  wire [15:0] color_gs = { {15{rxd[disp_x[7:5]]}} };
  wire [15:0] color_bars = {
      {5{disp_x[7]}}, {6{disp_x[6]}}, {5{disp_x[5]}}};
  assign disp_color = disp_y > 120 ? color_bars : color_gs;
  // FIXME:  This doesn't work.  BL is always on.  Why?
  assign LCD_BL = KEY[3]; // C
`endif

`ifdef test_hdmi
  // VGA signal generator

`ifdef r640x480 // @60Hz
localparam mode_id = 1;
// Parameters for old static Verilog PLL calculator
localparam dot_clk = 252;
localparam dot_scale = 10;
// Parameter for current static PLLs
`define vpll vpll25_2
// Parameters for dynamic PLL, if ever
// DIVCLK_DIVIDE=5 CLKOUT0_DIVIDE=50 CLKOUT1_DIVIDE=10 CLKFBOUT_MULT=63
localparam DVI_H_ACTIVE = 12'd640;
localparam DVI_H_FPORCH = 12'd16;
localparam DVI_H_SYNC = 12'd96;
localparam DVI_H_BPORCH = 12'd48;
localparam DVI_V_ACTIVE = 12'd480;
localparam DVI_V_FPORCH = 12'd10;
localparam DVI_V_SYNC = 12'd2;
localparam DVI_V_BPORCH = 12'd33;
localparam DVI_H_POLAR = 1'b0;
localparam DVI_V_POLAR = 1'b0;
`endif

`ifdef r800x600 // @60Hz
localparam mode_id = 0; // No defined code; probably never will be
// Parameters for old static Verilog PLL calculator
localparam dot_clk = 40;
localparam dot_scale = 1;
// Parameter for current static PLLs
`define vpll vpll40
// Parameters for dynamic PLL, if ever
// DIVCLK_DIVIDE=1 CLKOUT0_DIVIDE=40 CLKOUT1_DIVIDE=8 CLKFBOUT_MULT=16
localparam DVI_H_ACTIVE = 12'd800;
localparam DVI_H_BPORCH = 12'd88;
localparam DVI_H_SYNC = 12'd128;
localparam DVI_H_FPORCH = 12'd40;
localparam DVI_V_ACTIVE = 12'd600;
localparam DVI_V_BPORCH = 12'd23;
localparam DVI_V_SYNC = 12'd4;
localparam DVI_V_FPORCH = 12'd1;
localparam DVI_H_POLAR = 1'b1;
localparam DVI_V_POLAR = 1'b1;
`endif

`ifdef r1024x768 // @60Hz
localparam mode_id = 0; // No defined code; probably never will be
// Parameters for old static Verilog PLL calculator
localparam dot_clk = 65;
localparam dot_scale = 1;
// Parameter for current static PLLs
`define vpll vpll65
// Parameters for dynamic PLL, if ever
// DIVCLK_DIVIDE=1 CLKOUT0_DIVIDE=20 CLKOUT1_DIVIDE=4 CLKFBOUT_MULT=13
localparam DVI_H_ACTIVE = 12'd1024;
localparam DVI_H_BPORCH = 12'd160;
localparam DVI_H_SYNC = 12'd136;
localparam DVI_H_FPORCH = 12'd24;
localparam DVI_V_ACTIVE = 12'd768;
localparam DVI_V_BPORCH = 12'd29;
localparam DVI_V_SYNC = 12'd6;
localparam DVI_V_FPORCH = 12'd3;
localparam DVI_H_POLAR = 1'b0;
localparam DVI_V_POLAR = 1'b0;
`endif

`ifdef r1280x720 // @60Hz
localparam mode_id = 4;
// Parameters for old static Verilog PLL calculator
localparam dot_clk = 7425;
localparam dot_scale = 100;
// Parameter for current static PLLs
`ifndef mmcm
`define vpll vpll74_25
`else
`define vpll vpllm74_25
`endif
// Parameters for dynamic PLL, if ever (99.66% accurate on PLL)
// DIVCLK_DIVIDE=5 CLKOUT0_DIVIDE=10 CLKOUT1_DIVIDE=2 CLKFBOUT_MULT=37
// MMCM (100%):
// DIVCLK_DIVIDE=5 CLKOUT0_DIVIDE_F=10 CLKOUT1_DIVIDE=2 CLKFBOUT_MULT_F=37.125
localparam DVI_H_BPORCH = 12'd220;
localparam DVI_H_ACTIVE = 12'd1280;
localparam DVI_H_FPORCH = 12'd110;
localparam DVI_H_SYNC   = 12'd40;
localparam DVI_H_POLAR  = 1'b1;
localparam DVI_V_BPORCH = 12'd20;
localparam DVI_V_ACTIVE = 12'd720;
localparam DVI_V_FPORCH = 12'd5;
localparam DVI_V_SYNC   = 12'd5;
localparam DVI_V_POLAR  = 1'b1;
`endif

`ifdef r1920x1080_30
localparam mode_id = 34;
// Parameters for old static Verilog PLL calculator
localparam dot_clk = 7425;
localparam dot_scale = 100;
// Parameter for current static PLLs
`ifndef mmcm
`define vpll vpll74_25
`else
`define vpll vpllm74_25
`endif
// Parameters for dynamic PLL, if ever (99.66% accurate on PLL)
// DIVCLK_DIVIDE=5 CLKOUT0_DIVIDE=10 CLKOUT1_DIVIDE=2 CLKFBOUT_MULT=37
// MMCM (100%):
// DIVCLK_DIVIDE=5 CLKOUT0_DIVIDE_F=10 CLKOUT1_DIVIDE=2 CLKFBOUT_MULT_F=37.125
localparam DVI_H_BPORCH = 12'd148;
localparam DVI_H_ACTIVE = 12'd1920;
localparam DVI_H_FPORCH = 12'd88;
localparam DVI_H_SYNC   = 12'd44;
localparam DVI_H_POLAR  = 1'b1;
localparam DVI_V_BPORCH = 12'd36;
localparam DVI_V_ACTIVE = 12'd1080;
localparam DVI_V_FPORCH = 12'd4;
localparam DVI_V_SYNC   = 12'd5;
localparam DVI_V_POLAR  = 1'b1;
`endif

`ifdef r1920x1080 // @60Hz
localparam mode_id = 16;
// Parameters for old static Verilog PLL calculator
localparam dot_clk = 2415;
localparam dot_scale = 10;
// Parameter for current static PLLs
`ifndef mmcm
`define vpll vpll148_5
`else
`define vpll vpllm148_5
`endif
// Parameters for dynamic PLL, if ever (99.66% accurate on PLL)
// DIVCLK_DIVIDE=5 CLKOUT0_DIVIDE=10 CLKOUT1_DIVIDE=2 CLKFBOUT_MULT=37
// MMCM (100%):
// DIVCLK_DIVIDE=5 CLKOUT0_DIVIDE_F=5 CLKOUT1_DIVIDE=1 CLKFBOUT_MULT_F=37.125
localparam DVI_H_BPORCH = 12'd148;
localparam DVI_H_ACTIVE = 12'd1920;
localparam DVI_H_FPORCH = 12'd88;
localparam DVI_H_SYNC   = 12'd44;
localparam DVI_H_POLAR  = 1'b0;
localparam DVI_V_BPORCH = 12'd36;
localparam DVI_V_ACTIVE = 12'd1080;
localparam DVI_V_FPORCH = 12'd4;
localparam DVI_V_SYNC   = 12'd5;
localparam DVI_V_POLAR  = 1'b0;
`endif

`ifdef r2560x1440_30
localparam mode_id = 0; // No defined code; custom mode not in my monitor
// Parameters for old static Verilog PLL calculator
localparam dot_clk = 12075;
localparam dot_scale = 100;
// Parameter for current static PLLs
`ifndef mmcm
`define vpll vpll120_75
`else
`define vpll vpllm120_75
`endif
// Parameters for dynamic PLL, if ever (99.38% accurate PLL)
// DIVCLK_DIVIDE=1 CLKOUT0_DIVIDE=10 CLKOUT1_DIVIDE=2 CLKFBOUT_MULT=12
// MMCM (100%) -- cheat: set max VCO freq = 1208
//                       needs DRC PDRC-34 disabled
// DIVCLK_DIVIDE=5 CLKOUT0_DIVIDE_F=10 CLKOUT1_DIVIDE=2 CLKFBOUT_MULT_F=60.375
localparam DVI_H_BPORCH = 12'd80;
localparam DVI_H_ACTIVE = 12'd2560;
localparam DVI_H_FPORCH = 12'd48;
localparam DVI_H_SYNC   = 12'd32;
localparam DVI_H_POLAR  = 1'b1;
localparam DVI_V_BPORCH = 12'd33;
localparam DVI_V_ACTIVE = 12'd1440;
localparam DVI_V_FPORCH = 12'd3;
localparam DVI_V_SYNC   = 12'd5;
localparam DVI_V_POLAR  = 1'b1;
`endif

`ifdef r2560x1440 // @60Hz
localparam mode_id = 0; // No defined code; probably never will be
// Parameters for old static Verilog PLL calculator
localparam dot_clk = 2415;
localparam dot_scale = 10;
// Parameter for current static PLLs
`ifndef mmcm
`define vpll vpll241_5
`else
`define vpll vpllm241_5
`endif
// Parameters for dynamic PLL, if ever (99.38% accurate, PLL or MMCM)
// DIVCLK_DIVIDE=1 CLKOUT0_DIVIDE=5 CLKOUT1_DIVIDE=1 CLKFBOUT_MULT=12
// MMCM (100%) -- cheat: set max VCO freq = 1208
//                       needs DRC PDRC-34 disabled
// DIVCLK_DIVIDE=5 CLKOUT0_DIVIDE_F=5 CLKOUT1_DIVIDE=1 CLKFBOUT_MULT_F=60.375
localparam DVI_H_BPORCH = 12'd80;
localparam DVI_H_ACTIVE = 12'd2560;
localparam DVI_H_FPORCH = 12'd48;
localparam DVI_H_SYNC   = 12'd32;
localparam DVI_H_POLAR  = 1'b1;
localparam DVI_V_BPORCH = 12'd33;
localparam DVI_V_ACTIVE = 12'd1440;
localparam DVI_V_FPORCH = 12'd3;
localparam DVI_V_SYNC   = 12'd5;
localparam DVI_V_POLAR  = 1'b1;
`endif

// This is from the Tang Nano 4K demo.
// It is invalid:  a vain attempt to squeeze a display
// out with lower frequencies.  The 4K has a max. I/O
// rate of 400MHz for LVDS, and a max. PLL out of 600MHz.
// The former implies 40MHz max dot clock, but that's wrong.
// If you take DDR into account, that's 80 MHz max.  If you
// take PLL output max, it's 120MHz max.  And yet the demo uses
// 154MHz somehow.  In any case, it's unusable on my monitor.
// Parameters for old static Verilog PLL calculator
//localparam dot_clk = 154;
//localparam dot_scale = 1;
//Not going to even add the PLL for this.
//localparam DVI_H_BPORCH = 12'd40;
//localparam DVI_H_ACTIVE = 12'd2560;
//localparam DVI_H_FPORCH = 12'd8;
//localparam DVI_H_SYNC   = 12'd32;
//localparam DVI_H_POLAR  = 1'b1;
//localparam DVI_V_BPORCH = 12'd6;
//localparam DVI_V_ACTIVE = 12'd1440;
//localparam DVI_V_FPORCH = 12'd13;
//localparam DVI_V_SYNC   = 12'd8;
//localparam DVI_V_POLAR  = 1'b0;
//localparam dot_clk = 154;
//localparam dot_scale = 1;

`ifdef r2560x1440_75
localparam mode_id = 0; // No defined code; probably never will be
// Parameters for old static Verilog PLL calculator
localparam dot_clk = 30425;
localparam dot_scale = 100;
// Parameter for current static PLLs
`define vpll vpll304_25
// Parameters for dynamic PLL, if ever (100.25% accurate; too fast for MMCM)
// DIVCLK_DIVIDE=4 CLKOUT0_DIVIDE=5 CLKOUT1_DIVIDE=1 CLKFBOUT_MULT=61
localparam DVI_H_BPORCH = 12'd80;
localparam DVI_H_ACTIVE = 12'd2560;
localparam DVI_H_FPORCH = 12'd48;
localparam DVI_H_SYNC   = 12'd32;
localparam DVI_H_POLAR  = 1'b1;
localparam DVI_V_BPORCH = 12'd44;
localparam DVI_V_ACTIVE = 12'd1440;
localparam DVI_V_FPORCH = 12'd3;
localparam DVI_V_SYNC   = 12'd5;
localparam DVI_V_POLAR  = 1'b0;
`endif

  wire clk_pixel, clk_pixel_, clk_shift, clk_shift_;
  `vpll vpll(
       .clk100(clk100), .clk_pixel(clk_pixel_), .clk_shift(clk_shift_));
  // clk_pixel has high fanout
  BUFG bufgpix (.I(clk_pixel_), .O(clk_pixel));
  // clk_shift has low fanout, but final bitstream gen fails if ODDR C not BUFG
  // NOTE: Do not constrain!!  That seems to confuse VPR:
  // Message: Can not find any logic block that can implement molecule.
  //         Atom genblk1[1].ddr (ODDR_VPR)
  BUFG bufgshift (.I(clk_shift_), .O(clk_shift));

  localparam x_bits = $clog2(DVI_H_ACTIVE+1);
  
  wire [11:0] cx, cy;
  wire [11:0] icx = DVI_H_ACTIVE - 12'b1 - cx;
  wire [7:0] gs = cx > DVI_H_ACTIVE / 2 ?
                     cx[x_bits - 2:x_bits - 9] :
                     icx[x_bits - 2:x_bits - 9];
  wire [7:0] cbr = {8{cx[x_bits - 2]}}, cbg = {8{cx[x_bits - 3]}},
             cbb = {8{cx[x_bits - 4]}};
  wire [7:0] vr, vg, vb;
  assign { vr, vg, vb } = cy > DVI_V_ACTIVE / 2 ? { cbr, cbg, cbb } : { gs, gs, gs };

 wire [7:0] tmds_ddr;
  wire [`va(10,4)] tmds;

  reg [15:0] audio_sample_word [1:0];
  always @(posedge clk125) begin
    audio_sample_word[1] <= {1'b0, {15{~KEY[2]}} & ctr[16:2]}; // W
    audio_sample_word[0] <= {1'b0, {15{~KEY[5]}} & ctr[15:1]}; // E
  end
  wire clk_audio;
  reg [11:0] acnt = 0;
  always @(posedge clk100)
    acnt <= acnt == (100000/48)-1 ? 0 : acnt + 1;
  assign clk_audio = acnt[10];

  wire [11:0] frame_width, frame_height, screen_width, screen_height;
  hdmi #(.VIDEO_ID_CODE(mode_id),
       .VIDEO_RATE(1000000/dot_scale*dot_clk),
       .SCREEN_WIDTH(DVI_H_ACTIVE), .SCREEN_HEIGHT(DVI_V_ACTIVE),
       .FRAME_WIDTH(DVI_H_ACTIVE+DVI_H_FPORCH+DVI_H_SYNC+DVI_H_BPORCH),
       .FRAME_HEIGHT(DVI_V_ACTIVE+DVI_V_FPORCH+DVI_V_SYNC+DVI_V_BPORCH),
       .HSYNC_PULSE_START(DVI_H_FPORCH), .HSYNC_PULSE_SIZE(DVI_H_SYNC),
       .VSYNC_PULSE_START(DVI_V_FPORCH), .VSYNC_PULSE_SIZE(DVI_V_SYNC),
       .AUDIO_RATE(48000), .AUDIO_BIT_WIDTH(16)) hdmi(
  .clk_pixel(clk_pixel),
  .clk_audio(clk_audio),
  .reset(1'b0),
  .rgb({vr, vg, vb}),
  .audio_sample_word({audio_sample_word[1], audio_sample_word[0]}),
  .tmds_dat(tmds[`vas(10,2,0)]),
  .tmds_clock(tmds[`vai(10,3)]),
  .cx(cx),
  .cy(cy),
  .frame_width(frame_width),
  .frame_height(frame_height),
  .screen_width(screen_width),
  .screen_height(screen_height)
);

 reg [9:0] tmds_[2:0];
 reg [4:0] pb = 5'b1;
 always @(posedge clk_shift)
   pb <= { pb[3:0], pb[4] };
                      // 00 00 01 11 11
 assign tmds_ddr = { |pb[1:0], |pb[2:0],
                     tmds_[2][1:0], tmds_[1][1:0], tmds_[0][1:0] };
 genvar i;
 generate
    for(i = 0; i < 3; i = i + 1)
      always @(posedge clk_shift)
        tmds_[i] <= pb[0] ? tmds[`vai(10,i)] : { 2'b0, tmds_[i][9:2] };
    for(i = 0; i < 4; i = i + 1) begin
      wire ddr_out;
      ODDR #(.DDR_CLK_EDGE("SAME_EDGE")) ddr (
                 .D1(tmds_ddr[i*2]), .D2(tmds_ddr[i*2+1]), .Q(ddr_out),
                 .C(clk_shift), .CE(1'b1), .S(1'b0), .R(1'b0));
      OBUFDS vidout(.I(ddr_out), .O(HDMI_TX_P[i]), .OB(HDMI_TX_N[i]));
    end
  endgenerate
`endif

endmodule
