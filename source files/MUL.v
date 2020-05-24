//////////////////////////////////////////////////////////////////////////////////
// Company: Nazarbayev University
// Engineer: Arshyn Zhanbolatov
// 
// Create Date: 09.08.2018 
// Design Name: MUL
// Module Name: multiplier
// Project Name: NeuroNoc
// Target Devices: 
// Tool Versions: 
// Description: 
//////////////////////////////////////////////////////////////////////////////////

module multiplier( clk,rst,hlt,SNC_MUL_valid,SNC_MUL_type,SNC_MUL_seqNum,SNC_MUL_sourceAddress,  SNC_MUL_data,MUL_ACC_valid,  MUL_ACC_type, MUL_ACC_seqNum, MUL_ACC_data);
`include "header.vh"

input clk;
input rst;
input hlt;
input SNC_MUL_valid;
input [TYPE_WIDTH-1:0] SNC_MUL_type;
input [SEQ_WIDTH-1:0] SNC_MUL_seqNum;
input [SOURCE_WIDTH-1:0] SNC_MUL_sourceAddress;
input [PAYLOAD_WIDTH-1:0] SNC_MUL_data;
output MUL_ACC_valid;
output [TYPE_WIDTH-1:0] MUL_ACC_type;
output [SEQ_WIDTH-1:0] MUL_ACC_seqNum;
output [max(PRODUCT_WIDTH,PAYLOAD_WIDTH+SOURCE_WIDTH)-1:0] MUL_ACC_data;


reg registered_valid;
reg [TYPE_WIDTH-1:0]  registered_type;
reg [SEQ_WIDTH-1:0] registered_seqNum;
reg [SOURCE_WIDTH-1:0] registered_sourceAddress;
reg [PAYLOAD_WIDTH-1:0] registered_data;


wire weightTable_writeEnable, weightTable_readEnable;
wire [SOURCE_WIDTH-1:0] weightTable_writeAddress, weightTable_readAddress;
wire [PAYLOAD_WIDTH-1:0] weightTable_writeData, weightTable_readData;
wire [PRODUCT_WIDTH-1:0] partialProduct;

blockedRAM_simpleDualPort #(.BRAM_WIDTH(PAYLOAD_WIDTH), .BRAM_DEPTH(NETWORK_SIZE)) weightTable(
.din(weightTable_writeData),
.addrin(weightTable_writeAddress),
.addrout(weightTable_readAddress),
.we(weightTable_writeEnable), .re(weightTable_readEnable), .clk(clk),
.dout(weightTable_readData)
);

//port assignments
assign MUL_ACC_valid=registered_valid;
assign MUL_ACC_type=registered_type;
assign MUL_ACC_seqNum=registered_seqNum;
assign MUL_ACC_data=(registered_type==DATA)?partialProduct:{registered_sourceAddress,registered_data};


//weight table assignments
assign weightTable_writeEnable=(registered_type==CONF_W)&registered_valid?1'b1:1'b0;
assign weightTable_writeAddress=registered_sourceAddress;
assign weightTable_writeData=registered_data;
assign weightTable_readEnable=hlt?1'b0:1'b1;
assign weightTable_readAddress=SNC_MUL_sourceAddress;


//internal assignments
assign partialProduct=$signed(weightTable_readData)*$signed(registered_data);


always @(posedge clk)
begin
    if(rst)
    begin
        registered_type<=0; 
        registered_seqNum<=0;
        registered_sourceAddress<=0;	
        registered_data<=0;
        registered_valid<=0;
    end
    else if(!hlt)
    begin
        registered_type<=SNC_MUL_type;
        registered_seqNum<=SNC_MUL_seqNum;
        registered_sourceAddress<=SNC_MUL_sourceAddress;
        registered_data<=SNC_MUL_data;
        registered_valid<=SNC_MUL_valid;
    end
end

endmodule
