module analyser(
	clk,
	reset,
	in,
	req_out,
	data_out,
	en
	);
parameter N = 4;
input wire clk;
input wire reset;
input wire en;
input wire [23:0] in;
output wire [7:0] req_out;
output wire [7:0] data_out;
reg [7:0] data;
reg [7:0] ssap; //source addr
reg [7:0] dsap;	//destination addr
reg [3:0] cnt;
reg [3:0] cnt_next;
//reg [N-1:0] size;
always_comb begin
	if(en) begin
		assign {dsap, ssap, data} = in;
	end
end

always_comb begin
	case (dsap[1:0])
		0: req_out = 4'b0001;
		1: req_out = 4'b0010;
		2: req_out = 4'b0100;
		3: req_out = 4'b1000;
	endcase
end

typedef enum {
	IDLE = 0,
	TRANS = 1,
};
//	This part can be used later for enabling size control
// always_ff @(posedge clk) begin
// 	if(!reset) begin
// 		cnt <= 0;
// 	end // if(!reset)
// 	else begin
// 		cnt <= cnt_next;
// 	end
// end

// always_comb begin
// 	cnt_next = cnt - 1;
// 	if(cnt == 0) begin
// 		cnt_next = size;
// 	end
// end
always_comb begin
	unique case (1'b1)
		state[IDLE]: begin
			next[TRANS] = 1'b1;
		end // state[IDLE]:

endmodule // analyser