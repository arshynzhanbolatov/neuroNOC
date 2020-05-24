`timescale 1ns / 1ns

module testbench_neuronoc();
`include "header.vh"

reg clk, rst, input_valid, input_ready;
reg [PACKET_SIZE-1:0] input_packet;
wire [PACKET_SIZE-1:0] output_packet;
wire output_valid, output_ready;
integer i,j,u,k;
integer n = 3;
task sendpacket;
input [TYPE_WIDTH-1:0] packetType;
input [SEQ_WIDTH-1:0] seqNum;
input [DEST_WIDTH-1:0] destAddress;
input [SOURCE_WIDTH-1:0] sourceAddress;
input [PAYLOAD_WIDTH-1:0] payload;

begin: F

forever 
begin
@(posedge clk)
if(output_ready) begin
    input_valid<=1;
    input_packet <={packetType, seqNum, destAddress, sourceAddress,  payload};
	@(posedge clk)
    input_valid<=0;
    disable F;
end
end


end
endtask

task sendpacketFT;
input [TYPE_WIDTH-1:0] packetType;
input [SWITCHNUMBER_WIDTH-1:0] switchNumber;
input [ENTRYNUMBER_WIDTH-1:0] entryNumber;
input [OPTIONAL_WIDTH-1:0] optional;
input [DATA_WIDTH-1:0] data;

begin: FT

forever 
begin
@(posedge clk)
if(output_ready) begin
    input_valid<=1;
    input_packet <={packetType, switchNumber, entryNumber, optional,  data};
	@(posedge clk)
    input_valid<=0;
    disable FT;
end
input_valid<=0;
end

end
endtask

initial
begin
    clk=1;
    forever
        #5 clk=~clk;    
end

initial
begin
    rst<=1; 
    @(posedge clk)
    @(posedge clk)
     rst<=0;
end



