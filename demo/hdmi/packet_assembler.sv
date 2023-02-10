// Implementation of HDMI packet ECC calculation.
// By Sameer Puri https://github.com/sameer

// tjm - ported to yosys-sv
`include "ysv-supt.v"

module packet_assembler (
    input logic clk_pixel,
    input logic reset,
    input logic data_island_period,
    input logic [23:0] header, // See Table 5-8 Packet Types
    input logic [`va(56,4)] sub,
    output logic [8:0] packet_data, // See Figure 5-4 Data Island Packet and ECC Structure
    output logic [4:0] counter
);

initial counter = 5'd0;

// 32 pixel wrap-around counter. See Section 5.2.3.4 for further information.
always_ff @(posedge clk_pixel)
begin
    if (reset)
        counter <= 5'd0;
    else if (data_island_period)
        counter <= counter + 5'd1;
end
// BCH packets 0 to 3 are transferred two bits at a time, see Section 5.2.3.4 for further information.
wire [5:0] counter_t2 = {counter, 1'b0};
wire [5:0] counter_t2_p1 = {counter, 1'b1};

// Initialize parity bits to 0
logic [`va(8,5)] parity = {8'd0, 8'd0, 8'd0, 8'd0, 8'd0};

wire [63:0] bch [3:0];
assign bch[0] = {parity[`vai(8,0)], sub[`vai(56,0)]};
assign bch[1] = {parity[`vai(8,1)], sub[`vai(56,1)]};
assign bch[2] = {parity[`vai(8,2)], sub[`vai(56,2)]};
assign bch[3] = {parity[`vai(8,3)], sub[`vai(56,3)]};
wire [31:0] bch4 = {parity[`vai(8,4)], header};
assign packet_data = {bch[3][counter_t2_p1], bch[2][counter_t2_p1], bch[1][counter_t2_p1], bch[0][counter_t2_p1], bch[3][counter_t2], bch[2][counter_t2], bch[1][counter_t2], bch[0][counter_t2], bch4[counter]};

// See Figure 5-5 Error Correction Code generator. Generalization of a CRC with binary BCH.
// See https://web.archive.org/web/20190520020602/http://hamsterworks.co.nz/mediawiki/index.php/Minimal_HDMI#Computing_the_ECC for an explanation of the implementation.
// See https://en.wikipedia.org/wiki/BCH_code#Systematic_encoding:_The_message_as_a_prefix for further information.
function automatic [7:0] next_ecc;
input [7:0] ecc, next_bch_bit;
begin
    next_ecc = (ecc >> 1) ^ ((ecc[0] ^ next_bch_bit) ? 8'b10000011 : 8'd0);
end
endfunction

logic [`va(8,5)] parity_next;

// The parity needs to be calculated 2 bits at a time for blocks 0 to 3.
// There's 56 bits being sent 2 bits at a time over TMDS channels 1 & 2, so the parity bits wouldn't be ready in time otherwise.
logic [`va(8,4)] parity_next_next;

genvar i;
generate
    for(i = 0; i < 5; i++)
    begin: parity_calc
        if (i == 4)
            assign parity_next[`vai(8,i)] = next_ecc(parity[`vai(8,i)], header[counter]);
        else
        begin
            assign parity_next[`vai(8,i)] = next_ecc(parity[`vai(8,i)], sub[56*i+counter_t2]);
            assign parity_next_next[`vai(8,i)] = next_ecc(parity_next[`vai(8,i)], sub[56*i+counter_t2_p1]);
        end
    end
endgenerate

always_ff @(posedge clk_pixel)
begin
    if (reset)
        parity <= {8'd0, 8'd0, 8'd0, 8'd0, 8'd0};
    else if (data_island_period)
    begin
        if (counter < 5'd28) // Compute ECC only on subpacket data, not on itself
        begin
            parity[`vas(8,3,0)] <= parity_next_next;
            if (counter < 5'd24) // Header only has 24 bits, whereas subpackets have 56 and 56 / 2 = 28.
                parity[`vai(8,4)] <= parity_next[`vai(8,4)];
        end
        else if (counter == 5'd31)
            parity <= {8'd0, 8'd0, 8'd0, 8'd0, 8'd0}; // Reset ECC for next packet
    end
    else
        parity <= {8'd0, 8'd0, 8'd0, 8'd0, 8'd0};
end

endmodule
