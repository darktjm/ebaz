`default_nettype none
`include "ebaz-eth.v" // also includes zynq-ps7.v

`include "ysv-supt.v"

module top (
  output wire CLK25,
  output wire [3:0] HDMI_TX_P, HDMI_TX_N,
  `EBAZ_ETH_Ports
);

  // ARM/PS7 interface
  `EBAZ_ETH_VLOG
  wire[3:0] fclk;
  PS7 arm (
      .FCLKCLK(fclk),
      `EBAZ_ETH_PS7
  );

  // Master clock
  wire clk125;
  BUFG bufg (.I(fclk[0]), .O(clk125));

wire clk100, clk100_;
wire clk_pixel;
wire clk_shift;
wire clk_audio;

pll pll(.fclk(clk125), .clk25(CLK25), .clk100(clk100_));
// BUFG needed for PLL input
BUFG bufg2 (.I(clk100_), .O(clk100));

reg [11:0] acnt = 0;
always @(posedge clk100)
  acnt <= acnt == (100000/48)-1 ? 0 : acnt + 1;
assign clk_audio = acnt[10];

reg [`va(16,2)] audio_sample_word;
reg [30:0] ctr = 0;
always @(posedge clk125) begin
  ctr <= ctr + 1;
  audio_sample_word[`vai(16,0)] <= ctr[16:8];
  audio_sample_word[`vai(16,1)] <= ctr[15:7];
end

reg [23:0] rgb = 24'd0;
wire [11:0] cx, cy, frame_width, frame_height, screen_width, screen_height;
// Border test (left = red, top = green, right = blue, bottom = blue, fill = black)
always @(posedge clk_pixel)
  rgb <= {cx == 0 ? ~8'd0 : 8'd0, cy == 0 ? ~8'd0 : 8'd0,
          cx == frame_width - 1'd1 || cy == frame_height - 1'd1 ? ~8'd0 : 8'd0};

  genvar i;
  wire [`va(10,4)] hdmi_tx;
  reg [9:0] hdmi_shift[3:0];
  reg [4:0] pb = 5'b1;
  always @(posedge clk_shift)
     pb <= { pb[3:0], pb[4] };
  for(i = 0; i < 4; i = i + 1) begin
      always @(posedge clk_shift)
//         hdmi_shift[i] <= pb[0] ? hdmi_tx[10*i+9:10*i] : { 2'b0, hdmi_shift[i][9:2] };
         hdmi_shift[i] <= pb[0] ? hdmi_tx[i] : { 2'b0, hdmi_shift[i][9:2] };
      wire ddr_out;
      ODDR #(.DDR_CLK_EDGE("SAME_EDGE")) ddr (.D1(hdmi_shift[i][0]), .D2(hdmi_shift[i][1]), .Q(ddr_out),
                 .C(clk_shift), .CE(1'b1), .S(1'b0), .R(1'b0));
      OBUFDS vidout(.I(ddr_out), .O(HDMI_TX_P[i]), .OB(HDMI_TX_N[i]));
  end

//vpll25_2 vpll(.clk100(clk100), .clk_pixel(clk_pixel), .clk_shift(clk_shift));
//hdmi #(.VIDEO_ID_CODE(1), .VIDEO_REFRESH_RATE(60), // 640x480@60
//vpll40 vpll(.clk100(clk100), .clk_pixel(clk_pixel), .clk_shift(clk_shift));
//hdmi #(.VIDEO_ID_CODE(0), // 800x600@60
//       .VIDEO_RATE(40000000), .SCREEN_WIDTH(800), .SCREEN_HEIGHT(600),
//       .FRAME_WIDTH(800+88+128+40), .FRAME_HEIGHT(600+23+4+1),
//       .HSYNC_PULSE_START(40), .HSYNC_PULSE_SIZE(128),
//       .VSYNC_PULSE_START(1), .VSYNC_PULSE_SIZE(4),
//vpll65 vpll(.clk100(clk100), .clk_pixel(clk_pixel), .clk_shift(clk_shift));
//hdmi #(.VIDEO_ID_CODE(0), // 800x600@60
//       .VIDEO_RATE(65000000), .SCREEN_WIDTH(1024), .SCREEN_HEIGHT(768),
//       .FRAME_WIDTH(1024+24+130+160), .FRAME_HEIGHT(768+3+6+29),
//       .HSYNC_PULSE_START(24), .HSYNC_PULSE_SIZE(130),
//       .VSYNC_PULSE_START(3), .VSYNC_PULSE_SIZE(6),
//vpllm74_25 vpll(.clk100(clk100), .clk_pixel(clk_pixel), .clk_shift(clk_shift));
//hdmi #(.VIDEO_ID_CODE(4), .VIDEO_REFRESH_RATE(60), // 1280x720@60
//vpllm74_25 vpll(.clk100(clk100), .clk_pixel(clk_pixel), .clk_shift(clk_shift));
//hdmi #(.VIDEO_ID_CODE(34), .VIDEO_REFRESH_RATE(30), // 1920x1080@30
//vpllm148_5 vpll(.clk100(clk100), .clk_pixel(clk_pixel), .clk_shift(clk_shift));
//hdmi #(.VIDEO_ID_CODE(16), .VIDEO_REFRESH_RATE(60), // 1920x1080@60
vpll120_75 vpll(.clk100(clk100), .clk_pixel(clk_pixel), .clk_shift(clk_shift));
hdmi #(.VIDEO_ID_CODE(0), // 2560x1440@30
       .VIDEO_RATE(120750000), .SCREEN_WIDTH(2560), .SCREEN_HEIGHT(1440),
       .FRAME_WIDTH(2560+48+32+80), .FRAME_HEIGHT(1440+3+5+33),
       .HSYNC_PULSE_START(48), .HSYNC_PULSE_SIZE(32),
       .VSYNC_PULSE_START(3), .VSYNC_PULSE_SIZE(5),
//hdmi #(.VIDEO_ID_CODE(0), // 2560x1440@60
//       .VIDEO_RATE(241500000), .SCREEN_WIDTH(2560), .SCREEN_HEIGHT(1440),
//       .FRAME_WIDTH(2560+48+32+80), .FRAME_HEIGHT(1440+3+5+33),
//       .HSYNC_PULSE_START(48), .HSYNC_PULSE_SIZE(32),
//       .VSYNC_PULSE_START(3), .VSYNC_PULSE_SIZE(5),
       .AUDIO_RATE(48000), .AUDIO_BIT_WIDTH(16)) hdmi(
  .clk_pixel(clk_pixel),
  .clk_audio(clk_audio),
  .reset(1'b0),
  .rgb(rgb),
  .audio_sample_word(audio_sample_word),
  .tmds_dat(hdmi_tx[`vas(10,2,0)]),
  .tmds_clock(hdmi_tx[`vai(10,3)]),
  .cx(cx),
  .cy(cy),
  .frame_width(frame_width),
  .frame_height(frame_height),
  .screen_width(screen_width),
  .screen_height(screen_height)
);


endmodule
