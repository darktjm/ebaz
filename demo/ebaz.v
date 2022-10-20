`default_nettype none
`include "ebaz-eth.v"

`define test_eth
`define test_lcd
`define test_hdmi
`define test_uart

module top(
  output wire CLK25,

`ifdef test_uart
  output wire LED_RED, LED_GREEN, /* active low */
`endif

//  output wire H4_03, H4_04, H4_05, H4_06, H4_07, H4_08,
//              H4_09, H4_10, H4_11, H4_12, H4_13, H4_14,
//	      H4_15, H4_16, H4_17, H4_18, H4_19, H4_20,
//  output wire H4_11, H4_12, H4_13, H4_14, H4_15, H4_16,
//              H4_17, H4_18, H4_19, H4_20,

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
  output wire TMDI_CK_P, TMDI_CK_N,
  output wire [2:0]TMDI_TX_P, TMDI_TX_N
`endif

`ifdef test_eth,
  `EBAZ_ETH_Ports
`endif
);

  wire clk125, clk25;
  BUFG bufg (.I(fclk[0]), .O(clk125));
  pll pll25 (.fclk(clk125), .clk25(clk25));
  BUFG bufg2 (.I(clk25), .O(CLK25));

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

  reg [30:0] ctr = 0;
  always @(posedge clk125)
    ctr <= ctr + 1;

  //reg [2:0] viddiv = 0;
  
  //always @(posedge clk125) begin
  //   if(viddiv == 5)
  //     viddiv <= 0;
  //   else
  //     viddiv <= viddiv + 1;
  //end
  //assign CLK25 = viddiv[1];
  //BUFR #(.BUFR_DIVIDE(5)) buf25 (.I(clk125), .O(CLK25), .CE(1'b1), .CLR(1'b0));

//assign { H4_03, H4_04, H4_05, H4_06, H4_07, H4_08,
//         H4_09, H4_10, H4_11, H4_12, H4_13, H4_14,
//	 H4_15, H4_16, H4_17, H4_18, H4_19, H4_20} = ctr[17:0];

`ifdef test_uart
`ifndef uart1
  wire txbusy, rxrdy;
  reg urd = 0, uwr = 0;
  wire [7:0] rxd;
  reg [7:0] txd;
  assign LED_RED = ~txbusy, LED_GREEN = ~rxrdy;
  buart #(.CLKFREQ(125000000)) uart(
     .rx(FPGA_RXD), .tx(FPGA_TXD), .baud(115200),
     .resetq(1'b1), .clk(clk125), .rd(urd), .wr(uwr),
     .valid(rxrdy), .rx_data(rxd), .busy(txbusy), .tx_data(txd));

  reg del = 0;
  always @(posedge clk125) begin
     if(rxrdy)
	txd <= rxd;
     del <= rxrdy;
     uwr <= del;
     urd <= uwr;
  end
`else
  simpleuart uart (
    .clk(clk125), .resetn(1'b1), .ser_tx(FPGA_TXD), .ser_rx(FPGA_RXD),
    .reg_div_we(4'b1111), .reg_div_di(125000000/115200),
    .reg_dat_we(uwr), .reg_dat_re(urd), .reg_data_do(rxd),
    .reg_data_di(txd), .reg_dat_wait(busy));

`endif
`endif

//  assign BEEP = |(ctr[18:14] & ~KEY);
  assign BEEP = ctr[16] & ~KEY[4]; // S
  assign LED[3:1] = ctr[27:25];

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
  assign LCD_BL = KEY[3]; // C
`endif

`ifdef test_hdmi
  // VGA signal generator

//`define r640x480
//`define r800x600
//`define r1024x768
`define r1280x720
//`define r1920x1080
//`define r2560x1440

`ifdef r640x480
localparam dot_clk = 252;
localparam dot_scale = 10;
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

`ifdef r800x600
localparam dot_clk = 40;
localparam dot_scale = 1;
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

`ifdef r1024x768
localparam dot_clk = 65;
localparam dot_scale = 1;
localparam DVI_H_ACTIVE = 12'd1024;
localparam DVI_H_BPORCH = 12'd160;
localparam DVI_H_SYNC = 12'd136;
localparam DVI_H_FPORCH = 12'24;
localparam DVI_V_ACTIVE = 12'768;
localparam DVI_V_BPORCH = 12'd29;
localparam DVI_V_SYNC = 12'd6;
localparam DVI_V_FPORCH = 12'd3;
localparam DVI_H_POLAR = 1'b0;
localparam DVI_V_POLAR = 1'b0;
`endif

// 720p
`ifdef r1280x720
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
localparam dot_clk = 7425;
localparam dot_scale = 100;
`endif

// 1080p 30hz
`ifdef r1920x1080
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
localparam dot_clk = 7425;
localparam dot_scale = 100;
`endif

// 1440p
`ifdef r2560x1440
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
localparam dot_clk = 2415;
localparam dot_scale = 10;

// This is from the Tang Nano 4K demo.
// It is invalid:  a vain attempt to squeeze a display
// out with lower frequencies.  The 4K has a max. I/O
// rate of 400MHz for LVDS, and a max. PLL out of 600MHz.
// The former implies 40MHz max dot clock, but that's wrong.
// If you take DDR into account, that's 80 MHz max.  If you
// take PLL output max, it's 120MHz max.  And yet the demo uses
// 154MHz somehow.  In any case, it's unusable on my monitor.
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
`endif

  wire clk_pixel, clk_shift;
  wire clk_pixel_, clk_shift_;
  vidpll vpll(.fclk(clk125), .clk_pixel(clk_pixel_), .clk_shift(clk_shift_));
  BUFG bufgpix (.I(clk_pixel_), .O(clk_pixel));
  BUFG bufgshift (.I(clk_shift_), .O(clk_shift));
