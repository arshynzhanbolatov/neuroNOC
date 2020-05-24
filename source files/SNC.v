//////////////////////////////////////////////////////////////////////////////////
// Company: Nazarbayev University
// Engineer: Arshyn Zhanbolatov
// 
// Create Date: 09.08.2018 
// Design Name: SNC
// Module Name: seqNumCheck
// Project Name: NeuroNoc
// Target Devices: 
// Tool Versions: 
// Description: 
//////////////////////////////////////////////////////////////////////////////////

module seqNumCheck(clk, rst, hlt, NI_SNC_valid, NI_SNC_packet, SNC_MUL_valid, SNC_MUL_type, SNC_MUL_seqNum, SNC_MUL_sourceAddress, SNC_MUL_data);
`include "header.vh"


input clk;
input rst;
input hlt;
input NI_SNC_valid;
input [PACKET_SIZE-1:0] NI_SNC_packet;
output SNC_MUL_valid;
output [TYPE_WIDTH-1:0] SNC_MUL_type;
output [SEQ_WIDTH-1:0] SNC_MUL_seqNum;
output [SOURCE_WIDTH-1:0] SNC_MUL_sourceAddress;
output [PAYLOAD_WIDTH-1:0] SNC_MUL_data;

 
reg [SEQ_WIDTH-1:0] currentSeqNum;
reg [$clog2(NETWORK_SIZE)-1:0] counter[2**SEQ_WIDTH-1:0], currentCounter;
reg [$clog2(NETWORK_SIZE)-1:0] inputNum;   
   
wire isNextSeqNum;
wire [SEQ_WIDTH-1:0] newSeqNum;
wire [$clog2(NETWORK_SIZE)-1:0] newCounter;
wire [$clog2(NETWORK_SIZE)-1:0] newInputNum;

wire  hashTable_writeEnable, hashTable_readEnable;
wire  [SEQ_WIDTH+$clog2(NETWORK_SIZE)-1:0] hashTable_readIndex, hashTable_writeIndex;
wire  [PACKET_SIZE-1:0] hashTable_readValue, hashTable_writeValue;



//port assingments 
assign SNC_MUL_valid=currentCounter==counter[currentSeqNum]?1'b0:1'b1;
assign SNC_MUL_type=hashTable_readValue[TYPE_START+:TYPE_WIDTH];
assign SNC_MUL_seqNum=hashTable_readValue[SEQ_START+:SEQ_WIDTH];
assign SNC_MUL_sourceAddress=hashTable_readValue[TYPE_START+:TYPE_WIDTH]==DATA&hashTable_readValue[SOURCE_START+:SOURCE_WIDTH]==0?hashTable_readValue[DEST_START+:DEST_WIDTH]:hashTable_readValue[SOURCE_START+:SOURCE_WIDTH];
assign SNC_MUL_data=hashTable_readValue[0+:PAYLOAD_WIDTH];


//hash table assignemnts
assign hashTable_writeEnable=NI_SNC_valid;
assign hashTable_readEnable=(!hlt&SNC_MUL_valid)|rst;
assign hashTable_writeIndex=hashFunction(NI_SNC_packet[SEQ_START+:SEQ_WIDTH], counter[NI_SNC_packet[SEQ_START+:SEQ_WIDTH]]);
assign hashTable_readIndex=rst?0:hashFunction(newSeqNum, newCounter);
assign hashTable_writeValue=NI_SNC_packet;


//internal assignemnts
assign isNextSeqNum=currentCounter==inputNum|hashTable_readValue[TYPE_START+:TYPE_WIDTH]==CONF_INB?1'b1:1'b0;
assign newCounter=isNextSeqNum?0:currentCounter+1;
assign newSeqNum=isNextSeqNum?(currentSeqNum+1):currentSeqNum;
assign newInputNum=hashTable_readValue[SOURCE_START+:SOURCE_WIDTH];

blockedRAM_simpleDualPort #(.BRAM_DEPTH(NETWORK_SIZE*(2**SEQ_WIDTH)), .BRAM_WIDTH(PACKET_SIZE)) 
hashTable(
.clk(clk),
.we(hashTable_writeEnable), .re(hashTable_readEnable),
.addrin(hashTable_writeIndex),
.addrout(hashTable_readIndex),
.din(hashTable_writeValue),
.dout(hashTable_readValue)
); 


always @(posedge clk) 
begin: block0
    integer i;
    if(rst)
    begin
        for(i=0;i<2**SEQ_WIDTH;i=i+1)
            counter[i]=0;
    end  
    else 
    begin
        if(NI_SNC_valid)
             counter[NI_SNC_packet[SEQ_START+:SEQ_WIDTH]]<=counter[NI_SNC_packet[SEQ_START+:SEQ_WIDTH]]+1;
        if(!NI_SNC_valid|currentSeqNum!=NI_SNC_packet[SEQ_START+:SEQ_WIDTH]) //To avoid multiple drivers
             if(isNextSeqNum&SNC_MUL_valid&!hlt)
                counter[currentSeqNum]<=0;
    end
end


always @(posedge clk)
begin: block1
    if(rst)
    begin
        currentCounter<=0;
        currentSeqNum<=0;
        inputNum<=0;
    end
    else if(!hlt&SNC_MUL_valid) 
    begin
         currentCounter<=newCounter;
         currentSeqNum<=newSeqNum;
         if(SNC_MUL_type==CONF_INB)
            inputNum<=newInputNum;
    end            
end

 
endmodule
