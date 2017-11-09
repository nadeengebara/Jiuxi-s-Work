module pri_sel #(parameter N = 4)(
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
parameter P = 16;
input wire clk;
input wire reset;
input wire [$clog2(P)-1:0] in[0:N-1];
input wire update;
output reg [$clog2(P)-1:0] out[0:N-1]; //output should be OR of all the input vectors
output reg [N-1:0] req_out;

reg [$clog2(N)-1:0] sel;
reg [$clog2(P)-1:0] data[0:N-1];
reg [$clog2(P)-1:0] m_data[0:N-1];
reg [$clog2(P)-1:0] data_next[0:N-1];
//reg [$clog2(P)-1:0] data_out[0:N-1]; //this is the real output;
reg [N-1:0][N-1:0] mask;

output reg ready;
reg [N-1:0] mid;
wire any_one;

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
//assign out = data_out;
genvar k;
generate
	for (k = 0; k < N; k++) begin
		assign out[k] = m_data[k] /*& {4{ready}}*/;
	end
endgenerate

genvar i;
generate
	for (i = 0; i < N; i++) begin: gen_1
		assign mask[i] = {4{mid[i] | any_one}};
		assign m_data[i] = data[i] & mask[i];
		//output request vector
		//this part can be removed for gnt arbiter
		//assign req_out[i] = |data_out[i];
		assign req_out[i] = |m_data[i];
	end
endgenerate

//bit select
always_comb begin
	for (int i = 0; i < N; i++) begin: gen_2
		mid[i] = data[i][3-sel];
	end
end

//FSM
typedef enum{
// IDLE = 0,
S0 = 0,
S1 = 1,
S2 = 2,
S3 = 3
} state_index_t;

reg [N-1:0] state, next;
always_ff @(posedge clk) begin
	if(!reset) begin
		for (int i = 0; i < N; i++) begin
			data[i] <= '0;
		end
		state <= '0;
		state[S3] <= 1'b1;
	end
	else begin
		state <= next;
		data <= data_next;
	end
end

//output register
// always_ff @(posedge clk) begin// try asynchronised reset if code not working on FPGA
// 	if(~reset)
// 		for (int i = 0; i < N; i++) begin
// 			data_out[i] <= 0;
// 		end
// 	else if(ready) 
// 		data_out <= m_data;
// end

//delayed ready signal from S2 generation
//THIS IS A VERY IMPORTANT METHOD, REMEMBER THIS!!!
always_ff @(posedge clk) begin : proc_ready
	if(~reset) begin
		ready <= 0;
	end else if(state[S2] == 1) begin
		ready <= 1;
	end
	else
		ready <= 0;
end

always_comb begin
	next = '0;
	sel = 0;
	//update = 0; // without default value lead to latch!!!
	unique case (1'b1)
		// state[IDLE]: begin
		// 	next[S0] = 1'b1;
		// end
		state[S0]: begin
			next[S1] = 1'b1;
			sel = 0;
			// ready = 1;
		end
		state[S1]: begin
			next[S2] = 1'b1;
			sel = 1;
		end
		state[S2]: begin 
			next[S3] = 1'b1;
			sel = 2;
		end
		state[S3]: begin
			if(update) begin
				next[S0] = 1'b1;
			//	ready = 1;
			end
			else next[S3] = 1'b1;
			sel = 3;
		end
	endcase
end

endmodule// pri_sel