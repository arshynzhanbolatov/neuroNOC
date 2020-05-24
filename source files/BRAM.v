module blockedRAM_simpleDualPort #(parameter BRAM_WIDTH=32, BRAM_DEPTH=256)(
input [BRAM_WIDTH-1:0] din,
input [$clog2(BRAM_DEPTH)-1:0] addrin,
input [$clog2(BRAM_DEPTH)-1:0] addrout,
input we, re, clk,
output [BRAM_WIDTH-1:0] dout 
);

reg [BRAM_WIDTH-1:0] mem[BRAM_DEPTH-1:0];
reg [$clog2(BRAM_DEPTH)-1:0] addrout_reg;


always @(posedge clk)
begin: block0
    if (we)
        mem[addrin]<= din;
    if (re)
        addrout_reg <= addrout;        
end

assign dout = mem[addrout_reg];
endmodule
    
