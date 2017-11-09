module dpa_tb;

reg [15:0] req;
reg [6:0] mask;
reg [15:0] grant;
dpa dpa1 (.*);

initial
begin
mask = 7'b0001111;
req = 16'b1010101101011100;
#10
mask = 7'b0011110;
req = 16'b1010101101011100;
#10
mask = 7'b0111100;
req = 16'b1010101101011100;
#10
mask = 7'b1111000;
req = 16'b1010101101011100;

end
endmodule // ripplecarry_tb
//1010101101011100