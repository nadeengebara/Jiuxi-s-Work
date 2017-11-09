module pri_sel_5bit(
	clk,
	reset,
	in,
	update,
	out,
	req_out,
	ready
	);
//know that the input of the grand arbiter is only 4
//the input request was selected at the FIFO stage where only non-empty queue
//with highest priority will be selected. This is where 16 different request boil down
//to only 4 request. Hence in this module, the number of input equals to N.
parameter N = 16;
parameter P = 32;
parameter C = $clog2(P);
input wire clk;
input wire reset;
input wire [C-1:0] in[0:N-1];
input wire update;
output reg [C-1:0] out[0:N-1]; //output should be OR of all the input vectors
output reg [N-1:0] req_out;

reg [$clog2(N)-1:0] sel;
reg [C-1:0] data[0:N-1];
reg [C-1:0] m_data[0:N-1];
reg [C-1:0] data_next[0:N-1];
reg [C-1:0] data_out[0:N-1]; //this is the real output;
reg [N-1:0][N-1:0] mask;

output reg ready;
reg [N-1:0] mid;
wire any_one;
reg store;

always_comb begin
	if(update) begin
		data_next = in;
	end
	else
		for (int i = 0; i < N; i++) begin
			data_next[i] = m_data[i];
		end
end

assign any_one = ~(|mid);
assign out = data_out;
// genvar k;
// generate
// 	for (k = 0; k < N; k++) begin
// 		assign out[k] = m_data[k] /*& {4{ready}}*/;
// 	end
// endgenerate

genvar i;
generate
	for (i = 0; i < N; i++) begin: gen_1
		assign mask[i] = {C{mid[i] | any_one}};
		assign m_data[i] = data[i] & mask[i];
		//output request vector
		//this part can be removed for gnt arbiter
		assign req_out[i] = |data_out[i];
		//assign req_out[i] = |m_data[i];
	end
endgenerate

//bit select
always_comb begin
	for (int i = 0; i < N; i++) begin: gen_2
		mid[i] = data[i][C-1-sel];
	end
end

//FSM
typedef enum int unsigned{IDLE, S0, S1, S2, S3, S4} state_t;
state_t state, next;

always_ff @(posedge clk) begin
	if(!reset) begin
		for (int i = 0; i < N; i++) begin
			data[i] <= '0;
		end
		state <= IDLE;
	end
	else begin
		state <= next;
		data <= data_next;
	end
end

//output register
always_ff @(posedge clk) begin// try asynchronised reset if code not working on FPGA
	if(~reset)
		for (int i = 0; i < N; i++) begin
			data_out[i] <= 0;
		end
	else if(store) 
		data_out <= m_data;
end

//delayed ready signal from S2 generation
//THIS IS A VERY IMPORTANT METHOD, REMEMBER THIS!!!
always_ff @(posedge clk) begin : proc_ready
	if(~reset) begin
		ready <= 0;
	end else if(state == S4) begin
		ready <= 1;
	end
	else
		ready <= 0;
end

always_comb begin
	next = state;
	sel = 0;
	store = 0;
	//update = 0; // without default value lead to latch!!!
	case (state)
		IDLE: begin 
			if(update) begin
				next = S0;
			//	ready = 1;
			end
			else next = IDLE;
		end
		S0: begin
			next = S1;
			sel = 0;
			// ready = 1;
		end
		S1: begin
			next = S2;
			sel = 1;
		end
		S2: begin 
			next = S3;
			sel = 2;
		end
		S3: begin
			next  = S4;
			sel = 3;
			store = 1;
		end
		S4: begin
			next = IDLE;
			sel = 4;
		end
	endcase
end

endmodule// pri_sel