module Alu #(
    parameter   DATA_W = 32,
    parameter   OP_W = 6,
    parameter   IM_W = 16,
)(
	input   [OP_W-1     : 0]    i_op,
    input   [DATA_W-1   : 0]    i_in_0,
    input   [DATA_W-1   : 0]    i_in_1,
    input   [IM_W-1     : 0]    i_im,
    output  [DATA_W-1   : 0]    o_alu_result,
    output                      o_zero,
    output                      o_overflow,
);

// LW   000001
// SW   000010
// ADD  000011
// SUB  000100
// ADDI 000101
// OR   000110
// XOR  000111
// BEQ  001000
// BNE  001001
// EOF  001010

reg     o_alu_result, o_overflow;

wire    [DATA_W     : 0]    mem_addr;
wire                        mem_addr_of;
wire    [DATA_W     : 0]    add_i0, add_i1;
wire    [DATA_W     : 0]    add_result;
wire                        add_result_of;
wire    [DATA_W     : 0]    sub_result;
wire                        sub_result_of;
wire    [DATA_W-1   : 0]    or_result;
wire    [DATA_W-1   : 0]    xor_result;


assign  mem_addr        = {i_in_0[DATA_W-1], i_in_0} + {{(DATA_W-IM_W+1){i_im[IM_W-1]}}, i_im};
assign  mem_addr_of     = mem_addr[DATA_W] ^ mem_addr[DATA_W-1];

assign  add_i0          = {i_in_0[DATA_W-1], i_in_0};
assign  add_i1          = i_op[1]? {i_in_1[DATA_W-1], i_in_1}: {{(DATA_W-IM_W+1){i_im[IM_W-1]}}, i_im};
assign  add_result      = {i_in_0[DATA_W-1], i_in_0} + {i_in_1[DATA_W-1], i_in_1};
assign  add_result_of   = add_result[DATA_W] ^ add_result[DATA_W-1];

assign  sub_result      = {i_in_0[DATA_W-1], i_in_0} - {i_in_1[DATA_W-1], i_in_1};
assign  sub_result_of   = sub_result[DATA_W] ^ sub_result[DATA_W-1];

assign  or_result       = i_in_0 | i_in_1;

assign  xor_result      = i_in_0 ^ i_in_1;

assign  o_zero          = ~( sub_result_of | |sub_result );


always@(i_op or i_in_0 or i_in_1 or i_im) begin
    o_alu_result = {DATA_W{1'b0}};
    o_overflow = 1'b0;

    if(~i_op[3] & ~i_op[2] & (i_op[1] ^ i_op[0])) begin
        // LW, SW
        o_alu_result = mem_addr;
        o_overflow = mem_addr_of;
    end
    else if((i_op[2] ^ i_op[1]) & i_op[0]) begin
        // ADD, ADDI
        o_alu_result = add_result;
        o_overflow = add_result_of;
    end
    else if(i_op[2] & ~i_op[1] & ~i_op[0]) begin
        // SUB
        o_alu_result = sub_result;
        o_overflow = sub_result_of;
    end
    else if(i_op[2] & i_op[1] & ~i_op[0]) begin
        // OR
        o_alu_result = or_result;
    end
    else if(i_op[2] & ~i_op[1] & i_op[0]) begin
        // XOR
        o_alu_result = xor_result;
    end
end

endmodule