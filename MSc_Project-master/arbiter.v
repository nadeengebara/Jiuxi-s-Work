module arbiter(
	req,
	gnt,
	clk,
	reset,
	en, //	block enable
	update_en,//	update enable
	any_gnt
	);
parameter N = 4;
input wire [N-1:0] req;
input wire update_en;
input wire en;
input wire clk;
input wire reset;
output wire [N-1:0] gnt;
output wire any_gnt;

wire [N-1:0] grant;
wire any_grant;
reg [$clog2(N)-1:0] pri;
reg [$clog2(N)-1:0] pri_next;
reg [$clog2(N)-1:0] gnt_enc;
//reg [$clog2(N)-1:0] grant_enc;
pp_enc ppe(.in(pri), .req(req), .gnt(grant), .any_gnt(any_grant));

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

assign gnt = (en) ? grant : '0;
assign any_gnt = (en) ? any_grant : 1'b0;

always @*
begin
	if (update_en & any_grant & en)
		pri_next = 1 + gnt_enc;
	//pri = pri + 1; This is the so called combinational loop
	else
		pri_next = pri;
end

always @(posedge clk) begin
	if(!reset)
		pri <= 0; //assume the arbitration is done in a cycle
	else 
		pri <= pri_next;
end

endmodule