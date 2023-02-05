// File hdmi/hdmidelay.vhd translated with vhd2vl v3.0 VHDL to Verilog RTL translator
// vhd2vl settings:
//  * Verilog Module Declaration Style: 2001
// Note: vhd2vl produces wrong code, so I've hand-adjusted it. -- tjm

// vhd2vl is Free (libre) Software:
//   Copyright (C) 2001 Vincenzo Liguori - Ocean Logic Pty Ltd
//     http://www.ocean-logic.com
//   Modifications Copyright (C) 2006 Mark Gonzales - PMC Sierra Inc
//   Modifications (C) 2010 Shankar Giri
//   Modifications Copyright (C) 2002-2017 Larry Doolittle
//     http://doolittle.icarus.com/~larry/vhd2vl/
//   Modifications (C) 2017 Rodrigo A. Melo
//
//   vhd2vl comes with ABSOLUTELY NO WARRANTY.  Always check the resulting
//   Verilog for correctness, ideally with a formal verification tool.
//
//   You are welcome to redistribute vhd2vl under certain conditions.
//   See the license (GPLv2) file included with the source for details.

// The result of translation follows.  Its copyright status should be
// considered unchanged from the original VHDL.

//-------------------------------------------------------------------------
// (c) 2016 Alexey Spirkov
// I am happy for anyone to use this for non-commercial use.
// If my verilog/vhdl/c files are used commercially or otherwise sold,
// please contact me for explicit permission at me _at_ alsp.net.
// This applies for source and binary form and derived works.
// no timescale needed

module hdmi_delay_line(
input wire i_clk,
input wire [G_WIDTH - 1:0] i_d,
output wire [G_WIDTH - 1:0] o_q
);

parameter [31:0] G_WIDTH=40;
parameter [31:0] G_DEPTH=11;




reg [G_WIDTH - 1:0] q_pipe[0:G_DEPTH - 1];

  genvar i;
  for(i = 0; i < G_DEPTH - 1; i = i + 1)
    always @(posedge i_clk)
      q_pipe[i+1] <= q_pipe[i];
  always @(posedge i_clk)
    q_pipe[0] <= i_d;

  assign o_q = q_pipe[G_DEPTH - 1];

endmodule
