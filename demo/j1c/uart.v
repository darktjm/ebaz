`default_nettype none

// Input parameters:
//   UART_BAUD = fixed baud rate (else dynamic)

// Simple baud generator

module baudgen(
  input wire clk,
`ifndef UART_BAUD
  input wire resetq,
  input wire [31:0] baud,
`endif
  input wire restart,
  output wire ser_clk);
  parameter CLKFREQ = 1000000;

`ifdef UART_BAUD
// FIXME: see if baudgen generates similar gate cnt with fixed baud&resetq input
  parameter BAUD = `UART_BAUD;
  localparam lim = (CLKFREQ / BAUD) - 1; 
  localparam w = $clog2(lim);
  wire [w-1:0] limit = lim;
  reg [w-1:0] counter;
  assign ser_clk = (counter == limit);

  always @(posedge clk)
    if (restart)
      counter <= 0;
    else
      counter <= ser_clk ? 0 : (counter + 1);
`else
  wire [38:0] aclkfreq = CLKFREQ;
  reg [38:0] d;
  wire [38:0] dInc = d[38] ? ({4'd0, baud}) : (({4'd0, baud}) - aclkfreq);
  wire [38:0] dN = restart ? 0 : (d + dInc);
  wire fastclk = ~d[38];
  assign ser_clk = fastclk;

  always @(negedge resetq or posedge clk)
  begin
    if (!resetq) begin
      d <= 0;
    end else begin
      d <= dN;
    end
  end
`endif
endmodule

/*

-----+     +-----+-----+-----+-----+-----+-----+-----+-----+-----+-----+----
     |     |     |     |     |     |     |     |     |     |     |     |
     |start|  1  |  2  |  3  |  4  |  5  |  6  |  7  |  8  |stop1|stop2|
     |     |     |     |     |     |     |     |     |     |     |  ?  |
     +-----+-----+-----+-----+-----+-----+-----+-----+-----+           +

*/

module uart(
   input wire clk,         // System clock
   input wire resetq,

   // Outputs
   output wire uart_busy,   // High means UART is transmitting
   output reg uart_tx,     // UART transmit wire
   // Inputs
`ifndef UART_BAUD
   input wire [31:0] baud,
`endif
   input wire uart_wr_i,   // Raise to transmit byte
   input wire [7:0] uart_dat_i  // 8-bit data
);
  parameter CLKFREQ = 1000000;

  reg [3:0] bitcount;
  reg [8:0] shifter;

  assign uart_busy = |bitcount;
  wire sending = |bitcount;

  wire ser_clk;

  wire starting = uart_wr_i & ~uart_busy;
  baudgen #(.CLKFREQ(CLKFREQ) `ifdef UART_BAUD, .BAUD(`UART_BAUD) `endif) _baudgen(
    .clk(clk),
`ifndef UART_BAUD
    .resetq(resetq),
    .baud(baud),
`endif
    .restart(1'b0),
    .ser_clk(ser_clk));

  always @(negedge resetq or posedge clk)
  begin
    if (!resetq) begin
      uart_tx <= 1;
      bitcount <= 0;
      shifter <= 0;
    end else begin
      if (starting) begin
        shifter <= { uart_dat_i[7:0], 1'b0 };
        bitcount <= 1 + 8 + 1;
      end

      if (sending & ser_clk) begin
        { shifter, uart_tx } <= { 1'b1, shifter };
        bitcount <= bitcount - 4'd1;
      end
    end
  end

endmodule

module rxuart(
   input wire clk,
   input wire resetq,
`ifndef UART_BAUD
   input wire [31:0] baud,
`endif
   input wire uart_rx,      // UART recv wire
   input wire rd,           // read strobe
   output wire valid,       // has data 
   output wire [7:0] data); // data
  parameter CLKFREQ = 1000000;

  reg [4:0] bitcount;
  reg [7:0] shifter;

  // On starting edge, wait 3 half-bits then sample, and sample every 2 bits thereafter

  wire idle = &bitcount;
  wire sample;
  reg [2:0] hh = 3'b111;
  wire [2:0] hhN = {hh[1:0], uart_rx};
  wire startbit = idle & (hhN[2:1] == 2'b10);
  wire [7:0] shifterN = sample ? {hh[1], shifter[7:1]} : shifter;

  wire ser_clk; 
  baudgen #(.CLKFREQ(CLKFREQ) `ifdef UART_BAUD, .BAUD(`UART_BAUD*2) `endif) _baudgen(
    .clk(clk),
`ifndef UART_BAUD
    .baud({baud[30:0], 1'b0}),
    .resetq(resetq),
`endif
    .restart(startbit),
    .ser_clk(ser_clk));

  assign valid = (bitcount == 18);
  reg [4:0] bitcountN;
  always @*
    if (startbit)
      bitcountN = 0;
    else if (!idle & !valid & ser_clk)
      bitcountN = bitcount + 5'd1;
    else if (valid & rd)
      bitcountN = 5'b11111;
    else
      bitcountN = bitcount;

  // 3,5,7,9,11,13,15,17
  assign sample = (|bitcount[4:1]) & bitcount[0] & !valid & ser_clk;
  assign data = shifter;

  always @(negedge resetq or posedge clk)
  begin
    if (!resetq) begin
      hh <= 3'b111;
      bitcount <= 5'b11111;
      shifter <= 0;
    end else begin
      hh <= hhN;
      bitcount <= bitcountN;
      shifter <= shifterN;
    end
  end
endmodule

module buart(
   input wire clk,
   input wire resetq,
`ifndef UART_BAUD
   input wire [31:0] baud,
`endif
   input wire rx,           // recv wire
   output wire tx,          // xmit wire
   input wire rd,           // read strobe
   input wire wr,           // write strobe
   output wire valid,       // has recv data 
   output wire busy,        // is transmitting
   input wire [7:0] tx_data,
   output wire [7:0] rx_data // data
);
  parameter CLKFREQ = 1000000;

  rxuart #(.CLKFREQ(CLKFREQ)) _rx (
     .clk(clk),
     .resetq(resetq),
`ifndef UART_BAUD
     .baud(baud),
`endif
     .uart_rx(rx),
     .rd(rd),
     .valid(valid),
     .data(rx_data));
  uart #(.CLKFREQ(CLKFREQ)) _tx (
     .clk(clk),
     .resetq(resetq),
`ifndef UART_BAUD
     .baud(baud),
`endif
     .uart_busy(busy),
     .uart_tx(tx),
     .uart_wr_i(wr),
     .uart_dat_i(tx_data));
endmodule
