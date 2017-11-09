module pri_scheduler(
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
input wire [C-1:0] pri_req_in[0:N-1][0:N-1];
output reg [N-1:0][N-1:0] decision;
output reg decision_ready;
//wire [$clog2(P)-1:0] masked_req_in[0:N-1][0:N-1];
//wire [N-1:0][N-1:0] mid;
wire [C-1:0] pri_mid[0:N-1][0:N-1];
wire [N-1:0][N-1:0] c; //use to group output port identification
wire [N-1:0][N-1:0] b;
wire [N-1:0] acc_gnt[0:N-1];
wire [N-1:0] anyacc;
wire [N-1:0] anygnt;
wire [N-1:0] acc_update_en;
wire [N-1:0] gnt_update_en;
wire [N-1:0] gnt_en;
wire [N-1:0] acc_en;
wire [C-1:0] group[0:N-1][0:N-1];
//	update and ready signal for gnt and acc arbiter
//wire [N-1:0] gnt_update;
wire [N-1:0] gnt_ready;
wire [N-1:0] acc_ready;
//reg mask;
reg first_iteration;
//the req_reg will not be treated as register until another always_ff is added
reg [C-1:0] req_reg[0:N-1][0:N-1];
reg [N-1:0][N-1:0] decision_next;
reg [N-1:0] delayed_ready1;
//reg [N-1:0] delayed_ready2;
reg init;


genvar i, j;
// maybe masked input is not necessary, think again.
// can assign request as zero in reset stage
generate
	for(i=0; i<N; i++) begin: gen_lv1i
		for (j = 0; j < N; j++) begin
			assign req_reg[i][j] = pri_req_in[i][j] & {C{gnt_en[j]}};
		end
			//assign masked_req_in[i] = ~{N{mask}} & req_reg[i];
	end
endgenerate

//grant arbiter
generate
for(i=0; i<N; i++) begin: gen_i
	pri_arbiter #(.N(N), .P(P)) pri_grant_arbiter(
	.pri_req(req_reg[i]),
	.sel_update(delayed_ready1[i] | init), //selector input update
	//.gnt(),
	.clk(clk),
	.reset(reset),
	.en(gnt_en[i]), 
	.update_en(gnt_update_en[i]),// ptr update enable
	.any_gnt(anygnt[i]),
	.pri_out(pri_mid[i]),
	.sel_ready(gnt_ready[i])
	);
	for(j=0; j<N; j++) begin: gen_j
		assign c[i][j] = decision[j][i];
		assign b[i][j] = decision_next[j][i];
	end
assign gnt_en[i] = ~(|c[i]) | first_iteration | init;
assign gnt_update_en[i] = (|b[i]) & first_iteration;
end
endgenerate

//accept arbiter
generate
for(i=0; i<N; i++) begin: gen_j
	pri_arbiter #(.N(N), .P(P)) pri_accept_arbiter (
	// '{a,a,a,a} declare a unpacked array
	//	can also declare another signal to assign in a loop
	/*'{pri_mid[0][i], pri_mid[1][i], pri_mid[2][i], pri_mid[3][i]}*/
	.pri_req(group[i]), //USE TO BE 3 2 1 0
	.sel_update(gnt_ready[i]),
	.clk(clk),
	.reset(reset),
	.en(acc_en[i]), 
	.update_en(acc_update_en[i]),
	.gnt(acc_gnt[i]),
	.any_gnt(anyacc[i]),
	.sel_ready(acc_ready[i])
	//.pri_out()
	);
	assign acc_en[i] = ~(|decision[i]) | first_iteration | init;
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
// typedef enum int unsigned{IDLE, I1, I2, I3, I4, I5, I6, I7, I8,
// I9, I10, I11, I12, I13, I14, I15, I16, I17, I18, I19, I20, I21, I22, I23, I24,
// I25, I26, I27, I28, I29, I30, I31, I32} state_t;
// state_t state, next;



//state machine begin
always_ff @(posedge clk) begin // synchronised nreset
	if(!reset) begin
		//mask <= 1;
		state <= IDLE;
			for(int i=0; i<N; i++) begin: gen_assign1
				decision[i] <= '0;
			end
	end
	else begin
		//mask <= 0;
		state <= next;
			for(int i=0; i<N; i++) begin: gen_assign2
				if(acc_ready) begin
				decision[i] <= decision_next[i];
				end
				// if(state == IDLE)
				// 	decision[i] <= '0;
			end
	end
end

always_ff @(posedge clk or negedge reset) begin : proc_delayed_ready
	if(~reset) 
		delayed_ready1 <= 0;
	else 
		delayed_ready1 <= acc_ready;
end

generate
	for(i=0; i<N; i++) begin: gen_out
		assign decision_next[i] = (first_iteration) ? (acc_gnt[i] & {N{acc_ready[i]}}) : ((decision[i] | acc_gnt[i])& {N{acc_ready[i]}});
	end
endgenerate

