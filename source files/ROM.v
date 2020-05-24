module ROM #(parameter ROM_WIDTH=32, ROM_DEPTH=256)(
input [$clog2(ROM_DEPTH)-1:0] addr,
input en, clk,
output [ROM_WIDTH-1:0] data
);

reg [ROM_WIDTH-1:0] mem[ROM_DEPTH-1:0];
reg [$clog2(ROM_DEPTH)-1:0] addr_reg;

initial 
begin
    $readmemb("lut.bin", mem); 
end

always @(posedge clk)
begin
    if(en)
        addr_reg <= addr;
end

assign data = mem[addr_reg];

endmodule
    

