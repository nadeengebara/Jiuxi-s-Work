module pri_sel_tb();
parameter N = 4;

reg clk;
reg reset;
reg [N-1:0][N-1:0] in;
wire [N-1:0][N-1:0]out;

pri_sel #(.N(4), .P(8)) p (.*);

initial	begin 
	clk = 0;
	reset = 0;
	repeat(11) #10 clk = ~clk;
	reset = 1;
	forever #10 clk = ~clk;
end

initial	begin
	in = '0;
	#110
	in[0] = 4'b1111;
	in[1] = 4'b1110;
	in[2] = 4'b1110;
	in[3] = 4'b1110;
	#400
	in = '0;
end
endmodule // pri_sel_tb