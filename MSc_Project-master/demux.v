module demux(
demux_din,
demux_dout,
demux_sel
);
parameter N = 4;
parameter SEL = $clog2(N);
input demux_din;
input [SEL-1:0] demux_sel;
output reg [N-1:0] demux_dout;


//assign demux_dout = {3'b0, demux_din} << demux_sel;

always @*
begin
	demux_dout = 4'b0000;
	demux_dout[demux_sel] = demux_din;
end
endmodule