// always_comb begin
// 	next = state;
// 	decision_ready = 0;
// 	first_iteration = '0;
// 	init = 0;
//use unique reverse case statement to implement one hot state machine
//note that nowadays compiliers are able to choose one hot with enum state type, which means
//this coding style is not necessary
// 	case (state)
// 		IDLE: begin
// 			if(start) begin
// 				next = I1;
// 				decision_ready = 1;
// 				init = 1;
// 				end
// 			else
// 				next = IDLE;
// 		end
// 		I1: begin
			
// 			if(delayed_ready1[1]) 
// 				next = I2;
// 			else begin
// 				next = I1;
// 				first_iteration = '1;
// 			end
// 		end
// 		I2: begin
// 				if(delayed_ready1[1])
// 					next = I3;
// 				else
// 					next = I2;
// 		end
// 		I3: begin
// 				if(delayed_ready1[1])
// 					next = I4;
// 				else
// 					next = I3;
// 		end
// 		I4: begin
// 			if(delayed_ready1[1])
// 					next = I5;
// 				else
// 					next = I4;
// 		end
// 		I5: begin
// 				if(delayed_ready1[1])
// 					next = I6;
// 				else
// 					next = I5;
// 		end
// 		I6: begin
// 				if(delayed_ready1[1])
// 					next = I7;
// 				else
// 					next = I6;
// 		end
// 		I7: begin
// 				if(delayed_ready1[1])
// 					next = I8;
// 				else
// 					next = I7;
// 		end
// 		I8: begin
// 				if(delayed_ready1[1])
// 					next = I9;
// 				else
// 					next = I8;
// 		end
// 		I9: begin
// 				if(delayed_ready1[1])
// 					next = I10;
// 				else
// 					next = I9;
// 		end
// 		I10: begin
// 			if(delayed_ready1[1])
// 					next = I11;
// 				else
// 					next = I10;
// 		end
// 		I11: begin
// 				if(delayed_ready1[1])
// 					next = I12;
// 				else
// 					next = I11;
// 		end
// 		I12: begin
// 				if(delayed_ready1[1])
// 					next = I13;
// 				else
// 					next = I12;
// 		end
// 		I13: begin
// 				if(delayed_ready1[1])
// 					next = I14;
// 				else
// 					next = I13;
// 		end
// 		I13: begin
// 				if(delayed_ready1[1])
// 					next = I14;
// 				else
// 					next = I13;
// 		end
// 		I14: begin
// 				if(delayed_ready1[1])
// 					next = I15;
// 				else
// 					next = I14;
// 		end
// 		I15: begin
// 				if(delayed_ready1[1])
// 					next = I16;
// 				else
// 					next = I15;
// 		end
// 		I16: begin
// 				if(delayed_ready1[1])
// 					next = I17;
// 				else
// 					next = I16;
// 		end
// 		I17: begin
// 				if(delayed_ready1[1])
// 					next = I18;
// 				else
// 					next = I17;
// 		end
// 		I18: begin
// 			if(delayed_ready1[1])
// 					next = I19;
// 				else
// 					next = I18;
// 		end
// 		I19: begin
// 				if(delayed_ready1[1])
// 					next = I20;
// 				else
// 					next = I19;
// 		end
// 		I20: begin
// 				if(delayed_ready1[1])
// 					next = I21;
// 				else
// 					next = I20;
// 		end
// 		I21: begin
// 				if(delayed_ready1[1])
// 					next = I22;
// 				else
// 					next = I21;
// 		end
// 		I22: begin
// 				if(delayed_ready1[1])
// 					next = I23;
// 				else
// 					next = I22;
// 		end
// 		I23: begin
// 				if(delayed_ready1[1])
// 					next = I24;
// 				else
// 					next = I23;
// 		end
// 		I24: begin
// 			if(delayed_ready1[1])
// 					next = I25;
// 				else
// 					next = I24;
// 		end
// 		I25: begin
// 				if(delayed_ready1[1])
// 					next = I26;
// 				else
// 					next = I25;
// 		end
// 		I26: begin
// 				if(delayed_ready1[1])
// 					next = I27;
// 				else
// 					next = I26;
// 		end
// 		I27: begin
// 				if(delayed_ready1[1])
// 					next = I28;
// 				else
// 					next = I27;
// 		end
// 		I28: begin
// 				if(delayed_ready1[1])
// 					next = I29;
// 				else
// 					next = I28;
// 		end
// 		I29: begin
// 				if(delayed_ready1[1])
// 					next = I30;
// 				else
// 					next = I29;
// 		end
// 		I30: begin
// 				if(delayed_ready1[1])
// 					next = I31;
// 				else
// 					next = I30;
// 		end
// 		I31: begin
// 				if(delayed_ready1[1])
// 					next = I32;
// 				else
// 					next = I31;
// 		end				
// 		I32: begin
// 			if(acc_ready[1])
// 					next = IDLE;
// 				else
// 					next = I32;
// 		end
// 	endcase
// end
//  FSM end

endmodule // scheduler