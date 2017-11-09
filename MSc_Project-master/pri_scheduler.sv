module pri_scheduler #(parameter N = 4) (
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
parameter P = 16;
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
wire [N-1:0] gnt_ready;
wire [N-1:0] acc_ready;
//reg mask;
reg first_iteration;
//the req_reg will not be treated as register until another always_ff is added
reg [$clog2(P)-1:0] req_reg[0:N-1][0:N-1];
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
			assign req_reg[i][j] = pri_req_in[i][j] & {4{gnt_en[j]}};
		end
			//assign masked_req_in[i] = ~{N{mask}} & req_reg[i];
	end
endgenerate

//grant arbiter
generate
for(i=0; i<N; i++) begin: gen_i
	pri_arbiter pri_grant_arbiter (
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
	pri_arbiter pri_accept_arbiter (
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

//	FSM
typedef enum int unsigned{IDLE, I1, I2, I3, I4} state_t;
state_t state, next;

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

// always_ff @(posedge clk or negedge reset) begin : proc_delayed_ready2
// 	if(~reset)
// 			delayed_ready2 <= 0;
// 	else 
// 			delayed_ready2 <= delayed_ready1;
// end

generate
	for(i=0; i<N; i++) begin: gen_out
		assign decision_next[i] = (first_iteration) ? (acc_gnt[i] & {4{acc_ready[i]}}) : ((decision[i] | acc_gnt[i])& {4{acc_ready[i]}});
	end
endgenerate

always_comb begin
	next = state;
	decision_ready = 0;
	first_iteration = '0;
	init = 0;
//use unique reverse case statement to implement one hot state machine
//note that nowadays compiliers are able to choose one hot with enum state type, which means
//this coding style is not necessary
	case (state)
		IDLE: begin
			if(start) begin
				next = I1;
				decision_ready = 1;
				init = 1;
				end
			else
				next = IDLE;
		end
		I1: begin
			
			if(delayed_ready1[1]) 
				next = I2;
			else begin
				next = I1;
				first_iteration = '1;
			end
		end
		I2: begin
				if(delayed_ready1[1])
					next = I3;
				else
					next = I2;
		end
		I3: begin
				if(delayed_ready1[1])
					next = I4;
				else
					next = I3;
		end
		I4: begin
			if(acc_ready[1])
					next = IDLE;
				else
					next = I4;
		end
	endcase
end
//  FSM end

endmodule // scheduler