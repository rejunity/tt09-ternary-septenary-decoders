/*
 * Copyright (c) 2024 Your Name
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

module tt_um_rejunity_decoder (
    input  wire [7:0] ui_in,    // Dedicated inputs
    output wire [7:0] uo_out,   // Dedicated outputs
    input  wire [7:0] uio_in,   // IOs: Input path
    output wire [7:0] uio_out,  // IOs: Output path
    output wire [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
    input  wire       ena,      // always 1 when the design is powered, so you can ignore it
    input  wire       clk,      // clock
    input  wire       rst_n     // reset_n - low to reset
);

  // All output pins must be assigned. If not used, assign to 0.
  assign uio_oe  = 8'b0111_1111;

  // List all unused inputs to prevent warnings
  wire _unused = &{clk, rst_n, 1'b0};

  // unpack ternary weights - 5 weights per byte
  wire [4:0] weights3_zero;
  wire [4:0] weights3_sign;
  wire [15:0] weights3 = {6'b0, weights3_zero, weights3_sign};
  unpack_33333_weights unpack_33333_weights(
      .packed_weights(ui_in),
      .zero(weights3_zero),
      .sign(weights3_sign)
  );

  // unpack septenary/senary weights - 3 weights per byte
  wire [2:0] weights6_zero;
  wire [2:0] weights6_sign;
  wire [2:0] weights6_mul2;
  wire [2:0] weights6_div2;
  wire [15:0] weights6 = {1'b0, weights6_zero, weights6_sign, weights6_mul2, weights6_div2};
  unpack_676_weights unpack_676_weights(
      .packed_weights(ui_in),
      .zero(weights6_zero),
      .sign(weights6_sign),
      .mul2(weights6_mul2),
      .div2(weights6_div2)
  );

  // unpack septenary/quinary weights - 3 weights per byte
  wire [2:0] weights7_zero;
  wire [2:0] weights7_sign;
  wire [2:0] weights7_mul2;
  wire [2:0] weights7_div2;
  wire [15:0] weights7 = {1'b0, weights7_zero, weights7_sign, weights7_mul2, weights7_div2};
  unpack_775_weights unpack_775_weights(
      .packed_weights(ui_in),
      .zero(weights7_zero),
      .sign(weights7_sign),
      .mul2(weights7_mul2),
      .div2(weights7_div2)
  );

  wire [1:0] selector = {~ena, uio_in[7]};
  assign uo_out  = selector == 0 ? weights7[ 7:0] : 
                   selector == 1 ? weights3[ 7:0] :
                                   weights6[ 7:0];
  assign uio_out = selector == 0 ? weights7[14:8] : 
                   selector == 1 ? weights3[14:8] :
                                   weights6[14:8];

endmodule


module unpack_33333_weights(input        [7:0] packed_weights,
                              output reg [4:0] zero,
                              output reg [4:0] sign);
    always @(*) begin
        case(packed_weights)
        8'd000: begin zero = 5'b11111; sign = 5'b00000; end //   0  0  0  0  0
        8'd001: begin zero = 5'b01111; sign = 5'b00000; end //   0  0  0  0  1
        8'd002: begin zero = 5'b01111; sign = 5'b10000; end //   0  0  0  0 -1
        8'd003: begin zero = 5'b10111; sign = 5'b00000; end //   0  0  0  1  0
        8'd004: begin zero = 5'b00111; sign = 5'b00000; end //   0  0  0  1  1
        8'd005: begin zero = 5'b00111; sign = 5'b10000; end //   0  0  0  1 -1
        8'd006: begin zero = 5'b10111; sign = 5'b01000; end //   0  0  0 -1  0
        8'd007: begin zero = 5'b00111; sign = 5'b01000; end //   0  0  0 -1  1
        8'd008: begin zero = 5'b00111; sign = 5'b11000; end //   0  0  0 -1 -1
        8'd009: begin zero = 5'b11011; sign = 5'b00000; end //   0  0  1  0  0
        8'd010: begin zero = 5'b01011; sign = 5'b00000; end //   0  0  1  0  1
        8'd011: begin zero = 5'b01011; sign = 5'b10000; end //   0  0  1  0 -1
        8'd012: begin zero = 5'b10011; sign = 5'b00000; end //   0  0  1  1  0
        8'd013: begin zero = 5'b00011; sign = 5'b00000; end //   0  0  1  1  1
        8'd014: begin zero = 5'b00011; sign = 5'b10000; end //   0  0  1  1 -1
        8'd015: begin zero = 5'b10011; sign = 5'b01000; end //   0  0  1 -1  0
        8'd016: begin zero = 5'b00011; sign = 5'b01000; end //   0  0  1 -1  1
        8'd017: begin zero = 5'b00011; sign = 5'b11000; end //   0  0  1 -1 -1
        8'd018: begin zero = 5'b11011; sign = 5'b00100; end //   0  0 -1  0  0
        8'd019: begin zero = 5'b01011; sign = 5'b00100; end //   0  0 -1  0  1
        8'd020: begin zero = 5'b01011; sign = 5'b10100; end //   0  0 -1  0 -1
        8'd021: begin zero = 5'b10011; sign = 5'b00100; end //   0  0 -1  1  0
        8'd022: begin zero = 5'b00011; sign = 5'b00100; end //   0  0 -1  1  1
        8'd023: begin zero = 5'b00011; sign = 5'b10100; end //   0  0 -1  1 -1
        8'd024: begin zero = 5'b10011; sign = 5'b01100; end //   0  0 -1 -1  0
        8'd025: begin zero = 5'b00011; sign = 5'b01100; end //   0  0 -1 -1  1
        8'd026: begin zero = 5'b00011; sign = 5'b11100; end //   0  0 -1 -1 -1
        8'd027: begin zero = 5'b11101; sign = 5'b00000; end //   0  1  0  0  0
        8'd028: begin zero = 5'b01101; sign = 5'b00000; end //   0  1  0  0  1
        8'd029: begin zero = 5'b01101; sign = 5'b10000; end //   0  1  0  0 -1
        8'd030: begin zero = 5'b10101; sign = 5'b00000; end //   0  1  0  1  0
        8'd031: begin zero = 5'b00101; sign = 5'b00000; end //   0  1  0  1  1
        8'd032: begin zero = 5'b00101; sign = 5'b10000; end //   0  1  0  1 -1
        8'd033: begin zero = 5'b10101; sign = 5'b01000; end //   0  1  0 -1  0
        8'd034: begin zero = 5'b00101; sign = 5'b01000; end //   0  1  0 -1  1
        8'd035: begin zero = 5'b00101; sign = 5'b11000; end //   0  1  0 -1 -1
        8'd036: begin zero = 5'b11001; sign = 5'b00000; end //   0  1  1  0  0
        8'd037: begin zero = 5'b01001; sign = 5'b00000; end //   0  1  1  0  1
        8'd038: begin zero = 5'b01001; sign = 5'b10000; end //   0  1  1  0 -1
        8'd039: begin zero = 5'b10001; sign = 5'b00000; end //   0  1  1  1  0
        8'd040: begin zero = 5'b00001; sign = 5'b00000; end //   0  1  1  1  1
        8'd041: begin zero = 5'b00001; sign = 5'b10000; end //   0  1  1  1 -1
        8'd042: begin zero = 5'b10001; sign = 5'b01000; end //   0  1  1 -1  0
        8'd043: begin zero = 5'b00001; sign = 5'b01000; end //   0  1  1 -1  1
        8'd044: begin zero = 5'b00001; sign = 5'b11000; end //   0  1  1 -1 -1
        8'd045: begin zero = 5'b11001; sign = 5'b00100; end //   0  1 -1  0  0
        8'd046: begin zero = 5'b01001; sign = 5'b00100; end //   0  1 -1  0  1
        8'd047: begin zero = 5'b01001; sign = 5'b10100; end //   0  1 -1  0 -1
        8'd048: begin zero = 5'b10001; sign = 5'b00100; end //   0  1 -1  1  0
        8'd049: begin zero = 5'b00001; sign = 5'b00100; end //   0  1 -1  1  1
        8'd050: begin zero = 5'b00001; sign = 5'b10100; end //   0  1 -1  1 -1
        8'd051: begin zero = 5'b10001; sign = 5'b01100; end //   0  1 -1 -1  0
        8'd052: begin zero = 5'b00001; sign = 5'b01100; end //   0  1 -1 -1  1
        8'd053: begin zero = 5'b00001; sign = 5'b11100; end //   0  1 -1 -1 -1
        8'd054: begin zero = 5'b11101; sign = 5'b00010; end //   0 -1  0  0  0
        8'd055: begin zero = 5'b01101; sign = 5'b00010; end //   0 -1  0  0  1
        8'd056: begin zero = 5'b01101; sign = 5'b10010; end //   0 -1  0  0 -1
        8'd057: begin zero = 5'b10101; sign = 5'b00010; end //   0 -1  0  1  0
        8'd058: begin zero = 5'b00101; sign = 5'b00010; end //   0 -1  0  1  1
        8'd059: begin zero = 5'b00101; sign = 5'b10010; end //   0 -1  0  1 -1
        8'd060: begin zero = 5'b10101; sign = 5'b01010; end //   0 -1  0 -1  0
        8'd061: begin zero = 5'b00101; sign = 5'b01010; end //   0 -1  0 -1  1
        8'd062: begin zero = 5'b00101; sign = 5'b11010; end //   0 -1  0 -1 -1
        8'd063: begin zero = 5'b11001; sign = 5'b00010; end //   0 -1  1  0  0
        8'd064: begin zero = 5'b01001; sign = 5'b00010; end //   0 -1  1  0  1
        8'd065: begin zero = 5'b01001; sign = 5'b10010; end //   0 -1  1  0 -1
        8'd066: begin zero = 5'b10001; sign = 5'b00010; end //   0 -1  1  1  0
        8'd067: begin zero = 5'b00001; sign = 5'b00010; end //   0 -1  1  1  1
        8'd068: begin zero = 5'b00001; sign = 5'b10010; end //   0 -1  1  1 -1
        8'd069: begin zero = 5'b10001; sign = 5'b01010; end //   0 -1  1 -1  0
        8'd070: begin zero = 5'b00001; sign = 5'b01010; end //   0 -1  1 -1  1
        8'd071: begin zero = 5'b00001; sign = 5'b11010; end //   0 -1  1 -1 -1
        8'd072: begin zero = 5'b11001; sign = 5'b00110; end //   0 -1 -1  0  0
        8'd073: begin zero = 5'b01001; sign = 5'b00110; end //   0 -1 -1  0  1
        8'd074: begin zero = 5'b01001; sign = 5'b10110; end //   0 -1 -1  0 -1
        8'd075: begin zero = 5'b10001; sign = 5'b00110; end //   0 -1 -1  1  0
        8'd076: begin zero = 5'b00001; sign = 5'b00110; end //   0 -1 -1  1  1
        8'd077: begin zero = 5'b00001; sign = 5'b10110; end //   0 -1 -1  1 -1
        8'd078: begin zero = 5'b10001; sign = 5'b01110; end //   0 -1 -1 -1  0
        8'd079: begin zero = 5'b00001; sign = 5'b01110; end //   0 -1 -1 -1  1
        8'd080: begin zero = 5'b00001; sign = 5'b11110; end //   0 -1 -1 -1 -1
        8'd081: begin zero = 5'b11110; sign = 5'b00000; end //   1  0  0  0  0
        8'd082: begin zero = 5'b01110; sign = 5'b00000; end //   1  0  0  0  1
        8'd083: begin zero = 5'b01110; sign = 5'b10000; end //   1  0  0  0 -1
        8'd084: begin zero = 5'b10110; sign = 5'b00000; end //   1  0  0  1  0
        8'd085: begin zero = 5'b00110; sign = 5'b00000; end //   1  0  0  1  1
        8'd086: begin zero = 5'b00110; sign = 5'b10000; end //   1  0  0  1 -1
        8'd087: begin zero = 5'b10110; sign = 5'b01000; end //   1  0  0 -1  0
        8'd088: begin zero = 5'b00110; sign = 5'b01000; end //   1  0  0 -1  1
        8'd089: begin zero = 5'b00110; sign = 5'b11000; end //   1  0  0 -1 -1
        8'd090: begin zero = 5'b11010; sign = 5'b00000; end //   1  0  1  0  0
        8'd091: begin zero = 5'b01010; sign = 5'b00000; end //   1  0  1  0  1
        8'd092: begin zero = 5'b01010; sign = 5'b10000; end //   1  0  1  0 -1
        8'd093: begin zero = 5'b10010; sign = 5'b00000; end //   1  0  1  1  0
        8'd094: begin zero = 5'b00010; sign = 5'b00000; end //   1  0  1  1  1
        8'd095: begin zero = 5'b00010; sign = 5'b10000; end //   1  0  1  1 -1
        8'd096: begin zero = 5'b10010; sign = 5'b01000; end //   1  0  1 -1  0
        8'd097: begin zero = 5'b00010; sign = 5'b01000; end //   1  0  1 -1  1
        8'd098: begin zero = 5'b00010; sign = 5'b11000; end //   1  0  1 -1 -1
        8'd099: begin zero = 5'b11010; sign = 5'b00100; end //   1  0 -1  0  0
        8'd100: begin zero = 5'b01010; sign = 5'b00100; end //   1  0 -1  0  1
        8'd101: begin zero = 5'b01010; sign = 5'b10100; end //   1  0 -1  0 -1
        8'd102: begin zero = 5'b10010; sign = 5'b00100; end //   1  0 -1  1  0
        8'd103: begin zero = 5'b00010; sign = 5'b00100; end //   1  0 -1  1  1
        8'd104: begin zero = 5'b00010; sign = 5'b10100; end //   1  0 -1  1 -1
        8'd105: begin zero = 5'b10010; sign = 5'b01100; end //   1  0 -1 -1  0
        8'd106: begin zero = 5'b00010; sign = 5'b01100; end //   1  0 -1 -1  1
        8'd107: begin zero = 5'b00010; sign = 5'b11100; end //   1  0 -1 -1 -1
        8'd108: begin zero = 5'b11100; sign = 5'b00000; end //   1  1  0  0  0
        8'd109: begin zero = 5'b01100; sign = 5'b00000; end //   1  1  0  0  1
        8'd110: begin zero = 5'b01100; sign = 5'b10000; end //   1  1  0  0 -1
        8'd111: begin zero = 5'b10100; sign = 5'b00000; end //   1  1  0  1  0
        8'd112: begin zero = 5'b00100; sign = 5'b00000; end //   1  1  0  1  1
        8'd113: begin zero = 5'b00100; sign = 5'b10000; end //   1  1  0  1 -1
        8'd114: begin zero = 5'b10100; sign = 5'b01000; end //   1  1  0 -1  0
        8'd115: begin zero = 5'b00100; sign = 5'b01000; end //   1  1  0 -1  1
        8'd116: begin zero = 5'b00100; sign = 5'b11000; end //   1  1  0 -1 -1
        8'd117: begin zero = 5'b11000; sign = 5'b00000; end //   1  1  1  0  0
        8'd118: begin zero = 5'b01000; sign = 5'b00000; end //   1  1  1  0  1
        8'd119: begin zero = 5'b01000; sign = 5'b10000; end //   1  1  1  0 -1
        8'd120: begin zero = 5'b10000; sign = 5'b00000; end //   1  1  1  1  0
        8'd121: begin zero = 5'b00000; sign = 5'b00000; end //   1  1  1  1  1
        8'd122: begin zero = 5'b00000; sign = 5'b10000; end //   1  1  1  1 -1
        8'd123: begin zero = 5'b10000; sign = 5'b01000; end //   1  1  1 -1  0
        8'd124: begin zero = 5'b00000; sign = 5'b01000; end //   1  1  1 -1  1
        8'd125: begin zero = 5'b00000; sign = 5'b11000; end //   1  1  1 -1 -1
        8'd126: begin zero = 5'b11000; sign = 5'b00100; end //   1  1 -1  0  0
        8'd127: begin zero = 5'b01000; sign = 5'b00100; end //   1  1 -1  0  1
        8'd128: begin zero = 5'b01000; sign = 5'b10100; end //   1  1 -1  0 -1
        8'd129: begin zero = 5'b10000; sign = 5'b00100; end //   1  1 -1  1  0
        8'd130: begin zero = 5'b00000; sign = 5'b00100; end //   1  1 -1  1  1
        8'd131: begin zero = 5'b00000; sign = 5'b10100; end //   1  1 -1  1 -1
        8'd132: begin zero = 5'b10000; sign = 5'b01100; end //   1  1 -1 -1  0
        8'd133: begin zero = 5'b00000; sign = 5'b01100; end //   1  1 -1 -1  1
        8'd134: begin zero = 5'b00000; sign = 5'b11100; end //   1  1 -1 -1 -1
        8'd135: begin zero = 5'b11100; sign = 5'b00010; end //   1 -1  0  0  0
        8'd136: begin zero = 5'b01100; sign = 5'b00010; end //   1 -1  0  0  1
        8'd137: begin zero = 5'b01100; sign = 5'b10010; end //   1 -1  0  0 -1
        8'd138: begin zero = 5'b10100; sign = 5'b00010; end //   1 -1  0  1  0
        8'd139: begin zero = 5'b00100; sign = 5'b00010; end //   1 -1  0  1  1
        8'd140: begin zero = 5'b00100; sign = 5'b10010; end //   1 -1  0  1 -1
        8'd141: begin zero = 5'b10100; sign = 5'b01010; end //   1 -1  0 -1  0
        8'd142: begin zero = 5'b00100; sign = 5'b01010; end //   1 -1  0 -1  1
        8'd143: begin zero = 5'b00100; sign = 5'b11010; end //   1 -1  0 -1 -1
        8'd144: begin zero = 5'b11000; sign = 5'b00010; end //   1 -1  1  0  0
        8'd145: begin zero = 5'b01000; sign = 5'b00010; end //   1 -1  1  0  1
        8'd146: begin zero = 5'b01000; sign = 5'b10010; end //   1 -1  1  0 -1
        8'd147: begin zero = 5'b10000; sign = 5'b00010; end //   1 -1  1  1  0
        8'd148: begin zero = 5'b00000; sign = 5'b00010; end //   1 -1  1  1  1
        8'd149: begin zero = 5'b00000; sign = 5'b10010; end //   1 -1  1  1 -1
        8'd150: begin zero = 5'b10000; sign = 5'b01010; end //   1 -1  1 -1  0
        8'd151: begin zero = 5'b00000; sign = 5'b01010; end //   1 -1  1 -1  1
        8'd152: begin zero = 5'b00000; sign = 5'b11010; end //   1 -1  1 -1 -1
        8'd153: begin zero = 5'b11000; sign = 5'b00110; end //   1 -1 -1  0  0
        8'd154: begin zero = 5'b01000; sign = 5'b00110; end //   1 -1 -1  0  1
        8'd155: begin zero = 5'b01000; sign = 5'b10110; end //   1 -1 -1  0 -1
        8'd156: begin zero = 5'b10000; sign = 5'b00110; end //   1 -1 -1  1  0
        8'd157: begin zero = 5'b00000; sign = 5'b00110; end //   1 -1 -1  1  1
        8'd158: begin zero = 5'b00000; sign = 5'b10110; end //   1 -1 -1  1 -1
        8'd159: begin zero = 5'b10000; sign = 5'b01110; end //   1 -1 -1 -1  0
        8'd160: begin zero = 5'b00000; sign = 5'b01110; end //   1 -1 -1 -1  1
        8'd161: begin zero = 5'b00000; sign = 5'b11110; end //   1 -1 -1 -1 -1
        8'd162: begin zero = 5'b11110; sign = 5'b00001; end //  -1  0  0  0  0
        8'd163: begin zero = 5'b01110; sign = 5'b00001; end //  -1  0  0  0  1
        8'd164: begin zero = 5'b01110; sign = 5'b10001; end //  -1  0  0  0 -1
        8'd165: begin zero = 5'b10110; sign = 5'b00001; end //  -1  0  0  1  0
        8'd166: begin zero = 5'b00110; sign = 5'b00001; end //  -1  0  0  1  1
        8'd167: begin zero = 5'b00110; sign = 5'b10001; end //  -1  0  0  1 -1
        8'd168: begin zero = 5'b10110; sign = 5'b01001; end //  -1  0  0 -1  0
        8'd169: begin zero = 5'b00110; sign = 5'b01001; end //  -1  0  0 -1  1
        8'd170: begin zero = 5'b00110; sign = 5'b11001; end //  -1  0  0 -1 -1
        8'd171: begin zero = 5'b11010; sign = 5'b00001; end //  -1  0  1  0  0
        8'd172: begin zero = 5'b01010; sign = 5'b00001; end //  -1  0  1  0  1
        8'd173: begin zero = 5'b01010; sign = 5'b10001; end //  -1  0  1  0 -1
        8'd174: begin zero = 5'b10010; sign = 5'b00001; end //  -1  0  1  1  0
        8'd175: begin zero = 5'b00010; sign = 5'b00001; end //  -1  0  1  1  1
        8'd176: begin zero = 5'b00010; sign = 5'b10001; end //  -1  0  1  1 -1
        8'd177: begin zero = 5'b10010; sign = 5'b01001; end //  -1  0  1 -1  0
        8'd178: begin zero = 5'b00010; sign = 5'b01001; end //  -1  0  1 -1  1
        8'd179: begin zero = 5'b00010; sign = 5'b11001; end //  -1  0  1 -1 -1
        8'd180: begin zero = 5'b11010; sign = 5'b00101; end //  -1  0 -1  0  0
        8'd181: begin zero = 5'b01010; sign = 5'b00101; end //  -1  0 -1  0  1
        8'd182: begin zero = 5'b01010; sign = 5'b10101; end //  -1  0 -1  0 -1
        8'd183: begin zero = 5'b10010; sign = 5'b00101; end //  -1  0 -1  1  0
        8'd184: begin zero = 5'b00010; sign = 5'b00101; end //  -1  0 -1  1  1
        8'd185: begin zero = 5'b00010; sign = 5'b10101; end //  -1  0 -1  1 -1
        8'd186: begin zero = 5'b10010; sign = 5'b01101; end //  -1  0 -1 -1  0
        8'd187: begin zero = 5'b00010; sign = 5'b01101; end //  -1  0 -1 -1  1
        8'd188: begin zero = 5'b00010; sign = 5'b11101; end //  -1  0 -1 -1 -1
        8'd189: begin zero = 5'b11100; sign = 5'b00001; end //  -1  1  0  0  0
        8'd190: begin zero = 5'b01100; sign = 5'b00001; end //  -1  1  0  0  1
        8'd191: begin zero = 5'b01100; sign = 5'b10001; end //  -1  1  0  0 -1
        8'd192: begin zero = 5'b10100; sign = 5'b00001; end //  -1  1  0  1  0
        8'd193: begin zero = 5'b00100; sign = 5'b00001; end //  -1  1  0  1  1
        8'd194: begin zero = 5'b00100; sign = 5'b10001; end //  -1  1  0  1 -1
        8'd195: begin zero = 5'b10100; sign = 5'b01001; end //  -1  1  0 -1  0
        8'd196: begin zero = 5'b00100; sign = 5'b01001; end //  -1  1  0 -1  1
        8'd197: begin zero = 5'b00100; sign = 5'b11001; end //  -1  1  0 -1 -1
        8'd198: begin zero = 5'b11000; sign = 5'b00001; end //  -1  1  1  0  0
        8'd199: begin zero = 5'b01000; sign = 5'b00001; end //  -1  1  1  0  1
        8'd200: begin zero = 5'b01000; sign = 5'b10001; end //  -1  1  1  0 -1
        8'd201: begin zero = 5'b10000; sign = 5'b00001; end //  -1  1  1  1  0
        8'd202: begin zero = 5'b00000; sign = 5'b00001; end //  -1  1  1  1  1
        8'd203: begin zero = 5'b00000; sign = 5'b10001; end //  -1  1  1  1 -1
        8'd204: begin zero = 5'b10000; sign = 5'b01001; end //  -1  1  1 -1  0
        8'd205: begin zero = 5'b00000; sign = 5'b01001; end //  -1  1  1 -1  1
        8'd206: begin zero = 5'b00000; sign = 5'b11001; end //  -1  1  1 -1 -1
        8'd207: begin zero = 5'b11000; sign = 5'b00101; end //  -1  1 -1  0  0
        8'd208: begin zero = 5'b01000; sign = 5'b00101; end //  -1  1 -1  0  1
        8'd209: begin zero = 5'b01000; sign = 5'b10101; end //  -1  1 -1  0 -1
        8'd210: begin zero = 5'b10000; sign = 5'b00101; end //  -1  1 -1  1  0
        8'd211: begin zero = 5'b00000; sign = 5'b00101; end //  -1  1 -1  1  1
        8'd212: begin zero = 5'b00000; sign = 5'b10101; end //  -1  1 -1  1 -1
        8'd213: begin zero = 5'b10000; sign = 5'b01101; end //  -1  1 -1 -1  0
        8'd214: begin zero = 5'b00000; sign = 5'b01101; end //  -1  1 -1 -1  1
        8'd215: begin zero = 5'b00000; sign = 5'b11101; end //  -1  1 -1 -1 -1
        8'd216: begin zero = 5'b11100; sign = 5'b00011; end //  -1 -1  0  0  0
        8'd217: begin zero = 5'b01100; sign = 5'b00011; end //  -1 -1  0  0  1
        8'd218: begin zero = 5'b01100; sign = 5'b10011; end //  -1 -1  0  0 -1
        8'd219: begin zero = 5'b10100; sign = 5'b00011; end //  -1 -1  0  1  0
        8'd220: begin zero = 5'b00100; sign = 5'b00011; end //  -1 -1  0  1  1
        8'd221: begin zero = 5'b00100; sign = 5'b10011; end //  -1 -1  0  1 -1
        8'd222: begin zero = 5'b10100; sign = 5'b01011; end //  -1 -1  0 -1  0
        8'd223: begin zero = 5'b00100; sign = 5'b01011; end //  -1 -1  0 -1  1
        8'd224: begin zero = 5'b00100; sign = 5'b11011; end //  -1 -1  0 -1 -1
        8'd225: begin zero = 5'b11000; sign = 5'b00011; end //  -1 -1  1  0  0
        8'd226: begin zero = 5'b01000; sign = 5'b00011; end //  -1 -1  1  0  1
        8'd227: begin zero = 5'b01000; sign = 5'b10011; end //  -1 -1  1  0 -1
        8'd228: begin zero = 5'b10000; sign = 5'b00011; end //  -1 -1  1  1  0
        8'd229: begin zero = 5'b00000; sign = 5'b00011; end //  -1 -1  1  1  1
        8'd230: begin zero = 5'b00000; sign = 5'b10011; end //  -1 -1  1  1 -1
        8'd231: begin zero = 5'b10000; sign = 5'b01011; end //  -1 -1  1 -1  0
        8'd232: begin zero = 5'b00000; sign = 5'b01011; end //  -1 -1  1 -1  1
        8'd233: begin zero = 5'b00000; sign = 5'b11011; end //  -1 -1  1 -1 -1
        8'd234: begin zero = 5'b11000; sign = 5'b00111; end //  -1 -1 -1  0  0
        8'd235: begin zero = 5'b01000; sign = 5'b00111; end //  -1 -1 -1  0  1
        8'd236: begin zero = 5'b01000; sign = 5'b10111; end //  -1 -1 -1  0 -1
        8'd237: begin zero = 5'b10000; sign = 5'b00111; end //  -1 -1 -1  1  0
        8'd238: begin zero = 5'b00000; sign = 5'b00111; end //  -1 -1 -1  1  1
        8'd239: begin zero = 5'b00000; sign = 5'b10111; end //  -1 -1 -1  1 -1
        8'd240: begin zero = 5'b10000; sign = 5'b01111; end //  -1 -1 -1 -1  0
        8'd241: begin zero = 5'b00000; sign = 5'b01111; end //  -1 -1 -1 -1  1
        8'd242: begin zero = 5'b00000; sign = 5'b11111; end //  -1 -1 -1 -1 -1
        default: {zero, sign} = {5'b11_111, 5'b0}; // Default case
        endcase
    end
endmodule

module unpack_676_weights(input      [7:0] packed_weights,
                          output reg [2:0] zero,
                          output reg [2:0] sign,
                          output reg [2:0] mul2,
                          output reg [2:0] div2);
    always @(*) begin
        case(packed_weights)
        8'd000: begin zero = 3'b111; sign = 3'b000; mul2 = 3'b000; div2 = 3'b000; end //     0    0    0
        8'd001: begin zero = 3'b011; sign = 3'b000; mul2 = 3'b000; div2 = 3'b100; end //   0.5    0    0
        8'd002: begin zero = 3'b011; sign = 3'b000; mul2 = 3'b000; div2 = 3'b000; end //     1    0    0
        8'd003: begin zero = 3'b011; sign = 3'b000; mul2 = 3'b100; div2 = 3'b000; end //     2    0    0
        8'd004: begin zero = 3'b011; sign = 3'b100; mul2 = 3'b000; div2 = 3'b000; end //    -1    0    0
        8'd005: begin zero = 3'b011; sign = 3'b100; mul2 = 3'b100; div2 = 3'b000; end //    -2    0    0
        8'd006: begin zero = 3'b101; sign = 3'b000; mul2 = 3'b000; div2 = 3'b010; end //     0  0.5    0
        8'd007: begin zero = 3'b001; sign = 3'b000; mul2 = 3'b000; div2 = 3'b110; end //   0.5  0.5    0
        8'd008: begin zero = 3'b001; sign = 3'b000; mul2 = 3'b000; div2 = 3'b010; end //     1  0.5    0
        8'd009: begin zero = 3'b001; sign = 3'b000; mul2 = 3'b100; div2 = 3'b010; end //     2  0.5    0
        8'd010: begin zero = 3'b001; sign = 3'b100; mul2 = 3'b000; div2 = 3'b010; end //    -1  0.5    0
        8'd011: begin zero = 3'b001; sign = 3'b100; mul2 = 3'b100; div2 = 3'b010; end //    -2  0.5    0
        8'd012: begin zero = 3'b101; sign = 3'b000; mul2 = 3'b000; div2 = 3'b000; end //     0    1    0
        8'd013: begin zero = 3'b001; sign = 3'b000; mul2 = 3'b000; div2 = 3'b100; end //   0.5    1    0
        8'd014: begin zero = 3'b001; sign = 3'b000; mul2 = 3'b000; div2 = 3'b000; end //     1    1    0
        8'd015: begin zero = 3'b001; sign = 3'b000; mul2 = 3'b100; div2 = 3'b000; end //     2    1    0
        8'd016: begin zero = 3'b001; sign = 3'b100; mul2 = 3'b000; div2 = 3'b000; end //    -1    1    0
        8'd017: begin zero = 3'b001; sign = 3'b100; mul2 = 3'b100; div2 = 3'b000; end //    -2    1    0
        8'd018: begin zero = 3'b101; sign = 3'b000; mul2 = 3'b010; div2 = 3'b000; end //     0    2    0
        8'd019: begin zero = 3'b001; sign = 3'b000; mul2 = 3'b010; div2 = 3'b100; end //   0.5    2    0
        8'd020: begin zero = 3'b001; sign = 3'b000; mul2 = 3'b010; div2 = 3'b000; end //     1    2    0
        8'd021: begin zero = 3'b001; sign = 3'b000; mul2 = 3'b110; div2 = 3'b000; end //     2    2    0
        8'd022: begin zero = 3'b001; sign = 3'b100; mul2 = 3'b010; div2 = 3'b000; end //    -1    2    0
        8'd023: begin zero = 3'b001; sign = 3'b100; mul2 = 3'b110; div2 = 3'b000; end //    -2    2    0
        8'd024: begin zero = 3'b101; sign = 3'b010; mul2 = 3'b000; div2 = 3'b010; end //     0 -0.5    0
        8'd025: begin zero = 3'b001; sign = 3'b010; mul2 = 3'b000; div2 = 3'b110; end //   0.5 -0.5    0
        8'd026: begin zero = 3'b001; sign = 3'b010; mul2 = 3'b000; div2 = 3'b010; end //     1 -0.5    0
        8'd027: begin zero = 3'b001; sign = 3'b010; mul2 = 3'b100; div2 = 3'b010; end //     2 -0.5    0
        8'd028: begin zero = 3'b001; sign = 3'b110; mul2 = 3'b000; div2 = 3'b010; end //    -1 -0.5    0
        8'd029: begin zero = 3'b001; sign = 3'b110; mul2 = 3'b100; div2 = 3'b010; end //    -2 -0.5    0
        8'd030: begin zero = 3'b101; sign = 3'b010; mul2 = 3'b000; div2 = 3'b000; end //     0   -1    0
        8'd031: begin zero = 3'b001; sign = 3'b010; mul2 = 3'b000; div2 = 3'b100; end //   0.5   -1    0
        8'd032: begin zero = 3'b001; sign = 3'b010; mul2 = 3'b000; div2 = 3'b000; end //     1   -1    0
        8'd033: begin zero = 3'b001; sign = 3'b010; mul2 = 3'b100; div2 = 3'b000; end //     2   -1    0
        8'd034: begin zero = 3'b001; sign = 3'b110; mul2 = 3'b000; div2 = 3'b000; end //    -1   -1    0
        8'd035: begin zero = 3'b001; sign = 3'b110; mul2 = 3'b100; div2 = 3'b000; end //    -2   -1    0
        8'd036: begin zero = 3'b101; sign = 3'b010; mul2 = 3'b010; div2 = 3'b000; end //     0   -2    0
        8'd037: begin zero = 3'b001; sign = 3'b010; mul2 = 3'b010; div2 = 3'b100; end //   0.5   -2    0
        8'd038: begin zero = 3'b001; sign = 3'b010; mul2 = 3'b010; div2 = 3'b000; end //     1   -2    0
        8'd039: begin zero = 3'b001; sign = 3'b010; mul2 = 3'b110; div2 = 3'b000; end //     2   -2    0
        8'd040: begin zero = 3'b001; sign = 3'b110; mul2 = 3'b010; div2 = 3'b000; end //    -1   -2    0
        8'd041: begin zero = 3'b001; sign = 3'b110; mul2 = 3'b110; div2 = 3'b000; end //    -2   -2    0
        8'd042: begin zero = 3'b110; sign = 3'b000; mul2 = 3'b000; div2 = 3'b000; end //     0    0    1
        8'd043: begin zero = 3'b010; sign = 3'b000; mul2 = 3'b000; div2 = 3'b100; end //   0.5    0    1
        8'd044: begin zero = 3'b010; sign = 3'b000; mul2 = 3'b000; div2 = 3'b000; end //     1    0    1
        8'd045: begin zero = 3'b010; sign = 3'b000; mul2 = 3'b100; div2 = 3'b000; end //     2    0    1
        8'd046: begin zero = 3'b010; sign = 3'b100; mul2 = 3'b000; div2 = 3'b000; end //    -1    0    1
        8'd047: begin zero = 3'b010; sign = 3'b100; mul2 = 3'b100; div2 = 3'b000; end //    -2    0    1
        8'd048: begin zero = 3'b100; sign = 3'b000; mul2 = 3'b000; div2 = 3'b010; end //     0  0.5    1
        8'd049: begin zero = 3'b000; sign = 3'b000; mul2 = 3'b000; div2 = 3'b110; end //   0.5  0.5    1
        8'd050: begin zero = 3'b000; sign = 3'b000; mul2 = 3'b000; div2 = 3'b010; end //     1  0.5    1
        8'd051: begin zero = 3'b000; sign = 3'b000; mul2 = 3'b100; div2 = 3'b010; end //     2  0.5    1
        8'd052: begin zero = 3'b000; sign = 3'b100; mul2 = 3'b000; div2 = 3'b010; end //    -1  0.5    1
        8'd053: begin zero = 3'b000; sign = 3'b100; mul2 = 3'b100; div2 = 3'b010; end //    -2  0.5    1
        8'd054: begin zero = 3'b100; sign = 3'b000; mul2 = 3'b000; div2 = 3'b000; end //     0    1    1
        8'd055: begin zero = 3'b000; sign = 3'b000; mul2 = 3'b000; div2 = 3'b100; end //   0.5    1    1
        8'd056: begin zero = 3'b000; sign = 3'b000; mul2 = 3'b000; div2 = 3'b000; end //     1    1    1
        8'd057: begin zero = 3'b000; sign = 3'b000; mul2 = 3'b100; div2 = 3'b000; end //     2    1    1
        8'd058: begin zero = 3'b000; sign = 3'b100; mul2 = 3'b000; div2 = 3'b000; end //    -1    1    1
        8'd059: begin zero = 3'b000; sign = 3'b100; mul2 = 3'b100; div2 = 3'b000; end //    -2    1    1
        8'd060: begin zero = 3'b100; sign = 3'b000; mul2 = 3'b010; div2 = 3'b000; end //     0    2    1
        8'd061: begin zero = 3'b000; sign = 3'b000; mul2 = 3'b010; div2 = 3'b100; end //   0.5    2    1
        8'd062: begin zero = 3'b000; sign = 3'b000; mul2 = 3'b010; div2 = 3'b000; end //     1    2    1
        8'd063: begin zero = 3'b000; sign = 3'b000; mul2 = 3'b110; div2 = 3'b000; end //     2    2    1
        8'd064: begin zero = 3'b000; sign = 3'b100; mul2 = 3'b010; div2 = 3'b000; end //    -1    2    1
        8'd065: begin zero = 3'b000; sign = 3'b100; mul2 = 3'b110; div2 = 3'b000; end //    -2    2    1
        8'd066: begin zero = 3'b100; sign = 3'b010; mul2 = 3'b000; div2 = 3'b010; end //     0 -0.5    1
        8'd067: begin zero = 3'b000; sign = 3'b010; mul2 = 3'b000; div2 = 3'b110; end //   0.5 -0.5    1
        8'd068: begin zero = 3'b000; sign = 3'b010; mul2 = 3'b000; div2 = 3'b010; end //     1 -0.5    1
        8'd069: begin zero = 3'b000; sign = 3'b010; mul2 = 3'b100; div2 = 3'b010; end //     2 -0.5    1
        8'd070: begin zero = 3'b000; sign = 3'b110; mul2 = 3'b000; div2 = 3'b010; end //    -1 -0.5    1
        8'd071: begin zero = 3'b000; sign = 3'b110; mul2 = 3'b100; div2 = 3'b010; end //    -2 -0.5    1
        8'd072: begin zero = 3'b100; sign = 3'b010; mul2 = 3'b000; div2 = 3'b000; end //     0   -1    1
        8'd073: begin zero = 3'b000; sign = 3'b010; mul2 = 3'b000; div2 = 3'b100; end //   0.5   -1    1
        8'd074: begin zero = 3'b000; sign = 3'b010; mul2 = 3'b000; div2 = 3'b000; end //     1   -1    1
        8'd075: begin zero = 3'b000; sign = 3'b010; mul2 = 3'b100; div2 = 3'b000; end //     2   -1    1
        8'd076: begin zero = 3'b000; sign = 3'b110; mul2 = 3'b000; div2 = 3'b000; end //    -1   -1    1
        8'd077: begin zero = 3'b000; sign = 3'b110; mul2 = 3'b100; div2 = 3'b000; end //    -2   -1    1
        8'd078: begin zero = 3'b100; sign = 3'b010; mul2 = 3'b010; div2 = 3'b000; end //     0   -2    1
        8'd079: begin zero = 3'b000; sign = 3'b010; mul2 = 3'b010; div2 = 3'b100; end //   0.5   -2    1
        8'd080: begin zero = 3'b000; sign = 3'b010; mul2 = 3'b010; div2 = 3'b000; end //     1   -2    1
        8'd081: begin zero = 3'b000; sign = 3'b010; mul2 = 3'b110; div2 = 3'b000; end //     2   -2    1
        8'd082: begin zero = 3'b000; sign = 3'b110; mul2 = 3'b010; div2 = 3'b000; end //    -1   -2    1
        8'd083: begin zero = 3'b000; sign = 3'b110; mul2 = 3'b110; div2 = 3'b000; end //    -2   -2    1
        8'd084: begin zero = 3'b110; sign = 3'b000; mul2 = 3'b001; div2 = 3'b000; end //     0    0    2
        8'd085: begin zero = 3'b010; sign = 3'b000; mul2 = 3'b001; div2 = 3'b100; end //   0.5    0    2
        8'd086: begin zero = 3'b010; sign = 3'b000; mul2 = 3'b001; div2 = 3'b000; end //     1    0    2
        8'd087: begin zero = 3'b010; sign = 3'b000; mul2 = 3'b101; div2 = 3'b000; end //     2    0    2
        8'd088: begin zero = 3'b010; sign = 3'b100; mul2 = 3'b001; div2 = 3'b000; end //    -1    0    2
        8'd089: begin zero = 3'b010; sign = 3'b100; mul2 = 3'b101; div2 = 3'b000; end //    -2    0    2
        8'd090: begin zero = 3'b100; sign = 3'b000; mul2 = 3'b001; div2 = 3'b010; end //     0  0.5    2
        8'd091: begin zero = 3'b000; sign = 3'b000; mul2 = 3'b001; div2 = 3'b110; end //   0.5  0.5    2
        8'd092: begin zero = 3'b000; sign = 3'b000; mul2 = 3'b001; div2 = 3'b010; end //     1  0.5    2
        8'd093: begin zero = 3'b000; sign = 3'b000; mul2 = 3'b101; div2 = 3'b010; end //     2  0.5    2
        8'd094: begin zero = 3'b000; sign = 3'b100; mul2 = 3'b001; div2 = 3'b010; end //    -1  0.5    2
        8'd095: begin zero = 3'b000; sign = 3'b100; mul2 = 3'b101; div2 = 3'b010; end //    -2  0.5    2
        8'd096: begin zero = 3'b100; sign = 3'b000; mul2 = 3'b001; div2 = 3'b000; end //     0    1    2
        8'd097: begin zero = 3'b000; sign = 3'b000; mul2 = 3'b001; div2 = 3'b100; end //   0.5    1    2
        8'd098: begin zero = 3'b000; sign = 3'b000; mul2 = 3'b001; div2 = 3'b000; end //     1    1    2
        8'd099: begin zero = 3'b000; sign = 3'b000; mul2 = 3'b101; div2 = 3'b000; end //     2    1    2
        8'd100: begin zero = 3'b000; sign = 3'b100; mul2 = 3'b001; div2 = 3'b000; end //    -1    1    2
        8'd101: begin zero = 3'b000; sign = 3'b100; mul2 = 3'b101; div2 = 3'b000; end //    -2    1    2
        8'd102: begin zero = 3'b100; sign = 3'b000; mul2 = 3'b011; div2 = 3'b000; end //     0    2    2
        8'd103: begin zero = 3'b000; sign = 3'b000; mul2 = 3'b011; div2 = 3'b100; end //   0.5    2    2
        8'd104: begin zero = 3'b000; sign = 3'b000; mul2 = 3'b011; div2 = 3'b000; end //     1    2    2
        8'd105: begin zero = 3'b000; sign = 3'b000; mul2 = 3'b111; div2 = 3'b000; end //     2    2    2
        8'd106: begin zero = 3'b000; sign = 3'b100; mul2 = 3'b011; div2 = 3'b000; end //    -1    2    2
        8'd107: begin zero = 3'b000; sign = 3'b100; mul2 = 3'b111; div2 = 3'b000; end //    -2    2    2
        8'd108: begin zero = 3'b100; sign = 3'b010; mul2 = 3'b001; div2 = 3'b010; end //     0 -0.5    2
        8'd109: begin zero = 3'b000; sign = 3'b010; mul2 = 3'b001; div2 = 3'b110; end //   0.5 -0.5    2
        8'd110: begin zero = 3'b000; sign = 3'b010; mul2 = 3'b001; div2 = 3'b010; end //     1 -0.5    2
        8'd111: begin zero = 3'b000; sign = 3'b010; mul2 = 3'b101; div2 = 3'b010; end //     2 -0.5    2
        8'd112: begin zero = 3'b000; sign = 3'b110; mul2 = 3'b001; div2 = 3'b010; end //    -1 -0.5    2
        8'd113: begin zero = 3'b000; sign = 3'b110; mul2 = 3'b101; div2 = 3'b010; end //    -2 -0.5    2
        8'd114: begin zero = 3'b100; sign = 3'b010; mul2 = 3'b001; div2 = 3'b000; end //     0   -1    2
        8'd115: begin zero = 3'b000; sign = 3'b010; mul2 = 3'b001; div2 = 3'b100; end //   0.5   -1    2
        8'd116: begin zero = 3'b000; sign = 3'b010; mul2 = 3'b001; div2 = 3'b000; end //     1   -1    2
        8'd117: begin zero = 3'b000; sign = 3'b010; mul2 = 3'b101; div2 = 3'b000; end //     2   -1    2
        8'd118: begin zero = 3'b000; sign = 3'b110; mul2 = 3'b001; div2 = 3'b000; end //    -1   -1    2
        8'd119: begin zero = 3'b000; sign = 3'b110; mul2 = 3'b101; div2 = 3'b000; end //    -2   -1    2
        8'd120: begin zero = 3'b100; sign = 3'b010; mul2 = 3'b011; div2 = 3'b000; end //     0   -2    2
        8'd121: begin zero = 3'b000; sign = 3'b010; mul2 = 3'b011; div2 = 3'b100; end //   0.5   -2    2
        8'd122: begin zero = 3'b000; sign = 3'b010; mul2 = 3'b011; div2 = 3'b000; end //     1   -2    2
        8'd123: begin zero = 3'b000; sign = 3'b010; mul2 = 3'b111; div2 = 3'b000; end //     2   -2    2
        8'd124: begin zero = 3'b000; sign = 3'b110; mul2 = 3'b011; div2 = 3'b000; end //    -1   -2    2
        8'd125: begin zero = 3'b000; sign = 3'b110; mul2 = 3'b111; div2 = 3'b000; end //    -2   -2    2
        8'd126: begin zero = 3'b110; sign = 3'b001; mul2 = 3'b000; div2 = 3'b001; end //     0    0 -0.5
        8'd127: begin zero = 3'b010; sign = 3'b001; mul2 = 3'b000; div2 = 3'b101; end //   0.5    0 -0.5
        8'd128: begin zero = 3'b010; sign = 3'b001; mul2 = 3'b000; div2 = 3'b001; end //     1    0 -0.5
        8'd129: begin zero = 3'b010; sign = 3'b001; mul2 = 3'b100; div2 = 3'b001; end //     2    0 -0.5
        8'd130: begin zero = 3'b010; sign = 3'b101; mul2 = 3'b000; div2 = 3'b001; end //    -1    0 -0.5
        8'd131: begin zero = 3'b010; sign = 3'b101; mul2 = 3'b100; div2 = 3'b001; end //    -2    0 -0.5
        8'd132: begin zero = 3'b100; sign = 3'b001; mul2 = 3'b000; div2 = 3'b011; end //     0  0.5 -0.5
        8'd133: begin zero = 3'b000; sign = 3'b001; mul2 = 3'b000; div2 = 3'b111; end //   0.5  0.5 -0.5
        8'd134: begin zero = 3'b000; sign = 3'b001; mul2 = 3'b000; div2 = 3'b011; end //     1  0.5 -0.5
        8'd135: begin zero = 3'b000; sign = 3'b001; mul2 = 3'b100; div2 = 3'b011; end //     2  0.5 -0.5
        8'd136: begin zero = 3'b000; sign = 3'b101; mul2 = 3'b000; div2 = 3'b011; end //    -1  0.5 -0.5
        8'd137: begin zero = 3'b000; sign = 3'b101; mul2 = 3'b100; div2 = 3'b011; end //    -2  0.5 -0.5
        8'd138: begin zero = 3'b100; sign = 3'b001; mul2 = 3'b000; div2 = 3'b001; end //     0    1 -0.5
        8'd139: begin zero = 3'b000; sign = 3'b001; mul2 = 3'b000; div2 = 3'b101; end //   0.5    1 -0.5
        8'd140: begin zero = 3'b000; sign = 3'b001; mul2 = 3'b000; div2 = 3'b001; end //     1    1 -0.5
        8'd141: begin zero = 3'b000; sign = 3'b001; mul2 = 3'b100; div2 = 3'b001; end //     2    1 -0.5
        8'd142: begin zero = 3'b000; sign = 3'b101; mul2 = 3'b000; div2 = 3'b001; end //    -1    1 -0.5
        8'd143: begin zero = 3'b000; sign = 3'b101; mul2 = 3'b100; div2 = 3'b001; end //    -2    1 -0.5
        8'd144: begin zero = 3'b100; sign = 3'b001; mul2 = 3'b010; div2 = 3'b001; end //     0    2 -0.5
        8'd145: begin zero = 3'b000; sign = 3'b001; mul2 = 3'b010; div2 = 3'b101; end //   0.5    2 -0.5
        8'd146: begin zero = 3'b000; sign = 3'b001; mul2 = 3'b010; div2 = 3'b001; end //     1    2 -0.5
        8'd147: begin zero = 3'b000; sign = 3'b001; mul2 = 3'b110; div2 = 3'b001; end //     2    2 -0.5
        8'd148: begin zero = 3'b000; sign = 3'b101; mul2 = 3'b010; div2 = 3'b001; end //    -1    2 -0.5
        8'd149: begin zero = 3'b000; sign = 3'b101; mul2 = 3'b110; div2 = 3'b001; end //    -2    2 -0.5
        8'd150: begin zero = 3'b100; sign = 3'b011; mul2 = 3'b000; div2 = 3'b011; end //     0 -0.5 -0.5
        8'd151: begin zero = 3'b000; sign = 3'b011; mul2 = 3'b000; div2 = 3'b111; end //   0.5 -0.5 -0.5
        8'd152: begin zero = 3'b000; sign = 3'b011; mul2 = 3'b000; div2 = 3'b011; end //     1 -0.5 -0.5
        8'd153: begin zero = 3'b000; sign = 3'b011; mul2 = 3'b100; div2 = 3'b011; end //     2 -0.5 -0.5
        8'd154: begin zero = 3'b000; sign = 3'b111; mul2 = 3'b000; div2 = 3'b011; end //    -1 -0.5 -0.5
        8'd155: begin zero = 3'b000; sign = 3'b111; mul2 = 3'b100; div2 = 3'b011; end //    -2 -0.5 -0.5
        8'd156: begin zero = 3'b100; sign = 3'b011; mul2 = 3'b000; div2 = 3'b001; end //     0   -1 -0.5
        8'd157: begin zero = 3'b000; sign = 3'b011; mul2 = 3'b000; div2 = 3'b101; end //   0.5   -1 -0.5
        8'd158: begin zero = 3'b000; sign = 3'b011; mul2 = 3'b000; div2 = 3'b001; end //     1   -1 -0.5
        8'd159: begin zero = 3'b000; sign = 3'b011; mul2 = 3'b100; div2 = 3'b001; end //     2   -1 -0.5
        8'd160: begin zero = 3'b000; sign = 3'b111; mul2 = 3'b000; div2 = 3'b001; end //    -1   -1 -0.5
        8'd161: begin zero = 3'b000; sign = 3'b111; mul2 = 3'b100; div2 = 3'b001; end //    -2   -1 -0.5
        8'd162: begin zero = 3'b100; sign = 3'b011; mul2 = 3'b010; div2 = 3'b001; end //     0   -2 -0.5
        8'd163: begin zero = 3'b000; sign = 3'b011; mul2 = 3'b010; div2 = 3'b101; end //   0.5   -2 -0.5
        8'd164: begin zero = 3'b000; sign = 3'b011; mul2 = 3'b010; div2 = 3'b001; end //     1   -2 -0.5
        8'd165: begin zero = 3'b000; sign = 3'b011; mul2 = 3'b110; div2 = 3'b001; end //     2   -2 -0.5
        8'd166: begin zero = 3'b000; sign = 3'b111; mul2 = 3'b010; div2 = 3'b001; end //    -1   -2 -0.5
        8'd167: begin zero = 3'b000; sign = 3'b111; mul2 = 3'b110; div2 = 3'b001; end //    -2   -2 -0.5
        8'd168: begin zero = 3'b110; sign = 3'b001; mul2 = 3'b000; div2 = 3'b000; end //     0    0   -1
        8'd169: begin zero = 3'b010; sign = 3'b001; mul2 = 3'b000; div2 = 3'b100; end //   0.5    0   -1
        8'd170: begin zero = 3'b010; sign = 3'b001; mul2 = 3'b000; div2 = 3'b000; end //     1    0   -1
        8'd171: begin zero = 3'b010; sign = 3'b001; mul2 = 3'b100; div2 = 3'b000; end //     2    0   -1
        8'd172: begin zero = 3'b010; sign = 3'b101; mul2 = 3'b000; div2 = 3'b000; end //    -1    0   -1
        8'd173: begin zero = 3'b010; sign = 3'b101; mul2 = 3'b100; div2 = 3'b000; end //    -2    0   -1
        8'd174: begin zero = 3'b100; sign = 3'b001; mul2 = 3'b000; div2 = 3'b010; end //     0  0.5   -1
        8'd175: begin zero = 3'b000; sign = 3'b001; mul2 = 3'b000; div2 = 3'b110; end //   0.5  0.5   -1
        8'd176: begin zero = 3'b000; sign = 3'b001; mul2 = 3'b000; div2 = 3'b010; end //     1  0.5   -1
        8'd177: begin zero = 3'b000; sign = 3'b001; mul2 = 3'b100; div2 = 3'b010; end //     2  0.5   -1
        8'd178: begin zero = 3'b000; sign = 3'b101; mul2 = 3'b000; div2 = 3'b010; end //    -1  0.5   -1
        8'd179: begin zero = 3'b000; sign = 3'b101; mul2 = 3'b100; div2 = 3'b010; end //    -2  0.5   -1
        8'd180: begin zero = 3'b100; sign = 3'b001; mul2 = 3'b000; div2 = 3'b000; end //     0    1   -1
        8'd181: begin zero = 3'b000; sign = 3'b001; mul2 = 3'b000; div2 = 3'b100; end //   0.5    1   -1
        8'd182: begin zero = 3'b000; sign = 3'b001; mul2 = 3'b000; div2 = 3'b000; end //     1    1   -1
        8'd183: begin zero = 3'b000; sign = 3'b001; mul2 = 3'b100; div2 = 3'b000; end //     2    1   -1
        8'd184: begin zero = 3'b000; sign = 3'b101; mul2 = 3'b000; div2 = 3'b000; end //    -1    1   -1
        8'd185: begin zero = 3'b000; sign = 3'b101; mul2 = 3'b100; div2 = 3'b000; end //    -2    1   -1
        8'd186: begin zero = 3'b100; sign = 3'b001; mul2 = 3'b010; div2 = 3'b000; end //     0    2   -1
        8'd187: begin zero = 3'b000; sign = 3'b001; mul2 = 3'b010; div2 = 3'b100; end //   0.5    2   -1
        8'd188: begin zero = 3'b000; sign = 3'b001; mul2 = 3'b010; div2 = 3'b000; end //     1    2   -1
        8'd189: begin zero = 3'b000; sign = 3'b001; mul2 = 3'b110; div2 = 3'b000; end //     2    2   -1
        8'd190: begin zero = 3'b000; sign = 3'b101; mul2 = 3'b010; div2 = 3'b000; end //    -1    2   -1
        8'd191: begin zero = 3'b000; sign = 3'b101; mul2 = 3'b110; div2 = 3'b000; end //    -2    2   -1
        8'd192: begin zero = 3'b100; sign = 3'b011; mul2 = 3'b000; div2 = 3'b010; end //     0 -0.5   -1
        8'd193: begin zero = 3'b000; sign = 3'b011; mul2 = 3'b000; div2 = 3'b110; end //   0.5 -0.5   -1
        8'd194: begin zero = 3'b000; sign = 3'b011; mul2 = 3'b000; div2 = 3'b010; end //     1 -0.5   -1
        8'd195: begin zero = 3'b000; sign = 3'b011; mul2 = 3'b100; div2 = 3'b010; end //     2 -0.5   -1
        8'd196: begin zero = 3'b000; sign = 3'b111; mul2 = 3'b000; div2 = 3'b010; end //    -1 -0.5   -1
        8'd197: begin zero = 3'b000; sign = 3'b111; mul2 = 3'b100; div2 = 3'b010; end //    -2 -0.5   -1
        8'd198: begin zero = 3'b100; sign = 3'b011; mul2 = 3'b000; div2 = 3'b000; end //     0   -1   -1
        8'd199: begin zero = 3'b000; sign = 3'b011; mul2 = 3'b000; div2 = 3'b100; end //   0.5   -1   -1
        8'd200: begin zero = 3'b000; sign = 3'b011; mul2 = 3'b000; div2 = 3'b000; end //     1   -1   -1
        8'd201: begin zero = 3'b000; sign = 3'b011; mul2 = 3'b100; div2 = 3'b000; end //     2   -1   -1
        8'd202: begin zero = 3'b000; sign = 3'b111; mul2 = 3'b000; div2 = 3'b000; end //    -1   -1   -1
        8'd203: begin zero = 3'b000; sign = 3'b111; mul2 = 3'b100; div2 = 3'b000; end //    -2   -1   -1
        8'd204: begin zero = 3'b100; sign = 3'b011; mul2 = 3'b010; div2 = 3'b000; end //     0   -2   -1
        8'd205: begin zero = 3'b000; sign = 3'b011; mul2 = 3'b010; div2 = 3'b100; end //   0.5   -2   -1
        8'd206: begin zero = 3'b000; sign = 3'b011; mul2 = 3'b010; div2 = 3'b000; end //     1   -2   -1
        8'd207: begin zero = 3'b000; sign = 3'b011; mul2 = 3'b110; div2 = 3'b000; end //     2   -2   -1
        8'd208: begin zero = 3'b000; sign = 3'b111; mul2 = 3'b010; div2 = 3'b000; end //    -1   -2   -1
        8'd209: begin zero = 3'b000; sign = 3'b111; mul2 = 3'b110; div2 = 3'b000; end //    -2   -2   -1
        8'd210: begin zero = 3'b110; sign = 3'b001; mul2 = 3'b001; div2 = 3'b000; end //     0    0   -2
        8'd211: begin zero = 3'b010; sign = 3'b001; mul2 = 3'b001; div2 = 3'b100; end //   0.5    0   -2
        8'd212: begin zero = 3'b010; sign = 3'b001; mul2 = 3'b001; div2 = 3'b000; end //     1    0   -2
        8'd213: begin zero = 3'b010; sign = 3'b001; mul2 = 3'b101; div2 = 3'b000; end //     2    0   -2
        8'd214: begin zero = 3'b010; sign = 3'b101; mul2 = 3'b001; div2 = 3'b000; end //    -1    0   -2
        8'd215: begin zero = 3'b010; sign = 3'b101; mul2 = 3'b101; div2 = 3'b000; end //    -2    0   -2
        8'd216: begin zero = 3'b100; sign = 3'b001; mul2 = 3'b001; div2 = 3'b010; end //     0  0.5   -2
        8'd217: begin zero = 3'b000; sign = 3'b001; mul2 = 3'b001; div2 = 3'b110; end //   0.5  0.5   -2
        8'd218: begin zero = 3'b000; sign = 3'b001; mul2 = 3'b001; div2 = 3'b010; end //     1  0.5   -2
        8'd219: begin zero = 3'b000; sign = 3'b001; mul2 = 3'b101; div2 = 3'b010; end //     2  0.5   -2
        8'd220: begin zero = 3'b000; sign = 3'b101; mul2 = 3'b001; div2 = 3'b010; end //    -1  0.5   -2
        8'd221: begin zero = 3'b000; sign = 3'b101; mul2 = 3'b101; div2 = 3'b010; end //    -2  0.5   -2
        8'd222: begin zero = 3'b100; sign = 3'b001; mul2 = 3'b001; div2 = 3'b000; end //     0    1   -2
        8'd223: begin zero = 3'b000; sign = 3'b001; mul2 = 3'b001; div2 = 3'b100; end //   0.5    1   -2
        8'd224: begin zero = 3'b000; sign = 3'b001; mul2 = 3'b001; div2 = 3'b000; end //     1    1   -2
        8'd225: begin zero = 3'b000; sign = 3'b001; mul2 = 3'b101; div2 = 3'b000; end //     2    1   -2
        8'd226: begin zero = 3'b000; sign = 3'b101; mul2 = 3'b001; div2 = 3'b000; end //    -1    1   -2
        8'd227: begin zero = 3'b000; sign = 3'b101; mul2 = 3'b101; div2 = 3'b000; end //    -2    1   -2
        8'd228: begin zero = 3'b100; sign = 3'b001; mul2 = 3'b011; div2 = 3'b000; end //     0    2   -2
        8'd229: begin zero = 3'b000; sign = 3'b001; mul2 = 3'b011; div2 = 3'b100; end //   0.5    2   -2
        8'd230: begin zero = 3'b000; sign = 3'b001; mul2 = 3'b011; div2 = 3'b000; end //     1    2   -2
        8'd231: begin zero = 3'b000; sign = 3'b001; mul2 = 3'b111; div2 = 3'b000; end //     2    2   -2
        8'd232: begin zero = 3'b000; sign = 3'b101; mul2 = 3'b011; div2 = 3'b000; end //    -1    2   -2
        8'd233: begin zero = 3'b000; sign = 3'b101; mul2 = 3'b111; div2 = 3'b000; end //    -2    2   -2
        8'd234: begin zero = 3'b100; sign = 3'b011; mul2 = 3'b001; div2 = 3'b010; end //     0 -0.5   -2
        8'd235: begin zero = 3'b000; sign = 3'b011; mul2 = 3'b001; div2 = 3'b110; end //   0.5 -0.5   -2
        8'd236: begin zero = 3'b000; sign = 3'b011; mul2 = 3'b001; div2 = 3'b010; end //     1 -0.5   -2
        8'd237: begin zero = 3'b000; sign = 3'b011; mul2 = 3'b101; div2 = 3'b010; end //     2 -0.5   -2
        8'd238: begin zero = 3'b000; sign = 3'b111; mul2 = 3'b001; div2 = 3'b010; end //    -1 -0.5   -2
        8'd239: begin zero = 3'b000; sign = 3'b111; mul2 = 3'b101; div2 = 3'b010; end //    -2 -0.5   -2
        8'd240: begin zero = 3'b100; sign = 3'b011; mul2 = 3'b001; div2 = 3'b000; end //     0   -1   -2
        8'd241: begin zero = 3'b000; sign = 3'b011; mul2 = 3'b001; div2 = 3'b100; end //   0.5   -1   -2
        8'd242: begin zero = 3'b000; sign = 3'b011; mul2 = 3'b001; div2 = 3'b000; end //     1   -1   -2
        8'd243: begin zero = 3'b000; sign = 3'b011; mul2 = 3'b101; div2 = 3'b000; end //     2   -1   -2
        8'd244: begin zero = 3'b000; sign = 3'b111; mul2 = 3'b001; div2 = 3'b000; end //    -1   -1   -2
        8'd245: begin zero = 3'b000; sign = 3'b111; mul2 = 3'b101; div2 = 3'b000; end //    -2   -1   -2
        8'd246: begin zero = 3'b100; sign = 3'b011; mul2 = 3'b011; div2 = 3'b000; end //     0   -2   -2
        8'd247: begin zero = 3'b000; sign = 3'b011; mul2 = 3'b011; div2 = 3'b100; end //   0.5   -2   -2
        8'd248: begin zero = 3'b000; sign = 3'b011; mul2 = 3'b011; div2 = 3'b000; end //     1   -2   -2
        8'd249: begin zero = 3'b000; sign = 3'b011; mul2 = 3'b111; div2 = 3'b000; end //     2   -2   -2
        8'd250: begin zero = 3'b000; sign = 3'b111; mul2 = 3'b011; div2 = 3'b000; end //    -1   -2   -2
        8'd251: begin zero = 3'b000; sign = 3'b111; mul2 = 3'b111; div2 = 3'b000; end //    -2   -2   -2
        default: {zero, sign, mul2, div2} = {3'b111, 3'b0, 3'b0, 3'b0}; // Default case
        endcase
    end
endmodule

module unpack_775_weights(input      [7:0] packed_weights,
                          output reg [2:0] zero,
                          output reg [2:0] sign,
                          output reg [2:0] mul2,
                          output reg [2:0] div2);
    always @(*) begin
        case(packed_weights)
        8'd000: begin zero = 3'b111; sign = 3'b000; mul2 = 3'b000; div2 = 3'b000; end //     0    0    0
        8'd001: begin zero = 3'b011; sign = 3'b000; mul2 = 3'b000; div2 = 3'b000; end //     1    0    0
        8'd002: begin zero = 3'b011; sign = 3'b000; mul2 = 3'b100; div2 = 3'b000; end //     2    0    0
        8'd003: begin zero = 3'b011; sign = 3'b100; mul2 = 3'b000; div2 = 3'b000; end //    -1    0    0
        8'd004: begin zero = 3'b011; sign = 3'b100; mul2 = 3'b100; div2 = 3'b000; end //    -2    0    0
        8'd005: begin zero = 3'b101; sign = 3'b000; mul2 = 3'b000; div2 = 3'b010; end //     0  0.5    0
        8'd006: begin zero = 3'b001; sign = 3'b000; mul2 = 3'b000; div2 = 3'b010; end //     1  0.5    0
        8'd007: begin zero = 3'b001; sign = 3'b000; mul2 = 3'b100; div2 = 3'b010; end //     2  0.5    0
        8'd008: begin zero = 3'b001; sign = 3'b100; mul2 = 3'b000; div2 = 3'b010; end //    -1  0.5    0
        8'd009: begin zero = 3'b001; sign = 3'b100; mul2 = 3'b100; div2 = 3'b010; end //    -2  0.5    0
        8'd010: begin zero = 3'b101; sign = 3'b000; mul2 = 3'b000; div2 = 3'b000; end //     0    1    0
        8'd011: begin zero = 3'b001; sign = 3'b000; mul2 = 3'b000; div2 = 3'b000; end //     1    1    0
        8'd012: begin zero = 3'b001; sign = 3'b000; mul2 = 3'b100; div2 = 3'b000; end //     2    1    0
        8'd013: begin zero = 3'b001; sign = 3'b100; mul2 = 3'b000; div2 = 3'b000; end //    -1    1    0
        8'd014: begin zero = 3'b001; sign = 3'b100; mul2 = 3'b100; div2 = 3'b000; end //    -2    1    0
        8'd015: begin zero = 3'b101; sign = 3'b000; mul2 = 3'b010; div2 = 3'b000; end //     0    2    0
        8'd016: begin zero = 3'b001; sign = 3'b000; mul2 = 3'b010; div2 = 3'b000; end //     1    2    0
        8'd017: begin zero = 3'b001; sign = 3'b000; mul2 = 3'b110; div2 = 3'b000; end //     2    2    0
        8'd018: begin zero = 3'b001; sign = 3'b100; mul2 = 3'b010; div2 = 3'b000; end //    -1    2    0
        8'd019: begin zero = 3'b001; sign = 3'b100; mul2 = 3'b110; div2 = 3'b000; end //    -2    2    0
        8'd020: begin zero = 3'b101; sign = 3'b010; mul2 = 3'b000; div2 = 3'b010; end //     0 -0.5    0
        8'd021: begin zero = 3'b001; sign = 3'b010; mul2 = 3'b000; div2 = 3'b010; end //     1 -0.5    0
        8'd022: begin zero = 3'b001; sign = 3'b010; mul2 = 3'b100; div2 = 3'b010; end //     2 -0.5    0
        8'd023: begin zero = 3'b001; sign = 3'b110; mul2 = 3'b000; div2 = 3'b010; end //    -1 -0.5    0
        8'd024: begin zero = 3'b001; sign = 3'b110; mul2 = 3'b100; div2 = 3'b010; end //    -2 -0.5    0
        8'd025: begin zero = 3'b101; sign = 3'b010; mul2 = 3'b000; div2 = 3'b000; end //     0   -1    0
        8'd026: begin zero = 3'b001; sign = 3'b010; mul2 = 3'b000; div2 = 3'b000; end //     1   -1    0
        8'd027: begin zero = 3'b001; sign = 3'b010; mul2 = 3'b100; div2 = 3'b000; end //     2   -1    0
        8'd028: begin zero = 3'b001; sign = 3'b110; mul2 = 3'b000; div2 = 3'b000; end //    -1   -1    0
        8'd029: begin zero = 3'b001; sign = 3'b110; mul2 = 3'b100; div2 = 3'b000; end //    -2   -1    0
        8'd030: begin zero = 3'b101; sign = 3'b010; mul2 = 3'b010; div2 = 3'b000; end //     0   -2    0
        8'd031: begin zero = 3'b001; sign = 3'b010; mul2 = 3'b010; div2 = 3'b000; end //     1   -2    0
        8'd032: begin zero = 3'b001; sign = 3'b010; mul2 = 3'b110; div2 = 3'b000; end //     2   -2    0
        8'd033: begin zero = 3'b001; sign = 3'b110; mul2 = 3'b010; div2 = 3'b000; end //    -1   -2    0
        8'd034: begin zero = 3'b001; sign = 3'b110; mul2 = 3'b110; div2 = 3'b000; end //    -2   -2    0
        8'd035: begin zero = 3'b110; sign = 3'b000; mul2 = 3'b000; div2 = 3'b001; end //     0    0  0.5
        8'd036: begin zero = 3'b010; sign = 3'b000; mul2 = 3'b000; div2 = 3'b001; end //     1    0  0.5
        8'd037: begin zero = 3'b010; sign = 3'b000; mul2 = 3'b100; div2 = 3'b001; end //     2    0  0.5
        8'd038: begin zero = 3'b010; sign = 3'b100; mul2 = 3'b000; div2 = 3'b001; end //    -1    0  0.5
        8'd039: begin zero = 3'b010; sign = 3'b100; mul2 = 3'b100; div2 = 3'b001; end //    -2    0  0.5
        8'd040: begin zero = 3'b100; sign = 3'b000; mul2 = 3'b000; div2 = 3'b011; end //     0  0.5  0.5
        8'd041: begin zero = 3'b000; sign = 3'b000; mul2 = 3'b000; div2 = 3'b011; end //     1  0.5  0.5
        8'd042: begin zero = 3'b000; sign = 3'b000; mul2 = 3'b100; div2 = 3'b011; end //     2  0.5  0.5
        8'd043: begin zero = 3'b000; sign = 3'b100; mul2 = 3'b000; div2 = 3'b011; end //    -1  0.5  0.5
        8'd044: begin zero = 3'b000; sign = 3'b100; mul2 = 3'b100; div2 = 3'b011; end //    -2  0.5  0.5
        8'd045: begin zero = 3'b100; sign = 3'b000; mul2 = 3'b000; div2 = 3'b001; end //     0    1  0.5
        8'd046: begin zero = 3'b000; sign = 3'b000; mul2 = 3'b000; div2 = 3'b001; end //     1    1  0.5
        8'd047: begin zero = 3'b000; sign = 3'b000; mul2 = 3'b100; div2 = 3'b001; end //     2    1  0.5
        8'd048: begin zero = 3'b000; sign = 3'b100; mul2 = 3'b000; div2 = 3'b001; end //    -1    1  0.5
        8'd049: begin zero = 3'b000; sign = 3'b100; mul2 = 3'b100; div2 = 3'b001; end //    -2    1  0.5
        8'd050: begin zero = 3'b100; sign = 3'b000; mul2 = 3'b010; div2 = 3'b001; end //     0    2  0.5
        8'd051: begin zero = 3'b000; sign = 3'b000; mul2 = 3'b010; div2 = 3'b001; end //     1    2  0.5
        8'd052: begin zero = 3'b000; sign = 3'b000; mul2 = 3'b110; div2 = 3'b001; end //     2    2  0.5
        8'd053: begin zero = 3'b000; sign = 3'b100; mul2 = 3'b010; div2 = 3'b001; end //    -1    2  0.5
        8'd054: begin zero = 3'b000; sign = 3'b100; mul2 = 3'b110; div2 = 3'b001; end //    -2    2  0.5
        8'd055: begin zero = 3'b100; sign = 3'b010; mul2 = 3'b000; div2 = 3'b011; end //     0 -0.5  0.5
        8'd056: begin zero = 3'b000; sign = 3'b010; mul2 = 3'b000; div2 = 3'b011; end //     1 -0.5  0.5
        8'd057: begin zero = 3'b000; sign = 3'b010; mul2 = 3'b100; div2 = 3'b011; end //     2 -0.5  0.5
        8'd058: begin zero = 3'b000; sign = 3'b110; mul2 = 3'b000; div2 = 3'b011; end //    -1 -0.5  0.5
        8'd059: begin zero = 3'b000; sign = 3'b110; mul2 = 3'b100; div2 = 3'b011; end //    -2 -0.5  0.5
        8'd060: begin zero = 3'b100; sign = 3'b010; mul2 = 3'b000; div2 = 3'b001; end //     0   -1  0.5
        8'd061: begin zero = 3'b000; sign = 3'b010; mul2 = 3'b000; div2 = 3'b001; end //     1   -1  0.5
        8'd062: begin zero = 3'b000; sign = 3'b010; mul2 = 3'b100; div2 = 3'b001; end //     2   -1  0.5
        8'd063: begin zero = 3'b000; sign = 3'b110; mul2 = 3'b000; div2 = 3'b001; end //    -1   -1  0.5
        8'd064: begin zero = 3'b000; sign = 3'b110; mul2 = 3'b100; div2 = 3'b001; end //    -2   -1  0.5
        8'd065: begin zero = 3'b100; sign = 3'b010; mul2 = 3'b010; div2 = 3'b001; end //     0   -2  0.5
        8'd066: begin zero = 3'b000; sign = 3'b010; mul2 = 3'b010; div2 = 3'b001; end //     1   -2  0.5
        8'd067: begin zero = 3'b000; sign = 3'b010; mul2 = 3'b110; div2 = 3'b001; end //     2   -2  0.5
        8'd068: begin zero = 3'b000; sign = 3'b110; mul2 = 3'b010; div2 = 3'b001; end //    -1   -2  0.5
        8'd069: begin zero = 3'b000; sign = 3'b110; mul2 = 3'b110; div2 = 3'b001; end //    -2   -2  0.5
        8'd070: begin zero = 3'b110; sign = 3'b000; mul2 = 3'b000; div2 = 3'b000; end //     0    0    1
        8'd071: begin zero = 3'b010; sign = 3'b000; mul2 = 3'b000; div2 = 3'b000; end //     1    0    1
        8'd072: begin zero = 3'b010; sign = 3'b000; mul2 = 3'b100; div2 = 3'b000; end //     2    0    1
        8'd073: begin zero = 3'b010; sign = 3'b100; mul2 = 3'b000; div2 = 3'b000; end //    -1    0    1
        8'd074: begin zero = 3'b010; sign = 3'b100; mul2 = 3'b100; div2 = 3'b000; end //    -2    0    1
        8'd075: begin zero = 3'b100; sign = 3'b000; mul2 = 3'b000; div2 = 3'b010; end //     0  0.5    1
        8'd076: begin zero = 3'b000; sign = 3'b000; mul2 = 3'b000; div2 = 3'b010; end //     1  0.5    1
        8'd077: begin zero = 3'b000; sign = 3'b000; mul2 = 3'b100; div2 = 3'b010; end //     2  0.5    1
        8'd078: begin zero = 3'b000; sign = 3'b100; mul2 = 3'b000; div2 = 3'b010; end //    -1  0.5    1
        8'd079: begin zero = 3'b000; sign = 3'b100; mul2 = 3'b100; div2 = 3'b010; end //    -2  0.5    1
        8'd080: begin zero = 3'b100; sign = 3'b000; mul2 = 3'b000; div2 = 3'b000; end //     0    1    1
        8'd081: begin zero = 3'b000; sign = 3'b000; mul2 = 3'b000; div2 = 3'b000; end //     1    1    1
        8'd082: begin zero = 3'b000; sign = 3'b000; mul2 = 3'b100; div2 = 3'b000; end //     2    1    1
        8'd083: begin zero = 3'b000; sign = 3'b100; mul2 = 3'b000; div2 = 3'b000; end //    -1    1    1
        8'd084: begin zero = 3'b000; sign = 3'b100; mul2 = 3'b100; div2 = 3'b000; end //    -2    1    1
        8'd085: begin zero = 3'b100; sign = 3'b000; mul2 = 3'b010; div2 = 3'b000; end //     0    2    1
        8'd086: begin zero = 3'b000; sign = 3'b000; mul2 = 3'b010; div2 = 3'b000; end //     1    2    1
        8'd087: begin zero = 3'b000; sign = 3'b000; mul2 = 3'b110; div2 = 3'b000; end //     2    2    1
        8'd088: begin zero = 3'b000; sign = 3'b100; mul2 = 3'b010; div2 = 3'b000; end //    -1    2    1
        8'd089: begin zero = 3'b000; sign = 3'b100; mul2 = 3'b110; div2 = 3'b000; end //    -2    2    1
        8'd090: begin zero = 3'b100; sign = 3'b010; mul2 = 3'b000; div2 = 3'b010; end //     0 -0.5    1
        8'd091: begin zero = 3'b000; sign = 3'b010; mul2 = 3'b000; div2 = 3'b010; end //     1 -0.5    1
        8'd092: begin zero = 3'b000; sign = 3'b010; mul2 = 3'b100; div2 = 3'b010; end //     2 -0.5    1
        8'd093: begin zero = 3'b000; sign = 3'b110; mul2 = 3'b000; div2 = 3'b010; end //    -1 -0.5    1
        8'd094: begin zero = 3'b000; sign = 3'b110; mul2 = 3'b100; div2 = 3'b010; end //    -2 -0.5    1
        8'd095: begin zero = 3'b100; sign = 3'b010; mul2 = 3'b000; div2 = 3'b000; end //     0   -1    1
        8'd096: begin zero = 3'b000; sign = 3'b010; mul2 = 3'b000; div2 = 3'b000; end //     1   -1    1
        8'd097: begin zero = 3'b000; sign = 3'b010; mul2 = 3'b100; div2 = 3'b000; end //     2   -1    1
        8'd098: begin zero = 3'b000; sign = 3'b110; mul2 = 3'b000; div2 = 3'b000; end //    -1   -1    1
        8'd099: begin zero = 3'b000; sign = 3'b110; mul2 = 3'b100; div2 = 3'b000; end //    -2   -1    1
        8'd100: begin zero = 3'b100; sign = 3'b010; mul2 = 3'b010; div2 = 3'b000; end //     0   -2    1
        8'd101: begin zero = 3'b000; sign = 3'b010; mul2 = 3'b010; div2 = 3'b000; end //     1   -2    1
        8'd102: begin zero = 3'b000; sign = 3'b010; mul2 = 3'b110; div2 = 3'b000; end //     2   -2    1
        8'd103: begin zero = 3'b000; sign = 3'b110; mul2 = 3'b010; div2 = 3'b000; end //    -1   -2    1
        8'd104: begin zero = 3'b000; sign = 3'b110; mul2 = 3'b110; div2 = 3'b000; end //    -2   -2    1
        8'd105: begin zero = 3'b110; sign = 3'b000; mul2 = 3'b001; div2 = 3'b000; end //     0    0    2
        8'd106: begin zero = 3'b010; sign = 3'b000; mul2 = 3'b001; div2 = 3'b000; end //     1    0    2
        8'd107: begin zero = 3'b010; sign = 3'b000; mul2 = 3'b101; div2 = 3'b000; end //     2    0    2
        8'd108: begin zero = 3'b010; sign = 3'b100; mul2 = 3'b001; div2 = 3'b000; end //    -1    0    2
        8'd109: begin zero = 3'b010; sign = 3'b100; mul2 = 3'b101; div2 = 3'b000; end //    -2    0    2
        8'd110: begin zero = 3'b100; sign = 3'b000; mul2 = 3'b001; div2 = 3'b010; end //     0  0.5    2
        8'd111: begin zero = 3'b000; sign = 3'b000; mul2 = 3'b001; div2 = 3'b010; end //     1  0.5    2
        8'd112: begin zero = 3'b000; sign = 3'b000; mul2 = 3'b101; div2 = 3'b010; end //     2  0.5    2
        8'd113: begin zero = 3'b000; sign = 3'b100; mul2 = 3'b001; div2 = 3'b010; end //    -1  0.5    2
        8'd114: begin zero = 3'b000; sign = 3'b100; mul2 = 3'b101; div2 = 3'b010; end //    -2  0.5    2
        8'd115: begin zero = 3'b100; sign = 3'b000; mul2 = 3'b001; div2 = 3'b000; end //     0    1    2
        8'd116: begin zero = 3'b000; sign = 3'b000; mul2 = 3'b001; div2 = 3'b000; end //     1    1    2
        8'd117: begin zero = 3'b000; sign = 3'b000; mul2 = 3'b101; div2 = 3'b000; end //     2    1    2
        8'd118: begin zero = 3'b000; sign = 3'b100; mul2 = 3'b001; div2 = 3'b000; end //    -1    1    2
        8'd119: begin zero = 3'b000; sign = 3'b100; mul2 = 3'b101; div2 = 3'b000; end //    -2    1    2
        8'd120: begin zero = 3'b100; sign = 3'b000; mul2 = 3'b011; div2 = 3'b000; end //     0    2    2
        8'd121: begin zero = 3'b000; sign = 3'b000; mul2 = 3'b011; div2 = 3'b000; end //     1    2    2
        8'd122: begin zero = 3'b000; sign = 3'b000; mul2 = 3'b111; div2 = 3'b000; end //     2    2    2
        8'd123: begin zero = 3'b000; sign = 3'b100; mul2 = 3'b011; div2 = 3'b000; end //    -1    2    2
        8'd124: begin zero = 3'b000; sign = 3'b100; mul2 = 3'b111; div2 = 3'b000; end //    -2    2    2
        8'd125: begin zero = 3'b100; sign = 3'b010; mul2 = 3'b001; div2 = 3'b010; end //     0 -0.5    2
        8'd126: begin zero = 3'b000; sign = 3'b010; mul2 = 3'b001; div2 = 3'b010; end //     1 -0.5    2
        8'd127: begin zero = 3'b000; sign = 3'b010; mul2 = 3'b101; div2 = 3'b010; end //     2 -0.5    2
        8'd128: begin zero = 3'b000; sign = 3'b110; mul2 = 3'b001; div2 = 3'b010; end //    -1 -0.5    2
        8'd129: begin zero = 3'b000; sign = 3'b110; mul2 = 3'b101; div2 = 3'b010; end //    -2 -0.5    2
        8'd130: begin zero = 3'b100; sign = 3'b010; mul2 = 3'b001; div2 = 3'b000; end //     0   -1    2
        8'd131: begin zero = 3'b000; sign = 3'b010; mul2 = 3'b001; div2 = 3'b000; end //     1   -1    2
        8'd132: begin zero = 3'b000; sign = 3'b010; mul2 = 3'b101; div2 = 3'b000; end //     2   -1    2
        8'd133: begin zero = 3'b000; sign = 3'b110; mul2 = 3'b001; div2 = 3'b000; end //    -1   -1    2
        8'd134: begin zero = 3'b000; sign = 3'b110; mul2 = 3'b101; div2 = 3'b000; end //    -2   -1    2
        8'd135: begin zero = 3'b100; sign = 3'b010; mul2 = 3'b011; div2 = 3'b000; end //     0   -2    2
        8'd136: begin zero = 3'b000; sign = 3'b010; mul2 = 3'b011; div2 = 3'b000; end //     1   -2    2
        8'd137: begin zero = 3'b000; sign = 3'b010; mul2 = 3'b111; div2 = 3'b000; end //     2   -2    2
        8'd138: begin zero = 3'b000; sign = 3'b110; mul2 = 3'b011; div2 = 3'b000; end //    -1   -2    2
        8'd139: begin zero = 3'b000; sign = 3'b110; mul2 = 3'b111; div2 = 3'b000; end //    -2   -2    2
        8'd140: begin zero = 3'b110; sign = 3'b001; mul2 = 3'b000; div2 = 3'b001; end //     0    0 -0.5
        8'd141: begin zero = 3'b010; sign = 3'b001; mul2 = 3'b000; div2 = 3'b001; end //     1    0 -0.5
        8'd142: begin zero = 3'b010; sign = 3'b001; mul2 = 3'b100; div2 = 3'b001; end //     2    0 -0.5
        8'd143: begin zero = 3'b010; sign = 3'b101; mul2 = 3'b000; div2 = 3'b001; end //    -1    0 -0.5
        8'd144: begin zero = 3'b010; sign = 3'b101; mul2 = 3'b100; div2 = 3'b001; end //    -2    0 -0.5
        8'd145: begin zero = 3'b100; sign = 3'b001; mul2 = 3'b000; div2 = 3'b011; end //     0  0.5 -0.5
        8'd146: begin zero = 3'b000; sign = 3'b001; mul2 = 3'b000; div2 = 3'b011; end //     1  0.5 -0.5
        8'd147: begin zero = 3'b000; sign = 3'b001; mul2 = 3'b100; div2 = 3'b011; end //     2  0.5 -0.5
        8'd148: begin zero = 3'b000; sign = 3'b101; mul2 = 3'b000; div2 = 3'b011; end //    -1  0.5 -0.5
        8'd149: begin zero = 3'b000; sign = 3'b101; mul2 = 3'b100; div2 = 3'b011; end //    -2  0.5 -0.5
        8'd150: begin zero = 3'b100; sign = 3'b001; mul2 = 3'b000; div2 = 3'b001; end //     0    1 -0.5
        8'd151: begin zero = 3'b000; sign = 3'b001; mul2 = 3'b000; div2 = 3'b001; end //     1    1 -0.5
        8'd152: begin zero = 3'b000; sign = 3'b001; mul2 = 3'b100; div2 = 3'b001; end //     2    1 -0.5
        8'd153: begin zero = 3'b000; sign = 3'b101; mul2 = 3'b000; div2 = 3'b001; end //    -1    1 -0.5
        8'd154: begin zero = 3'b000; sign = 3'b101; mul2 = 3'b100; div2 = 3'b001; end //    -2    1 -0.5
        8'd155: begin zero = 3'b100; sign = 3'b001; mul2 = 3'b010; div2 = 3'b001; end //     0    2 -0.5
        8'd156: begin zero = 3'b000; sign = 3'b001; mul2 = 3'b010; div2 = 3'b001; end //     1    2 -0.5
        8'd157: begin zero = 3'b000; sign = 3'b001; mul2 = 3'b110; div2 = 3'b001; end //     2    2 -0.5
        8'd158: begin zero = 3'b000; sign = 3'b101; mul2 = 3'b010; div2 = 3'b001; end //    -1    2 -0.5
        8'd159: begin zero = 3'b000; sign = 3'b101; mul2 = 3'b110; div2 = 3'b001; end //    -2    2 -0.5
        8'd160: begin zero = 3'b100; sign = 3'b011; mul2 = 3'b000; div2 = 3'b011; end //     0 -0.5 -0.5
        8'd161: begin zero = 3'b000; sign = 3'b011; mul2 = 3'b000; div2 = 3'b011; end //     1 -0.5 -0.5
        8'd162: begin zero = 3'b000; sign = 3'b011; mul2 = 3'b100; div2 = 3'b011; end //     2 -0.5 -0.5
        8'd163: begin zero = 3'b000; sign = 3'b111; mul2 = 3'b000; div2 = 3'b011; end //    -1 -0.5 -0.5
        8'd164: begin zero = 3'b000; sign = 3'b111; mul2 = 3'b100; div2 = 3'b011; end //    -2 -0.5 -0.5
        8'd165: begin zero = 3'b100; sign = 3'b011; mul2 = 3'b000; div2 = 3'b001; end //     0   -1 -0.5
        8'd166: begin zero = 3'b000; sign = 3'b011; mul2 = 3'b000; div2 = 3'b001; end //     1   -1 -0.5
        8'd167: begin zero = 3'b000; sign = 3'b011; mul2 = 3'b100; div2 = 3'b001; end //     2   -1 -0.5
        8'd168: begin zero = 3'b000; sign = 3'b111; mul2 = 3'b000; div2 = 3'b001; end //    -1   -1 -0.5
        8'd169: begin zero = 3'b000; sign = 3'b111; mul2 = 3'b100; div2 = 3'b001; end //    -2   -1 -0.5
        8'd170: begin zero = 3'b100; sign = 3'b011; mul2 = 3'b010; div2 = 3'b001; end //     0   -2 -0.5
        8'd171: begin zero = 3'b000; sign = 3'b011; mul2 = 3'b010; div2 = 3'b001; end //     1   -2 -0.5
        8'd172: begin zero = 3'b000; sign = 3'b011; mul2 = 3'b110; div2 = 3'b001; end //     2   -2 -0.5
        8'd173: begin zero = 3'b000; sign = 3'b111; mul2 = 3'b010; div2 = 3'b001; end //    -1   -2 -0.5
        8'd174: begin zero = 3'b000; sign = 3'b111; mul2 = 3'b110; div2 = 3'b001; end //    -2   -2 -0.5
        8'd175: begin zero = 3'b110; sign = 3'b001; mul2 = 3'b000; div2 = 3'b000; end //     0    0   -1
        8'd176: begin zero = 3'b010; sign = 3'b001; mul2 = 3'b000; div2 = 3'b000; end //     1    0   -1
        8'd177: begin zero = 3'b010; sign = 3'b001; mul2 = 3'b100; div2 = 3'b000; end //     2    0   -1
        8'd178: begin zero = 3'b010; sign = 3'b101; mul2 = 3'b000; div2 = 3'b000; end //    -1    0   -1
        8'd179: begin zero = 3'b010; sign = 3'b101; mul2 = 3'b100; div2 = 3'b000; end //    -2    0   -1
        8'd180: begin zero = 3'b100; sign = 3'b001; mul2 = 3'b000; div2 = 3'b010; end //     0  0.5   -1
        8'd181: begin zero = 3'b000; sign = 3'b001; mul2 = 3'b000; div2 = 3'b010; end //     1  0.5   -1
        8'd182: begin zero = 3'b000; sign = 3'b001; mul2 = 3'b100; div2 = 3'b010; end //     2  0.5   -1
        8'd183: begin zero = 3'b000; sign = 3'b101; mul2 = 3'b000; div2 = 3'b010; end //    -1  0.5   -1
        8'd184: begin zero = 3'b000; sign = 3'b101; mul2 = 3'b100; div2 = 3'b010; end //    -2  0.5   -1
        8'd185: begin zero = 3'b100; sign = 3'b001; mul2 = 3'b000; div2 = 3'b000; end //     0    1   -1
        8'd186: begin zero = 3'b000; sign = 3'b001; mul2 = 3'b000; div2 = 3'b000; end //     1    1   -1
        8'd187: begin zero = 3'b000; sign = 3'b001; mul2 = 3'b100; div2 = 3'b000; end //     2    1   -1
        8'd188: begin zero = 3'b000; sign = 3'b101; mul2 = 3'b000; div2 = 3'b000; end //    -1    1   -1
        8'd189: begin zero = 3'b000; sign = 3'b101; mul2 = 3'b100; div2 = 3'b000; end //    -2    1   -1
        8'd190: begin zero = 3'b100; sign = 3'b001; mul2 = 3'b010; div2 = 3'b000; end //     0    2   -1
        8'd191: begin zero = 3'b000; sign = 3'b001; mul2 = 3'b010; div2 = 3'b000; end //     1    2   -1
        8'd192: begin zero = 3'b000; sign = 3'b001; mul2 = 3'b110; div2 = 3'b000; end //     2    2   -1
        8'd193: begin zero = 3'b000; sign = 3'b101; mul2 = 3'b010; div2 = 3'b000; end //    -1    2   -1
        8'd194: begin zero = 3'b000; sign = 3'b101; mul2 = 3'b110; div2 = 3'b000; end //    -2    2   -1
        8'd195: begin zero = 3'b100; sign = 3'b011; mul2 = 3'b000; div2 = 3'b010; end //     0 -0.5   -1
        8'd196: begin zero = 3'b000; sign = 3'b011; mul2 = 3'b000; div2 = 3'b010; end //     1 -0.5   -1
        8'd197: begin zero = 3'b000; sign = 3'b011; mul2 = 3'b100; div2 = 3'b010; end //     2 -0.5   -1
        8'd198: begin zero = 3'b000; sign = 3'b111; mul2 = 3'b000; div2 = 3'b010; end //    -1 -0.5   -1
        8'd199: begin zero = 3'b000; sign = 3'b111; mul2 = 3'b100; div2 = 3'b010; end //    -2 -0.5   -1
        8'd200: begin zero = 3'b100; sign = 3'b011; mul2 = 3'b000; div2 = 3'b000; end //     0   -1   -1
        8'd201: begin zero = 3'b000; sign = 3'b011; mul2 = 3'b000; div2 = 3'b000; end //     1   -1   -1
        8'd202: begin zero = 3'b000; sign = 3'b011; mul2 = 3'b100; div2 = 3'b000; end //     2   -1   -1
        8'd203: begin zero = 3'b000; sign = 3'b111; mul2 = 3'b000; div2 = 3'b000; end //    -1   -1   -1
        8'd204: begin zero = 3'b000; sign = 3'b111; mul2 = 3'b100; div2 = 3'b000; end //    -2   -1   -1
        8'd205: begin zero = 3'b100; sign = 3'b011; mul2 = 3'b010; div2 = 3'b000; end //     0   -2   -1
        8'd206: begin zero = 3'b000; sign = 3'b011; mul2 = 3'b010; div2 = 3'b000; end //     1   -2   -1
        8'd207: begin zero = 3'b000; sign = 3'b011; mul2 = 3'b110; div2 = 3'b000; end //     2   -2   -1
        8'd208: begin zero = 3'b000; sign = 3'b111; mul2 = 3'b010; div2 = 3'b000; end //    -1   -2   -1
        8'd209: begin zero = 3'b000; sign = 3'b111; mul2 = 3'b110; div2 = 3'b000; end //    -2   -2   -1
        8'd210: begin zero = 3'b110; sign = 3'b001; mul2 = 3'b001; div2 = 3'b000; end //     0    0   -2
        8'd211: begin zero = 3'b010; sign = 3'b001; mul2 = 3'b001; div2 = 3'b000; end //     1    0   -2
        8'd212: begin zero = 3'b010; sign = 3'b001; mul2 = 3'b101; div2 = 3'b000; end //     2    0   -2
        8'd213: begin zero = 3'b010; sign = 3'b101; mul2 = 3'b001; div2 = 3'b000; end //    -1    0   -2
        8'd214: begin zero = 3'b010; sign = 3'b101; mul2 = 3'b101; div2 = 3'b000; end //    -2    0   -2
        8'd215: begin zero = 3'b100; sign = 3'b001; mul2 = 3'b001; div2 = 3'b010; end //     0  0.5   -2
        8'd216: begin zero = 3'b000; sign = 3'b001; mul2 = 3'b001; div2 = 3'b010; end //     1  0.5   -2
        8'd217: begin zero = 3'b000; sign = 3'b001; mul2 = 3'b101; div2 = 3'b010; end //     2  0.5   -2
        8'd218: begin zero = 3'b000; sign = 3'b101; mul2 = 3'b001; div2 = 3'b010; end //    -1  0.5   -2
        8'd219: begin zero = 3'b000; sign = 3'b101; mul2 = 3'b101; div2 = 3'b010; end //    -2  0.5   -2
        8'd220: begin zero = 3'b100; sign = 3'b001; mul2 = 3'b001; div2 = 3'b000; end //     0    1   -2
        8'd221: begin zero = 3'b000; sign = 3'b001; mul2 = 3'b001; div2 = 3'b000; end //     1    1   -2
        8'd222: begin zero = 3'b000; sign = 3'b001; mul2 = 3'b101; div2 = 3'b000; end //     2    1   -2
        8'd223: begin zero = 3'b000; sign = 3'b101; mul2 = 3'b001; div2 = 3'b000; end //    -1    1   -2
        8'd224: begin zero = 3'b000; sign = 3'b101; mul2 = 3'b101; div2 = 3'b000; end //    -2    1   -2
        8'd225: begin zero = 3'b100; sign = 3'b001; mul2 = 3'b011; div2 = 3'b000; end //     0    2   -2
        8'd226: begin zero = 3'b000; sign = 3'b001; mul2 = 3'b011; div2 = 3'b000; end //     1    2   -2
        8'd227: begin zero = 3'b000; sign = 3'b001; mul2 = 3'b111; div2 = 3'b000; end //     2    2   -2
        8'd228: begin zero = 3'b000; sign = 3'b101; mul2 = 3'b011; div2 = 3'b000; end //    -1    2   -2
        8'd229: begin zero = 3'b000; sign = 3'b101; mul2 = 3'b111; div2 = 3'b000; end //    -2    2   -2
        8'd230: begin zero = 3'b100; sign = 3'b011; mul2 = 3'b001; div2 = 3'b010; end //     0 -0.5   -2
        8'd231: begin zero = 3'b000; sign = 3'b011; mul2 = 3'b001; div2 = 3'b010; end //     1 -0.5   -2
        8'd232: begin zero = 3'b000; sign = 3'b011; mul2 = 3'b101; div2 = 3'b010; end //     2 -0.5   -2
        8'd233: begin zero = 3'b000; sign = 3'b111; mul2 = 3'b001; div2 = 3'b010; end //    -1 -0.5   -2
        8'd234: begin zero = 3'b000; sign = 3'b111; mul2 = 3'b101; div2 = 3'b010; end //    -2 -0.5   -2
        8'd235: begin zero = 3'b100; sign = 3'b011; mul2 = 3'b001; div2 = 3'b000; end //     0   -1   -2
        8'd236: begin zero = 3'b000; sign = 3'b011; mul2 = 3'b001; div2 = 3'b000; end //     1   -1   -2
        8'd237: begin zero = 3'b000; sign = 3'b011; mul2 = 3'b101; div2 = 3'b000; end //     2   -1   -2
        8'd238: begin zero = 3'b000; sign = 3'b111; mul2 = 3'b001; div2 = 3'b000; end //    -1   -1   -2
        8'd239: begin zero = 3'b000; sign = 3'b111; mul2 = 3'b101; div2 = 3'b000; end //    -2   -1   -2
        8'd240: begin zero = 3'b100; sign = 3'b011; mul2 = 3'b011; div2 = 3'b000; end //     0   -2   -2
        8'd241: begin zero = 3'b000; sign = 3'b011; mul2 = 3'b011; div2 = 3'b000; end //     1   -2   -2
        8'd242: begin zero = 3'b000; sign = 3'b011; mul2 = 3'b111; div2 = 3'b000; end //     2   -2   -2
        8'd243: begin zero = 3'b000; sign = 3'b111; mul2 = 3'b011; div2 = 3'b000; end //    -1   -2   -2
        8'd244: begin zero = 3'b000; sign = 3'b111; mul2 = 3'b111; div2 = 3'b000; end //    -2   -2   -2
        default: {zero, sign, mul2, div2} = {3'b111, 3'b0, 3'b0, 3'b0}; // Default case
        endcase
    end
endmodule
