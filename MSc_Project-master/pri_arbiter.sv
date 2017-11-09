module pri_arbiter(
	//req,
	pri_req,
	sel_update,
	clk,
	reset,
	en, //	ppe block enable
	update_en,//	ppe update enable
	gnt,
	any_gnt,
	pri_out,
	sel_ready
	);
parameter N = 4;
parameter P = 16;
//input wire [N-1:0] req;
input wire [$clog2(P)-1:0] pri_req[0:N-1];
input wire sel_update;
input wire update_en;
input wire en;
input wire clk;
input wire reset;
output wire [N-1:0] gnt;
output wire any_gnt;
output wire [$clog2(P)-1:0] pri_out[0:N-1];
output wire sel_ready;

wire [N-1:0] grant;
wire any_grant;
reg [$clog2(N)-1:0] pri[0:P-1];//	P pointers for P priority levels
reg [$clog2(N)-1:0] pri_next[0:P-1];
reg [$clog2(N)-1:0] gnt_enc;

// extra wire for priority modification
wire [$clog2(P)-1:0] pri_sel_out[0:N-1];
wire [N-1:0] req_out;
wire [$clog2(P)-1:0] pri_max;
reg [$clog2(N)-1:0] p;
//reg [$clog2(N)-1:0] p_next;


//Additional priority select module
//READY MAYBE NEEDED SINCE RESULT IS ONLY VALID AFTER 4 CLK CYCLES
pri_sel psel(.in(pri_req), .update(sel_update), .req_out(req_out), .out(pri_sel_out), .ready(sel_ready), .*);
pp_enc ppe(.in(p), .req(req_out), .gnt(grant), .any_gnt(any_grant));

//assign pri = (any_gnt)? pri+1 : pri;//	priority update
always_comb begin
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

//priority output after priority encoder
genvar i;
generate
	for (i = 0; i < N; i++) begin
		assign pri_out[i] = {4{gnt[i]}} & pri_sel_out[i];
	end
endgenerate

assign pri_max = pri_sel_out[gnt_enc];

always_comb begin
	for (int j = 0; j < P; j++) begin
		pri_next[j] = '0; // default value to aviod latch
	end

	if (update_en & any_grant & en)
		pri_next[pri_max] = (1 + gnt_enc)%4;
	//pri = pri + 1; This is the so called combinational loop
	else
		pri_next = pri;
end

always @(posedge clk) begin
	if(!reset) begin
		for (int i = 0; i < P; i++) begin
			pri[i] <= '0; //assume the arbitration is done in a cycle
		end
		p <= 0;
	end
	else begin
		pri <= pri_next;
		p <= pri[pri_max];
	end
end

endmodule