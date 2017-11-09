module arbiter_tb;

reg north, west, request, south, east, grant;
arbiter a (.*);

initial
begin
	north = 1;
	west = 1;
	request = 1;
#10
	north = 1;
	west = 1;
	request = 0;
#10
	north = 0;
	west = 1;
	request = 1;
#10
	north = 1;
	west = 0;
	request = 1;	
#10
	north = 1;
	west = 1;
	request = 0;
end
endmodule // arbiter_cell_tb