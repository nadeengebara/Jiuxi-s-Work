module pri_sel_comb_tb();
parameter N = 4;
parameter P = 16;
// reg clk;
// reg reset;
reg [$clog2(P)-1:0] in[0:N-1];
wire [$clog2(P)-1:0] out;
wire [N-1:0] req_out;
int seed;

pri_sel_comb #(.N(N)) p (.*);

initial	begin
	for (int i = 0; i < N; i++) begin

		in[i] = '0;	
	end

	forever begin
		#100
		for (int j = 0; j < 4; j++) begin
			seed = {$random} % 16;
			in[j] = seed;
		end
	end
end
endmodule // pri_sel_tb