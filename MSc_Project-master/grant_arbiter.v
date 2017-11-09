module grant_arbiter(
	req,
	gnt,
	clk,
	reset,
	en, //	block enable
	update_en//	update enable
	);
parameter N = 4;

input wire [N-1:0] req;
input wire update_en;
input wire en;
input wire clk;
input wire reset;
output wire [N-1:0] gnt;
wire any_gnt;

reg [$clog2(N)-1:0] pri;
reg [$clog2(N)-1:0] pri_next;
reg [$clog2(N)-1:0] gnt_enc;
//reg [$clog2(N)-1:0] grant_enc;
pp_enc ppe(.in(pri_next), .req(req), .gnt(gnt), .any_gnt(any_gnt));

//assign pri = (any_gnt)? pri+1 : pri;//	priority update
always @*
begin
case (gnt)
	4'b0001 : gnt_enc = 0; 
	4'b0010 : gnt_enc = 1;
	4'b0100 : gnt_enc = 2;
	4'b1000 : gnt_enc = 3;
	default : gnt_enc = 'x;
endcase
end

always @*
begin
	if (update_en & any_gnt & en)
		pri_next = pri + gnt_enc;
	//pri = pri + 1; This is the so called combinational loop
	else
		pri_next = pri;
end


always @ (posedge clk) begin
	if(!reset)
		pri <= 0; //assume the arbitration is done in a cycle
	else 
		pri <= pri_next; 
end 

endmodule