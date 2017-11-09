module rca_tb;

reg [15:0] req;
reg [15:0] grant;
rca rca1 (.*);

initial
begin
req = 16'b0000000000000000;
#10
req = 16'b1111000000000000;
#10
req = 16'b0000111100000000;
#10
req = 16'b0000000011110000;
#10
req = 16'b1010101101011100;
end
endmodule // dpa_tb