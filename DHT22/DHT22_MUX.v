module DHT22_MUX(clk, reset, get, sda, data);
input wire clk;
input wire reset;
input wire get;
inout sda;
output wire [39:0] data;

wire wdivClk;

divClk Add_DivClk2MHz( 
	.clk (clk), 
	.divClk (wdivClk)
);


DHT22 Add_DHT22(
	.clk(wdivClk),
	.reset (reset),
	.get (get),
	.sda (sda),
	.data (data)
);


endmodule