initial
begin: block
    integer counter;
   	@(posedge clk) 
   	@(posedge clk) 
	//pwesn
    
	//CONFIGURE FORWARDIING TABLE
    
	
	//first row
	for(i = 0; i < 15; i = i + 1) 
	begin
		sendpacketFT(CONF_FT, i , 0, 0, 5'b00101);
		for(u = 208; u < 256; u = u + 1)
		begin 
			sendpacketFT(CONF_FT, i, u, 0, 5'b01000);	
		end
	end
	sendpacketFT(CONF_FT, 15 , 0, 0, 5'b00001);
	
	//next 6 rows
	for(j = 1; j < 6; j = j + 1)
	begin
		for(i = 16*j; i < j*16+16; i = i + 1) 
		begin
			sendpacketFT(CONF_FT, i , 0, 0, 5'b10001);
		end
	end
			
	
	for(i = 96; i < 112; i = i + 1)
	begin            
	   sendpacketFT(CONF_FT, i , 0, 0, 5'b10000);
    end
	
	// first layer
	//sources are first and last columns with 5 rows 1-6 LAYERS
	
	for(j = 1; j < 7; j = j + 1)
	begin
		sendpacketFT(CONF_FT, 16*j, j*16+15, 0, 5'b00001);
		sendpacketFT(CONF_FT, 16*j, j*16, 0, 5'b00101);
		sendpacketFT(CONF_FT, 16*j+15, j*16+15, 0, 5'b01001);
		sendpacketFT(CONF_FT, 16*j+15, j*16, 0, 5'b00001);
		for(i = 16*j+1; i < j*16+15; i = i + 1) 
		begin
			sendpacketFT(CONF_FT, i, j*16, 0, 5'b00101);
			sendpacketFT(CONF_FT, i, j*16+15, 0, 5'b01001);
		end		
		for(k = j+1; k < 7; k = k + 1)
		begin
			for(i = 16*k; i < k*16+16; i = i + 1)
			begin
				sendpacketFT(CONF_FT, i, j*16, 0, 5'b00001);
				sendpacketFT(CONF_FT, i, j*16 + 15, 0, 5'b00001);
			end
		end
		for(k = 7; k < 12; k = k + 1)
		begin
			for(i = 16*k; i < k*16+16; i = i + 1)
			begin
				sendpacketFT(CONF_FT, i, j*16, 0, 5'b10001);
				sendpacketFT(CONF_FT, i, j*16 + 15, 0, 5'b10001);
			end
		end
		for(i = 192; i < 208; i = i + 1)
		begin
			sendpacketFT(CONF_FT, i, j*16, 0, 5'b10000);
			sendpacketFT(CONF_FT, i, j*16 + 15, 0, 5'b10000);
		end
	end
	// source are all middle located switches
	for(j = 1; j < 7; j = j + 1)
	begin
		
		for(i = 16*j+1; i < j*16+15; i = i + 1) 
		begin
			sendpacketFT(CONF_FT, j*16, i, 0, 5'b00001);
			for(k = j*16+1; k < i; k = k + 1)
			begin
				sendpacketFT(CONF_FT, k, i, 0, 5'b01001);
			end
			sendpacketFT(CONF_FT, i, i, 0, 5 'b01101);
			for(k = i+1; k < j*16+15; k = k + 1)
			begin
				sendpacketFT(CONF_FT, k, i, 0, 5'b00101);
			end
			sendpacketFT(CONF_FT, k, i, 0, 5'b00001);
			for(k = j+1; k < 7; k = k + 1)
				for(u = 16*k; u < k*16+16; u = u + 1)
					sendpacketFT(CONF_FT, u, i, 0, 5'b00001);
			for(k = 7; k < 12; k = k + 1)
				for(u = 16*k; u < k*16+16; u = u + 1)
					sendpacketFT(CONF_FT, u, i, 0, 5'b10001);
			for(u = 192; u < 208; u = u + 1)
				sendpacketFT(CONF_FT, u, i, 0, 5'b10000);
		end		
	end	
	
	//second layer
	//sources are first and last columns with 5 rows 7-12 LAYERS
	
	for(j = 7; j < 13; j = j + 1)
	begin
		sendpacketFT(CONF_FT, 16*j, j*16+15, 0, 5'b00001);
		sendpacketFT(CONF_FT, 16*j, j*16, 0, 5'b00101);
		sendpacketFT(CONF_FT, 16*j+15, j*16+15, 0, 5'b01001);
		sendpacketFT(CONF_FT, 16*j+15, j*16, 0, 5'b00001);
		for(i = 16*j+1; i < j*16+15; i = i + 1) 
		begin
			sendpacketFT(CONF_FT, i, j*16, 0, 5'b00101);
			sendpacketFT(CONF_FT, i, j*16+15, 0, 5'b01001);
		end		
		for(k = j+1; k < 13; k = k + 1)
		begin
			for(i = 16*k; i < k*16+16; i = i + 1)
			begin
				sendpacketFT(CONF_FT, i, j*16, 0, 5'b00001);
				sendpacketFT(CONF_FT, i, j*16 + 15, 0, 5'b00001);
			end
		end
		for(k = 13; k < 15; k = k + 1)
		begin
			for(i = 16*k; i < k*16+16; i = i + 1)
			begin
				sendpacketFT(CONF_FT, i, j*16, 0, 5'b10001);
				sendpacketFT(CONF_FT, i, j*16 + 15, 0, 5'b10001);
			end
		end
		for(i = 240; i < 256; i = i + 1)
		begin
			sendpacketFT(CONF_FT, i, j*16, 0, 5'b10000);
			sendpacketFT(CONF_FT, i, j*16 + 15, 0, 5'b10000);
		end
	end
	// source are all middle located switches
	for(j = 7; j < 13; j = j + 1)
	begin
		for(i = 16*j+1; i < j*16+15; i = i + 1) 
		begin
			sendpacketFT(CONF_FT, j*16, i, 0, 5'b00001);
			for(k = j*16+1; k < i; k = k + 1)
			begin
				sendpacketFT(CONF_FT, k, i, 0, 5'b01001);
			end
			sendpacketFT(CONF_FT, i, i, 0, 5 'b01101);
			for(k = i+1; k < j*16+15; k = k + 1)
			begin
				sendpacketFT(CONF_FT, k, i, 0, 5'b00101);
			end
			sendpacketFT(CONF_FT, k, i, 0, 5'b00001);
			for(k = j+1; k < 13; k = k + 1)
				for(u = 16*k; u < k*16+16; u = u + 1)
					sendpacketFT(CONF_FT, u, i, 0, 5'b00001);
			for(k = 13; k < 15; k = k + 1)
				for(u = 16*k; u < k*16+16; u = u + 1)
					sendpacketFT(CONF_FT, u, i, 0, 5'b10001);
			for(u = 240; u < 256; u = u + 1)
				sendpacketFT(CONF_FT, u, i, 0, 5'b10000);
				
		end		
	end		
	
	
	
	//output layer
	
	for(j = 13; j < 16; j = j + 1)
	begin
		for(i = j*16; i < j*16+16; i = i + 1)
		begin
			sendpacketFT(CONF_FT, i, i, 0, 5'b00010);
			if(j < 15) 	sendpacketFT(CONF_FT, i, i+16, 0, 5'b00010);
			if(j < 14)	sendpacketFT(CONF_FT, i, i+32, 0, 5'b00010);
		end
	end
	
	for(j = 1; j < 13; j = j + 1)
	begin
		for(i = j*16; i < j*16+16; i = i + 1)
		begin
			sendpacketFT(CONF_FT, i, 208+(i%16), 0, 5'b00010);
			sendpacketFT(CONF_FT, i, 224+(i%16), 0, 5'b00010);
			sendpacketFT(CONF_FT, i, 240+(i%16), 0, 5'b00010);
		end
	end
	
	for(i = 0; i < 16; i = i + 1) 
	begin
		for(j = 13; j < 16; j = j + 1)
		begin
			for(k = j*16; k < j*16 + 16; k = k+1)
			begin
				if(i == 0)
					sendpacketFT(CONF_FT, i, k,  0, 5'b10000);
				else 
					sendpacketFT(CONF_FT, i, k,  0, 5'b01000);
				
			end
		end	
	end
	
	
    	//END
			
    	//CONFIGURE INPUT NUMBER and BIAS
    counter=0;
   
	for(j = 1; j < 7; j = j + 1)
	begin
		for(i = j*16; i < j*16+16; i = i + 1)
		begin
			sendpacket(CONF_INB, counter, i, 47, d(-1.3, BIAS_WIDTH, BFRACTION, BINT));	
		end
	end
	for(j = 7; j < 13; j = j + 1)
	begin
		for(i = j*16; i < j*16+16; i = i + 1)
		begin
			sendpacket(CONF_INB, counter, i, 95, d(-1.2, BIAS_WIDTH, BFRACTION, BINT));	
		end
	end
	for(j = 13; j < 16; j = j + 1)
	begin
		for(i = j*16; i < j*16+16; i = i + 1)
		begin
			sendpacket(CONF_INB, counter, i, 95, d(-1.2, BIAS_WIDTH, BFRACTION, BINT));	
		end
	end
    	//END
		//4
    
    	//CONFIGURE WEIGHTS
	counter=counter+1;
	
	for(j = 1; j < 7; j = j + 1)
	begin
		for(i = j*16; i < j*16+16; i = i + 1)
		begin
			for(k = 0; k < 48; k=k+1)
				sendpacket(CONF_W, counter, i, k, d((i+k)/100,WEIGHT_WIDTH, WFRACTION, WINT));
			for(k = 7; k < 13; k = k + 1)
            begin
				for(u = k*16; u < k*16+16; u = u + 1)
				begin
                    sendpacket(CONF_W, counter, u, i, d((i+u)/200,WEIGHT_WIDTH, WFRACTION, WINT));    
                end
            end   
		end
	end
	for(j = 7; j < 13; j = j + 1)
	begin
		for(i = j*16; i < j*16+16; i = i + 1)
		begin
			for(k = 13; k < 16; k = k + 1)
            begin
				for(u = k*16; u < k*16+16; u = u + 1)
				begin
                    sendpacket(CONF_W, counter, u, i, d((i+u)/200,WEIGHT_WIDTH, WFRACTION, WINT));    
                end
            end 
		end
	end
	
	//end
	
	//SEND INPUTS
	
	input_ready<=1;
	repeat(1)
	begin
	   counter=counter+1;
		for(k = 0; k < 48; k=k+1)
            sendpacket(DATA, counter, k, 0, d(1.5, INPUT_WIDTH, IFRACTION, IINT));
            
        
	end

	//END
	
end



neuroNoC nn(
.i_clk(clk), 
.i_rst(rst),

.i_nn_valid(input_valid), 
.o_nn_ready(output_ready), 
.i_nn_data(input_packet), 
 
.o_nn_valid(output_valid), 
.i_nn_ready(input_ready),
.o_nn_data(output_packet) 

);



endmodule

