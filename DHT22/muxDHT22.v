module muxDHT22(sw0, sw1, sw2, sw3, data, out);
input wire sw0;
input wire sw1;
input wire sw2;
input wire sw3;
input wire [39:0] data;
output wire [7:0] out;

assign out = (!sw0)? data[15:8] : (!sw1)? data[23:16] : (!sw2)? data[31:24] : (!sw3)? data[38:32] : data[7:0];

endmodule
