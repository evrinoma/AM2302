module DHT22(clk, reset, get, sda, data);
input wire clk;
input wire reset;
input wire get;
inout sda;
output reg [39:0] data;

reg lastSda	= 0;
reg wdata 	= 0;
reg rw		= 1;

reg [9:0] address;

reg [3:0] state;
reg [9:0] count;

reg [3:0] trace;
reg [9:0] countTrace;

localparam STATE_IDLE 				= 0;
localparam STATE_START				= 1;
localparam STATE_RELEASE 			= 2;
localparam STATE_RESPONSE_LOW 	= 3;
localparam STATE_RESPONSE_HIGH 	= 4;
localparam STATE_DATA_LOW			= 5;
localparam STATE_DATA_HIGH			= 6;
localparam STATE_STOP  				= 7;
localparam STATE_HALT 				= 8;

localparam DELAY_HALT 				= 2;

assign sda = (rw)? 1'bz : wdata;

always@(posedge clk)
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
					if (!get) 
						state <= STATE_START;
					else
						state <= STATE_IDLE;
					rw		<= 1;
					count	<= 10'd0;
					address <= 10'd39;
				end
				STATE_START : begin //1
					if (count == 1000) //1ms
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
					if (count == 30) //30us
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
					if (trace != STATE_HALT ) 
						begin
							if (count == 40)	//80us/2
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
					else
						begin
							state <= STATE_IDLE;
						end
				end
				STATE_RESPONSE_HIGH : begin //4
					if (trace != STATE_HALT ) 
						begin
							if (count == 40)	//80us/2
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
					else
						begin
							state <= STATE_IDLE;
						end
				end
				STATE_DATA_LOW : begin //5
					if (trace != STATE_HALT ) 
						begin
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
					else
						begin
							state <= STATE_IDLE;
						end	
				end
				STATE_DATA_HIGH : begin //6
					if (trace != STATE_HALT ) 
						begin
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
					else
						begin
							state <= STATE_IDLE;
						end
				end
				STATE_STOP : begin //7
					if (trace != STATE_HALT ) 
					begin
						if (sda) 
							begin
								state <= STATE_IDLE;
							end
						else
							begin
								state <= STATE_STOP;
							end
						rw		<= 1;	
						end
					else
					 begin
						state <= STATE_IDLE;
					 end
				end
			endcase
		end
end


always@(posedge clk)
begin
	if (!reset)
		begin
			trace <= STATE_IDLE;
			countTrace	<= 10'd0;
		end
	else
		begin		
			case (trace) 
				STATE_IDLE, STATE_START,STATE_RELEASE : begin //0, 1, 2
						trace <= state;
						countTrace	<= 10'd0;					
				end				
				STATE_RESPONSE_LOW,STATE_RESPONSE_HIGH,STATE_DATA_LOW,STATE_DATA_HIGH,STATE_STOP : begin //3, 4, 5, 6, 7
					if (state == trace)
						if (countTrace > 85 ) //85us - max time for Responce period
							begin
								trace <= STATE_HALT;
								countTrace	<= 10'd0;
							end
						else
							begin				
								countTrace <= countTrace + 10'd1;
							end
					else
						begin
							trace <= state;
							countTrace	<= 10'd0;
						end
				end
				STATE_HALT : begin //8
					if (countTrace == DELAY_HALT)
						begin
							trace <= STATE_IDLE;
							countTrace	<= 10'd0;					
						end
					else
						begin
							countTrace <= countTrace + 10'd1;
						end
				end
			endcase
		end		
end


endmodule
