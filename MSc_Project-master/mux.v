module mux(
mux_din,
mux_sel,
mux_dout
);
//---------------Ports---------------
parameter N = 4;
parameter SEL = $clog2(N); 

input [N-1:0] mux_din;
input [SEL-1:0] mux_sel;
output reg mux_dout;

//assign mux_dout = mux_din[mux_sel];

always @*
begin 
mux_dout = mux_din[mux_sel];
end 
// begin
// case (mux_sel)
// 	2'b00:	mux_dout = mux_din[0];
// 	2'b01:	mux_dout = mux_din[1];
// 	2'b10:	mux_dout = mux_din[2];
// 	2'b11:	mux_dout = mux_din[3];
// endcase 
// end 
endmodule



