module arbiter_tb();

reg clk, reset;
reg [3:0] req;
reg update_en;
reg en;
wire [3:0] gnt;
wire any_gnt;

arbiter #(.N(4)) gb (.*);

initial begin
	clk = 0;
	reset = 0;
	repeat(11) #10 clk = ~clk;
	reset = 1;
	forever #10 clk = ~clk;
end

initial begin
	update_en = 1;
	en = 1;
	req = 4'b0000;
	repeat(32) #10 req = req + 1;
end 
endmodule // arbiter_tb