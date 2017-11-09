module pp_enc(
	in,
	req,
	gnt,
	any_gnt
	);
//parameter can be redefined in higher level
//localparam protect the parameter and is not redefine-able
parameter N = 4;

input wire [$clog2(N)-1:0] in;
input wire [N-1:0] req;
output wire [N-1:0] gnt;
output wire any_gnt;
wire any_thermal_gnt;

wire [N-1:0] mask_out;
wire [N-1:0] thermal_out;
//wire [N-1:0] pe_out;
wire [N-1:0] gnt_thermal;
wire [N-1:0] gnt_pe;

thermal_dec #(.N(N)) thermal(.in(in), .out(thermal_out));
p_trans #(.N(N))  thermal_enc(.in(mask_out), .out(gnt_thermal));
p_trans #(.N(N)) enc(.in(req), .out(gnt_pe));
assign mask_out = (~thermal_out) & req;
assign any_thermal_gnt = |gnt_thermal;
assign any_gnt = |gnt_pe;
assign gnt = (any_thermal_gnt) ? gnt_thermal : gnt_pe;

endmodule