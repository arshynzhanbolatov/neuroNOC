//////////////////////////////////////////////////////////////////////////////////
// Company: Nazarbayev University
// Engineer: Arshyn Zhanbolatov
// 
// Create Date: 09.08.2018 
// Design Name: AF
// Module Name: activationFunction
// Project Name: NeuroNoc
// Target Devices: 
// Tool Versions: 
// Description: 
//////////////////////////////////////////////////////////////////////////////////

module activationFunction(clk, rst, hlt, ACC_AF_valid, ACC_AF_type, ACC_AF_seqNum, ACC_AF_data, AF_NI_packet, AF_NI_valid);
parameter SOURCE_ADDRESS=1, DEST_ADDRESS=0;
`include "header.vh"

input clk;
input rst;
input hlt;
input ACC_AF_valid;
input [TYPE_WIDTH-1:0] ACC_AF_type;
input [SEQ_WIDTH-1:0] ACC_AF_seqNum;
input [SSUM_WIDTH-1:0] ACC_AF_data; 
output [PACKET_SIZE-1:0] AF_NI_packet;
output AF_NI_valid;


reg registered_valid;
reg [TYPE_WIDTH-1:0] registered_type;
reg [SEQ_WIDTH-1:0] registered_seqNum;
reg [SSUM_WIDTH-1:0] registered_data;

wire lut_readEnable;
wire [LUTADDRESS_WIDTH-1:0] lut_readAddress;
wire [PAYLOAD_WIDTH-1:0] lut_readValue;

wire [PAYLOAD_WIDTH-1:0] payload;
wire [SOURCE_WIDTH-1:0] sourceAddress;
wire [DEST_WIDTH-1:0] destAddress;

ROM #(.ROM_WIDTH(INPUT_WIDTH), .ROM_DEPTH(2**LUTADDRESS_WIDTH)) lut(
.addr(lut_readAddress),
.en(lut_readEnable), .clk(clk),
.data(lut_readValue)
);

//port assignments
assign AF_NI_valid=registered_valid&(registered_type==DATA)?1'b1:1'b0;
assign AF_NI_packet={registered_type, registered_seqNum,destAddress,sourceAddress,payload};


//lut port assignments
assign lut_readEnable=!hlt;
assign lut_readAddress=$signed(ACC_AF_data)-$signed(LOWER_BOUND);

//internal assignments
assign payload=$signed(registered_data)>$signed(UPPER_BOUND)?UB_VALUE:(($signed(registered_data)<$signed(LOWER_BOUND))?LB_VALUE:lut_readValue);
assign sourceAddress=SOURCE_ADDRESS;
assign destAddress=DEST_ADDRESS;


always @(posedge clk)
begin
    if(rst)
    begin
        registered_type<=0;
        registered_seqNum<=0; 	
        registered_data<=0;
        registered_valid<=0;
    end
    else if(!hlt)
    begin
        registered_type<=ACC_AF_type;
        registered_seqNum<=ACC_AF_seqNum;
        registered_data<=ACC_AF_data;
        registered_valid<=ACC_AF_valid;
    end
end


endmodule

