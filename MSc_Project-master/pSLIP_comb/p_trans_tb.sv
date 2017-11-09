module p_trans_tb();

parameter N = 8;

reg [N-1:0] in;
wire [N-1:0] out;
int seed;

p_trans #(.N(8)) p (.*);

initial begin
	for (int i = 0; i < N; i++) begin
		in = 0;
	end

	forever begin
		#100
		for (int i = 0; i < N; i++) begin
			seed = {$random} % (2**N);
			in = seed;
		end
	end // forever
end // initial
endmodule // p_trans_tb