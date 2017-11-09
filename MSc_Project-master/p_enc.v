// grant priority issue
module p_enc(
	in,
	out
	);
parameter N = 4;
input wire [N-1:0] in;
output reg [$clog2(N) - 1:0] out;
always @*
begin
case (in)
	4'b0001 : out = 0; 
	4'b0010 : out = 1;
	4'b0100 : out = 2;
	4'b1000 : out = 3;
	default: out = 'x;
endcase
end
endmodule // p_enc