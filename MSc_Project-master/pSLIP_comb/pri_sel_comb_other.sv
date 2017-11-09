module pri_sel_comb_other (
	in,
	out,
	req_out
	);
parameter N = 4;
parameter P = 4;
input wire [$clog2(P)-1:0] in[0:N-1];
output reg [$clog2(P)-1:0] out; //output should be OR of all the input vectors
output reg [N-1:0] req_out;

//reg [$clog2(P)-1:0] data_out[0:N-1]; //this is the real output;
reg temp0;
reg temp1;
reg temp2;
always_comb	begin

	temp0 = ~(in[0][1] | in[1][1] | in[2][1] | in[3][1]);
	temp1 = in[0][0] | in[1][0] | in[2][0] | in[3][0];		
	temp2 = (&(in[0]) | &(in[1]) | &(in[2]) | &(in[3]));
	out[1] = ~temp0;
	out[0] = temp2 | (temp1 & temp0);
end

always_comb begin
	for (int i = 0; i < N; i++) begin
		req_out[i] = (out == 0)? '0 : ~(|(out ^ in[i]));
	end
end

endmodule // pri_sel_comb