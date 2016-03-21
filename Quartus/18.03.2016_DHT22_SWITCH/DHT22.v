module DHT22(clk, reset, get, sda, data);
input wire clk;
input wire reset;
input wire get;
inout sda;
output reg [39:0] data;

reg lastSda	= 0;
reg divClk 	= 0;
reg wdata 	= 0;
reg rw		= 1;

reg [2:0] state;
reg [9:0] count;
reg [9:0] address;

//assign sda = divClk;

localparam STATE_IDLE 				= 0;
localparam STATE_START 				= 1;
localparam STATE_RELEASE 			= 2;
localparam STATE_RESPONSE_LOW 	= 3;
localparam STATE_RESPONSE_HIGH 	= 4;
localparam STATE_DATA_LOW			= 5;
localparam STATE_DATA_HIGH			= 6;
localparam STATE_STOP 				= 7;

assign sda = (rw)? 1'bz : wdata;

always@(posedge clk)
begin
	divClk <= !divClk;
end

always@(posedge divClk)
begin
	if (!reset)
		begin
			state <= STATE_IDLE;
			rw		<= 1;
			count <= 10'd0;
			address <= 10'd39;
			data <= 40'd0;
			lastSda	<= 0;
		end
	else
		begin
			case (state) 
				STATE_IDLE : begin //0
					if (get) 
						state <= STATE_START;
					else
						state <= STATE_IDLE;
					rw		<= 1;
					count	<= 10'd0;
					address <= 10'd39;
				end
				STATE_START : begin //1
					if (count == 1000) 
						begin
							state <= STATE_RELEASE;
							count <= 10'd0;
						end
					else
						begin
							state <= STATE_START;
							count <= count + 10'd1;
						end
					wdata <= 0;
					rw		<= 0;
				end
				STATE_RELEASE : begin //2
					if (count == 30) 
						begin
							state <= STATE_RESPONSE_LOW;
							count <= 10'd0;
							rw		<= 1;
						end
					else
						begin
							state <= STATE_RELEASE;
							count <= count + 10'd1;
							rw		<= 0;
						end
					wdata <= 1;
				end
				STATE_RESPONSE_LOW : begin //3
					if (count == 40)
						begin
							if (sda && !lastSda) 
								begin
									state <= STATE_RESPONSE_HIGH;
									count <= 10'd0;
								end								
							else
								begin
									state <= STATE_RESPONSE_LOW;							
								end
						end
					else
						begin
							count <= count + 10'd1;
						end	
					rw			<= 1;	
					lastSda	<= sda;
				end
				STATE_RESPONSE_HIGH : begin //4
					if (count == 40)
						begin
							if (!sda && lastSda) 
								begin
									state <= STATE_DATA_LOW;
									count <= 10'd0;
								end								
							else
								begin
									state <= STATE_RESPONSE_HIGH;							
								end
						end
					else
						begin
							count <= count + 10'd1;
						end	
					rw			<= 1;	
					lastSda	<= sda;
				end
				STATE_DATA_LOW : begin //5
					if (sda) 
						begin
							state <= STATE_DATA_HIGH;
						end
					else
						begin
							state <= STATE_DATA_LOW;
						end
					rw		<= 1;		
				end
				STATE_DATA_HIGH : begin //6
					if (sda) 
						begin
							count <= count + 10'd1;
							state <= STATE_DATA_HIGH;
						end
					else
						begin
							if (count < 30) 
								begin
									data[address] = 1'b0;
								end
							else
								begin
									data[address] = 1'b1;
								end
							if (address)
								begin
									address = address - 10'd1;
									state <= STATE_DATA_LOW;
									count <= 10'd0;
								end
							else
								begin
									address <= 10'd39;
									state <= STATE_STOP;
								end
						end
					rw		<= 1;	
				end
				STATE_STOP : begin //7
					if (sda) 
						begin
							state <= STATE_IDLE;
						end
					else
						begin
							state <= STATE_STOP;
						end
					state <= STATE_IDLE;
					rw		<= 1;	
				end
			endcase
		end
end



endmodule