//   assign clk_pixel = CLK25;
//   assign clk_shift = clk125;

  wire [7:0] vga_r, vga_g, vga_b;
  wire vga_hsync, vga_vsync, vga_blank;
  vga
  #(
    .c_resolution_x(DVI_H_ACTIVE),
    .c_hsync_front_porch(DVI_H_FPORCH),
    .c_hsync_pulse(DVI_H_SYNC),
    .c_hsync_back_porch(DVI_H_BPORCH),
    .c_resolution_y(DVI_V_ACTIVE),
    .c_vsync_front_porch(DVI_V_FPORCH),
    .c_vsync_pulse(DVI_V_SYNC),
    .c_vsync_back_porch(DVI_V_BPORCH),
    .c_bits_x(11),
    .c_bits_y(11)
  )
  vga_instance
  (
    .clk_pixel(clk_pixel),
    .clk_pixel_ena(1'b1),
    .test_picture(1'b1), // enable test picture generation
    .vga_r(vga_r),
    .vga_g(vga_g),
    .vga_b(vga_b),
    .vga_hsync(vga_hsync),
    .vga_vsync(vga_vsync),
    .vga_blank(vga_blank)
  );
  // VGA to digital video converter
  wire [7:0] tmds_ddr;
  vga2dvid
  #(
    .c_ddr(1'b1),
    .c_shift_clock_synchronizer(1'b0) // would 1 work?
  )
  vga2dvid_instance
  (
    .clk_pixel(clk_pixel),
    .clk_shift(clk_shift),
    .in_red(vga_r),
    .in_green(vga_g),
    .in_blue(vga_b),
    .in_hsync(vga_hsync),
    .in_vsync(vga_vsync),
    .in_blank(vga_blank),
    .out_clock(tmds_ddr[7:6]),
    .out_red  (tmds_ddr[5:4]),
    .out_green(tmds_ddr[3:2]),
    .out_blue (tmds_ddr[1:0])
  );

  wire [3:0]tmdi_p, tmdi_n;
  assign tmdi_p[3] = TMDI_CK_P, tmdi_n[3] = TMDI_CK_N;
  assign tmdi_p[2:0] = TMDI_TX_P, tmdi_n[2:0] = TMDI_TX_N;
  generate
    genvar i;
    for(i = 0; i < 4; i = i + 1) begin
      wire ddr_out;
      ODDR #(.DDR_CLK_EDGE("SAME_EDGE")) ddr (.D1(tmds_ddr[i*2]), .D2(tmds_ddr[i*2+1]), .Q(ddr_out),
                 .C(clk_shift), .CE(1'b1), .S(1'b0), .R(1'b0));
      OBUFDS vidout(.I(ddr_out), .O(tmdi_p[i]), .OB(tmdi_n[i]));
    end
  endgenerate
//  assign H4_11 = vga_hsync, H4_12 = vga_vsync;
//       H4_13 = tmds_ddr[2], H4_14 = tmds_ddr[3];
//	 H4_15 = tmds_ddr[4], H4_16 = tmds_ddr[5],
//	 H4_17 = tmds_ddr[6], H4_18 = tmds_ddr[7];

//   reg [9:0] sctr = 0;
//   always @(posedge CLK25)
//     sctr = sctr + 1'b1;

//   reg [9:0] pctr = 0;
//   always @(posedge clk_pixel)
//     pctr = pctr + 1'b1;

//   OBUFDS ob0(.I(vga_vsync), .O(H4_11), .OB(H4_12));
//   OBUFDS ob1(.I(vga_hsync), .O(H4_14), .OB(H4_13));
//   OBUFDS ob2(.I(pctr[9]), .O(H4_16), .OB(H4_15));
//   OBUFDS ob3(.I(sctr[9]), .O(H4_18), .OB(H4_17));
//   assign H4_19 = 1'b0, H4_20 = 1'b0;
//   OBUF #(.SLEW("FAST")) ob8(.I(ctr[1]), .O(H4_19));
//   OBUF #(.SLEW("FAST")) ob9(.I(ctr[0]), .O(H4_20));

//  OBUFDS hout (.I(ctr[11]), .O(H4_18), .OB(H4_17));
//  OBUFDS hout2 (.I(ctr[12]), .O(H4_16), .OB(H4_15));

//  wire d11, d13, d16, d18;
//  ODDR ddr1 (.D1(tmds_ddr[6]), .D2(tmds_ddr[7]), .Q(d11));
//  OBUFDS vidout1(.I(d11), .O(H4_11), .OB(H4_12));
//  ODDR ddr2 (.D1(tmds_ddr[4]), .D2(tmds_ddr[5]), .Q(d13));
//  OBUFDS vidout2(.I(d13), .O(H4_14), .OB(H4_13));
//  ODDR ddr3 (.D1(tmds_ddr[2]), .D2(tmds_ddr[3]), .Q(d16));
//  OBUFDS vidout3(.I(d16), .O(H4_16), .OB(H4_15));
//  ODDR ddr4 (.D1(tmds_ddr[0]), .D2(tmds_ddr[1]), .Q(d18));
//  OBUFDS vidout4(.I(d18), .O(H4_18), .OB(H4_17));
`endif


endmodule
