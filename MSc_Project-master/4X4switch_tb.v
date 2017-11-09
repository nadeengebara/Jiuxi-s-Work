module switch_tb;

reg [3:0] port_tx;
reg [7:0] sel;
reg [3:0] port_rx;

switch s (.*);

initial 
begin 
sel = 0;
port_tx = 0;
#10
sel = 8'b10010011;

#10
port_tx[0] = 1;
#10
port_tx[1] = 1;
#10
port_tx[2] = 1;
#10
port_tx[3] = 1;

#10
port_tx[0] = 0;
#10
port_tx[1] = 0;
#10
port_tx[2] = 0;
#10
port_tx[3] = 0;


end 
endmodule 