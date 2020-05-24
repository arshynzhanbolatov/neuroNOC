//////////////////////////////////////////////////////////////////////////////////
// Company: Nazarbayev University
// Engineer: Arshyn Zhanbolatov
// 
// Create Date: 09.08.2018 
// Design Name: PE
// Module Name: processingElement
// Project Name: NeuroNoc
// Target Devices: 
// Tool Versions: 
// Description: 
//////////////////////////////////////////////////////////////////////////////////

module processingElement(clk, rst, NI_PE_valid, NI_PE_packet, NI_PE_ready, PE_NI_ready, PE_NI_packet, PE_NI_valid);
parameter SOURCE_ADDRESS=1;
`include "header.vh"

input clk;
input rst;
input NI_PE_valid;
input [PACKET_SIZE-1:0] NI_PE_packet;
output NI_PE_ready;
input PE_NI_ready;
output [PACKET_SIZE-1:0] PE_NI_packet;
output PE_NI_valid;


wire hlt;
wire SNC_MUL_valid;
wire [TYPE_WIDTH-1:0] SNC_MUL_type;
wire [SEQ_WIDTH-1:0] SNC_MUL_seqNum;
wire [SOURCE_WIDTH-1:0] SNC_MUL_sourceAddress;
wire [PAYLOAD_WIDTH-1:0] SNC_MUL_data;
 
seqNumCheck
snc
(.clk(clk),
 .rst(rst),
 .hlt(hlt),
 .NI_SNC_valid(NI_PE_valid),
 .NI_SNC_packet(NI_PE_packet),
 .SNC_MUL_valid(SNC_MUL_valid),
 .SNC_MUL_type(SNC_MUL_type),
 .SNC_MUL_seqNum(SNC_MUL_seqNum),
 .SNC_MUL_sourceAddress(SNC_MUL_sourceAddress),
 .SNC_MUL_data(SNC_MUL_data)
);

wire MUL_ACC_valid;
wire [TYPE_WIDTH-1:0] MUL_ACC_type;
wire [SEQ_WIDTH-1:0] MUL_ACC_seqNum;
wire [max(PRODUCT_WIDTH,SOURCE_WIDTH+PAYLOAD_WIDTH)-1:0] MUL_ACC_data;


multiplier
mul
(.clk(clk),
 .rst(rst),
 .hlt(hlt),
 .SNC_MUL_valid(SNC_MUL_valid),
 .SNC_MUL_type(SNC_MUL_type),
 .SNC_MUL_seqNum(SNC_MUL_seqNum),
 .SNC_MUL_sourceAddress(SNC_MUL_sourceAddress),
 .SNC_MUL_data(SNC_MUL_data),
 .MUL_ACC_valid(MUL_ACC_valid),
 .MUL_ACC_type(MUL_ACC_type),
 .MUL_ACC_seqNum(MUL_ACC_seqNum),
 .MUL_ACC_data(MUL_ACC_data)
);


wire ACC_AF_valid;
wire [TYPE_WIDTH-1:0] ACC_AF_type;
wire [SEQ_WIDTH-1:0] ACC_AF_seqNum;
wire [SSUM_WIDTH-1:0] ACC_AF_data;

accumulator
acc
(.clk(clk),
 .rst(rst),
 .hlt(hlt),
 .MUL_ACC_valid(MUL_ACC_valid),
 .MUL_ACC_type(MUL_ACC_type),
 .MUL_ACC_seqNum(MUL_ACC_seqNum),
 .MUL_ACC_data(MUL_ACC_data),
 .ACC_AF_valid(ACC_AF_valid),
 .ACC_AF_type(ACC_AF_type),
 .ACC_AF_seqNum(ACC_AF_seqNum),
 .ACC_AF_data(ACC_AF_data)
);


activationFunction #(.SOURCE_ADDRESS(SOURCE_ADDRESS)) af 
(.clk(clk),
 .rst(rst),
 .hlt(hlt),
 .ACC_AF_valid(ACC_AF_valid),
 .ACC_AF_type(ACC_AF_type),
 .ACC_AF_seqNum(ACC_AF_seqNum),
 .ACC_AF_data(ACC_AF_data),
 .AF_NI_packet(PE_NI_packet),
 .AF_NI_valid(PE_NI_valid));
 

assign NI_PE_ready=1'b1;
assign hlt=!PE_NI_ready;

endmodule
