module pri_scheduler_comb(
	clk,
	reset,
	start,
//	req_in,
	pri_req_in,
	decision,
	decision_ready
);
// `ifdef
// `else 
parameter N = 4;
parameter P = 16;
parameter C = $clog2(P);
input wire clk, reset, start;
//input wire [N-1:0][N-1:0] req_in;
input wire [$clog2(P)-1:0] pri_req_in[0:N-1][0:N-1];
output reg [N-1:0][N-1:0] decision;
output reg decision_ready;
//wire [$clog2(P)-1:0] masked_req_in[0:N-1][0:N-1];
//wire [N-1:0][N-1:0] mid;
wire [$clog2(P)-1:0] pri_mid[0:N-1][0:N-1];
wire [N-1:0][N-1:0] c; //use to group output port identification
wire [N-1:0][N-1:0] b;
wire [N-1:0] acc_gnt[0:N-1];
wire [N-1:0] anyacc;
wire [N-1:0] anygnt;
wire [N-1:0] acc_update_en;
wire [N-1:0] gnt_update_en;
wire [N-1:0] gnt_en;
wire [N-1:0] acc_en;
wire [$clog2(P)-1:0] group[0:N-1][0:N-1];
//	update and ready signal for gnt and acc arbiter
//wire [N-1:0] gnt_update;
//reg mask;
reg first_iteration;
//the req_reg will not be treated as register until another always_ff is added
reg [$clog2(P)-1:0] req_reg[0:N-1][0:N-1];
reg [N-1:0][N-1:0] decision_next;

genvar i, j;
// maybe masked input is not necessary, think again.
// can assign request as zero in reset stage
generate
	for(i=0; i<N; i++) begin: gen_lv1i
		for (j = 0; j < N; j++) begin
			assign req_reg[i][j] = pri_req_in[i][j] & {C{gnt_en[j]}};
		end
	end
endgenerate

//grant arbiter
generate
for(i=0; i<N; i++) begin: gen_i
	pri_arbiter_comb #(.N(N), .P(P)) pri_grant_arbiter (
	.pri_req(req_reg[i]),
	//.gnt(),
	.clk(clk),
	.reset(reset),
	.en(gnt_en[i]), 
	.update_en(gnt_update_en[i]),// ptr update enable
	.any_gnt(anygnt[i]),
	.pri_out(pri_mid[i])
	);
	for(j=0; j<N; j++) begin: gen_j
		assign c[i][j] = decision[j][i];
		assign b[i][j] = decision_next[j][i];
	end
assign gnt_en[i] = ~(|c[i]) | first_iteration;
assign gnt_update_en[i] = (|b[i]) & first_iteration;
end
endgenerate

//accept arbiter
generate
for(i=0; i<N; i++) begin: gen_j
	pri_arbiter_comb #(.N(N), .P(P)) pri_accept_arbiter (
	.pri_req(group[i]), //USE TO BE 3 2 1 0
	.clk(clk),
	.reset(reset),
	.en(acc_en[i]), 
	.update_en(acc_update_en[i]),
	.gnt(acc_gnt[i]),
	.any_gnt(anyacc[i])
	);
	assign acc_en[i] = ~(|decision[i]) | first_iteration;
	assign acc_update_en[i] = (|decision_next[i]) & first_iteration;// can i use anyacc?
end
endgenerate

generate
	for (i = 0; i < N; i++) begin
		for (j = 0; j < N; j++) begin
			assign group[i][j] = pri_mid[j][i];
		end
	end
endgenerate

`include "file4.txt"

//	FSM
// typedef enum int unsigned{IDLE, I1, I2, I3, I4, I5, I6, I7, I8, I9, I10, I11, I12, I13, I14, I15, I16,
// I17, I18, I19, I20, I21, I22, I23, I24, I25, I26, I27, I28, I29, I30, I31, I32} state_t;
// state_t state, next;

//state machine begin
always_ff @(posedge clk) begin // synchronised nreset
	if(!reset) begin
		state <= IDLE;
			for(int i=0; i<N; i++) begin: gen_assign1
				decision[i] <= '0;
			end
	end
	else begin
		state <= next;
			for(int i=0; i<N; i++) begin: gen_assign2
				decision[i] <= decision_next[i];
			end
	end
end

generate
	for(i=0; i<N; i++) begin: gen_out
		assign decision_next[i] = (first_iteration) ? acc_gnt[i] : (decision[i] | acc_gnt[i]);
	end
endgenerate

// always_comb begin
// 	next = state;
// 	decision_ready = 0;
// 	first_iteration = '0;
// //use unique reverse case statement to implement one hot state machine
// //note that nowadays compiliers are able to choose one hot with enum state type, which means
// //this coding style is not necessary
// 	case (state)
// 		IDLE: begin
// 			if(start) begin
// 				next = I1;
// 				end
// 			else
// 				next = IDLE;
// 			decision_ready = 1;
// 		end
// 		I1: begin
// 				next = I2;
// 				first_iteration = '1;
// 		end
// 		I2:		next = I3;
// 		I3:		next = I4;
// 		I4: 	next = I5;
// 		I5: 	next = I6;
// 		I6: 	next = I7;
// 		I7: 	next = I8;
// 		I8: 	next = I9;
// 		I9: 	next = I10;
// 		I10:	next = I11;
// 		I11:	next = I12;
// 		I12: 	next = I13;
// 		I13: 	next = I14;
// 		I14: 	next = I15;
// 		I15: 	next = I16;
// 		I16: 	next = I17;
// 		I17: 	next = I18;
// 		I18: 	next = I19;
// 		I19: 	next = I20;
// 		I20: 	next = I21;
// 		I21: 	next = I22;
// 		I22:	next = I23;
// 		I23:	next = I24;
// 		I24:	next = I25;
// 		I25: 	next = I26;				
// 		I26:	next = I27;
// 		I27: 	next = I28;
// 		I28: 	next = I29;
// 		I29:	next = I30;
// 		I30: 	next = I31;
// 		I31: 	next = I32;									
// 		I32:	next = IDLE;
// 	endcase
// end
//  FSM end

endmodule // scheduler