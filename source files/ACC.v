//////////////////////////////////////////////////////////////////////////////////
// Company: Nazarbayev University
// Engineer: Arshyn Zhanbolatov
// 
// Create Date: 09.08.2018 
// Design Name: ACC
// Module Name: accumulator
// Project Name: NeuroNoc
// Target Devices: 
// Tool Versions: 
// Description: 
//////////////////////////////////////////////////////////////////////////////////

module accumulator(clk, rst, hlt, MUL_ACC_valid, MUL_ACC_type,  MUL_ACC_seqNum, MUL_ACC_data, ACC_AF_valid, ACC_AF_type,ACC_AF_seqNum, ACC_AF_data);
`include "header.vh"

input clk;
input rst;
input hlt;
input MUL_ACC_valid;
input [TYPE_WIDTH-1:0] MUL_ACC_type;
input [SEQ_WIDTH-1:0] MUL_ACC_seqNum;
input [max(PRODUCT_WIDTH,PAYLOAD_WIDTH+SOURCE_WIDTH)-1:0] MUL_ACC_data;
output ACC_AF_valid;
output [TYPE_WIDTH-1:0] ACC_AF_type;
output [SEQ_WIDTH-1:0] ACC_AF_seqNum;
output [SSUM_WIDTH-1:0] ACC_AF_data;


reg registered_valid;
reg [TYPE_WIDTH-1:0] registered_type;
reg [SEQ_WIDTH-1:0] registered_seqNum;
reg [max(PRODUCT_WIDTH,PAYLOAD_WIDTH+SOURCE_WIDTH)-1:0] registered_data;


reg [BIAS_WIDTH-1:0] bias;
reg [SUM_WIDTH-1:0] result;
reg [$clog2(NETWORK_SIZE)-1:0] inputNum, counter;

wire [SUM_WIDTH-1:0] summand[1:0], sum;
wire isNextSum;

//Port assignemnts
assign ACC_AF_valid=registered_valid&(isNextSum|registered_type!=DATA);
assign ACC_AF_type=registered_type;
assign ACC_AF_seqNum=registered_seqNum;
assign ACC_AF_data=sum[(SUM_WIDTH-1)-:SSUM_WIDTH];


//internal assignments
assign summand[0]=(counter==0)?$signed($signed(bias)*(2**(IFRACTION+WFRACTION-BFRACTION))):result;
assign summand[1]=$signed(registered_data[PRODUCT_WIDTH-1:0]);
assign sum=summand[0]+summand[1];
assign isNextSum=counter==inputNum?1'b1:1'b0;


always @(posedge clk)
begin
    if(rst)
    begin
        registered_data<=0;
        registered_seqNum<=0;
        registered_type<=0;
        registered_valid<=0;
    end
    else if(!hlt)
    begin
        registered_data<=MUL_ACC_data;
        registered_seqNum<=MUL_ACC_seqNum;
        registered_type<=MUL_ACC_type;
        registered_valid<=MUL_ACC_valid;
    end
end

always @(posedge clk)
begin
    if(rst)
    begin
        bias<=0;
        result<=0;
        inputNum<=0;
        counter<=0;
    end
    else if(registered_valid&!hlt)
    begin
        case(registered_type)
            DATA:
            begin
                if(isNextSum)
                    counter<=0;
                else
                begin
                    result<=sum;
                    counter<=counter+1; 
                end                
            end
            CONF_INB:
            begin
                 bias<=registered_data[0+:PAYLOAD_WIDTH];
                 inputNum<=registered_data[SOURCE_START+:SOURCE_WIDTH];
            end                
            
        endcase    
    end
end


endmodule
