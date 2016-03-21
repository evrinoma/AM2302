module divClk(clk, divClk);
input wire clk;
output reg divClk = 0;

always@(posedge clk)
begin
	divClk <= !divClk;
end

endmodule
