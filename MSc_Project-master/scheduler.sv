module scheduler (
	clk,
	reset,
	start,
	ready,
	req_in,
	decision
);
parameter N = 4;
input wire clk, reset, start;
input wire [N-1:0][N-1:0] req_in;
output reg [N-1:0][N-1:0] decision;
output reg ready;

// wire [N-1:0][N-1:0] masked_req_in;
wire [N-1:0][N-1:0] mid;
wire [N-1:0][N-1:0] group;
wire [N-1:0][N-1:0] c; //use to group output port identification
wire [N-1:0][N-1:0] b;
wire [N-1:0] acc_gnt [0:N-1];
wire [N-1:0] anyacc;
wire [N-1:0] anygnt;
wire [N-1:0] acc_update_en;
wire [N-1:0] gnt_update_en;
wire [N-1:0] gnt_en;
wire [N-1:0] acc_en;
//reg mask;
reg first_iteration;
reg [N-1:0][N-1:0]req_reg;
reg [N-1:0][N-1:0]decision_next;
//reg [N-1:0][N-1:0]decision;

genvar i, j;
// maybe masked input is not necessary, think again.
generate
	for(i=0; i<N; i++) begin: gen_lv1i  
		//for(j=0; j<N; i++) begin: gen_lv1j
			assign req_reg[i] = req_in[i] & gnt_en; 
			// assign masked_req_in[i] = ~{N{mask}} & req_reg[i];
		//end
	end
endgenerate

//grant arbiter
generate
for(i=0; i<N; i++) begin: gen_i
	arbiter #(.N(N)) grant_arbiter (
	.req(req_reg[i]),
	.gnt(mid[i]),
	.clk(clk),
	.reset(reset),
	.en(gnt_en[i]), 
	.update_en(gnt_update_en[i]),
	.any_gnt(anygnt[i])
	);
	for (j=0; j<N; j++) begin: gen_j
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
	arbiter #(.N(N)) accept_arbiter (
	.req(group[i]),
	.gnt(acc_gnt[i]),
	.clk(clk),
	.reset(reset),
	.en(acc_en[i]), 
	.update_en(acc_update_en[i]),
	.any_gnt(anyacc[i])
	);
	assign acc_en[i] = ~(|decision[i]) | first_iteration;
	assign acc_update_en[i] = (|decision_next[i]) & first_iteration;// can i use anyacc?
end
endgenerate

generate
	for (i = 0; i < N; i++) begin
		for (j = 0; j < N; j++) begin
			assign group[i][j] = mid[j][i];
		end
	end
endgenerate
//	FSM
// typedef enum{
// IDLE  = 0,
// I1 = 1,
// I2 = 2,
// I3 = 3,
// I4 = 4
// } state_index_t;

// reg [4:0] state, next;

// typedef enum int unsigned {IDLE, I1, I2, I3, I4} state_t;
// state_t state, next;

`include "file4.txt"
//state machine begin
always_ff @(posedge clk) begin // synchronised nreset
	if(!reset) begin
		// state <= '0; // default assignment
		//mask <= 1;
		// state[IDLE] <= 1'b1;
		state <= IDLE;
			for(int i=0; i<N; i++) begin: gen_assign1
			    decision[i] <= '0;
			end	
	end
	else begin
		//mask <= 0;
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
// 	// next = '0;
// 	next = state;
// 	ready = 0;
// 	first_iteration = '0;
// //use unique reverse case statement to implement one hot state machine
// //note that nowadays compiliers are able to choose one hot with enum state type, which means
// //this coding style is not necessary
// 	// unique case (1'b1)
// 	case (state)
// 		// state[IDLE]: begin
// 		IDLE: begin	
// 			if(start) begin
// 				// next[I1] = 1'b1;
// 				next = I1;
// 				ready = 1;
// 				end
// 			else
// 				// next[IDLE] = 1'b1;
// 				next = IDLE;
// 		end
// 		// state[I1]: begin
// 		I1: begin
// 			first_iteration = '1;
// 			// next[I2] = 1'b1;
// 			next = I2;
// 		end
// 		// state[I2]: 
// 		I2: 
// 			// next[I3] = 1'b1;
// 			next = I3;
// 		// state[I3]:
// 		I3: 
// 			// next[I4] = 1'b1;
// 			next = I4;
// 		// state[I4]: begin
// 		I4: 
// 			// next[IDLE] = 1'b1;
// 			next = IDLE;

// 	endcase
// end
//  FSM end

endmodule // scheduler