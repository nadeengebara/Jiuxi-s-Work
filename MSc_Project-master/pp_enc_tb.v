module pp_enc_tb();
	reg [1:0] in;
	reg [3:0] req;
	wire [3:0] gnt;
	wire any_gnt;

pp_enc #(.N(4)) test (.*);

initial begin
	in = 0;
	req = 4'b0000;
	repeat(16) #10 req = req + 1;
	#20
	in = 1;
	req = 4'b0000;
	repeat(16) #10 req = req + 1;
	#20
	in = 2;
	req = 4'b0000;
	repeat(16) #10 req = req + 1;
	#20
	in = 3;
	req = 4'b0000;
	repeat(16) #10 req = req + 1;
end
endmodule