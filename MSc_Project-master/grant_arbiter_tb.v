module grant_arbiter_tb();

reg clk, reset;
reg [3:0] req;
reg update_en;
reg en;
wire [3:0] gnt;

grant_arbiter #(.N(4)) gb (.*);

initial begin
	clk = 0;
	reset = 1;
	repeat(11) #10 clk = ~clk;
	reset = 0;
	forever #10 clk = ~clk;
end

initial begin
	update_en = 1;
	en = 1;
	req = 4'b0000;
	repeat(32) #10 req = req + 1;
end 
endmodule // grant_arbiter_tb