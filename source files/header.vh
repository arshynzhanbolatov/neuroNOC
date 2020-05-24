localparam X_SIZE = 16;
localparam Y_SIZE = 16;
//packet format
localparam NETWORK_SIZE=X_SIZE*Y_SIZE;

localparam PAYLOAD_WIDTH=10,SOURCE_START=PAYLOAD_WIDTH, SOURCE_WIDTH=clog2(NETWORK_SIZE),
DEST_START=SOURCE_START+SOURCE_WIDTH, DEST_WIDTH=clog2(NETWORK_SIZE), SEQ_START=DEST_START+DEST_WIDTH,SEQ_WIDTH=5,
TYPE_START=SEQ_START+SEQ_WIDTH, TYPE_WIDTH=2,PACKET_SIZE=TYPE_START+TYPE_WIDTH;

//Forwarding table packet
localparam DATA_START = 0,DATA_WIDTH=5,OPTIONAL_START=DATA_WIDTH, 
ENTRYNUMBER_WIDTH=clog2(NETWORK_SIZE),
SWITCHNUMBER_WIDTH=clog2(NETWORK_SIZE) ,
OPTIONAL_WIDTH=PACKET_SIZE-DATA_WIDTH-ENTRYNUMBER_WIDTH-SWITCHNUMBER_WIDTH-TYPE_WIDTH,
SWITCHNUMBER_START=ENTRYNUMBER_START+ENTRYNUMBER_WIDTH,
ENTRYNUMBER_START=OPTIONAL_START+OPTIONAL_WIDTH;

//packet type
localparam DATA=2'b00, CONF_INB=2'b01, CONF_W=2'b10, CONF_FT=2'b11;

//activation function 
localparam FD_0=0.25, F_MAX=1, F_MIN=0;

//number representation
localparam INPUT_WIDTH=PAYLOAD_WIDTH, IFRACTION=8, IINT=INPUT_WIDTH-IFRACTION, WEIGHT_WIDTH=PAYLOAD_WIDTH, 
WFRACTION=8, WINT=WEIGHT_WIDTH-WFRACTION, BIAS_WIDTH=PAYLOAD_WIDTH, BFRACTION=8, BINT=BIAS_WIDTH-BFRACTION,
PRODUCT_WIDTH=clog2((2**(WEIGHT_WIDTH-1)-1)*2**(INPUT_WIDTH-2))+1,
SUM_WIDTH=clog2(NETWORK_SIZE*(2**WEIGHT_WIDTH-1)*(2**(INPUT_WIDTH-2))+2**(BIAS_WIDTH-1)*2**(IFRACTION+WFRACTION-BFRACTION))+1, 
SFRACTION=IFRACTION+WFRACTION, SINT=SUM_WIDTH-SFRACTION, SSUM_WIDTH=clog2(FD_0/c(1, INPUT_WIDTH, IFRACTION, IINT))+SINT, 
SSFRACTION=clog2(FD_0/c(1, INPUT_WIDTH, IFRACTION, IINT))>0?clog2(FD_0/c(1, INPUT_WIDTH, IFRACTION, IINT)):0, 
SSINT=clog2(FD_0/c(1, INPUT_WIDTH, IFRACTION, IINT))>0?SINT:SSUM_WIDTH;

//lut
localparam [SSUM_WIDTH-1:0] UPPER_BOUND=355, LOWER_BOUND=-UPPER_BOUND;
localparam UB_VALUE=d(F_MAX,INPUT_WIDTH,IFRACTION,IINT), LB_VALUE=d(F_MIN,INPUT_WIDTH,IFRACTION,IINT), LUTADDRESS_WIDTH=10;

function automatic [SEQ_WIDTH+clog2(NETWORK_SIZE)-1:0] hashFunction(input [SEQ_WIDTH-1:0] key1, input [clog2(NETWORK_SIZE)-1:0] key2);
    begin
        hashFunction={key1,key2};
    end
endfunction  

//functions
function automatic real c(input real x, input real xwidth, input real xfraction, input real xint);
	begin
		c=x*(2.0**(xint-1)-2.0**(-xfraction))/(2.0**(xwidth-1)-1);
	end
endfunction


function  automatic integer d(input real x, input real xwidth, input real xfraction, input real xint);
	begin
		d=x*(2.0**(xwidth-1)-1)/(2.0**(xint-1)-2.0**(-xfraction));
	end
endfunction

function integer max(input integer x, input integer y);
	begin
		max=x>y?x:y;
	end
endfunction

function integer clog2;
input integer value;
begin
value = value-1;
for (clog2=0; value>0; clog2=clog2+1)
value = value>>1;
end
endfunction
