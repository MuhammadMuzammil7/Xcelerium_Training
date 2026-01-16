// 32-bit Adder:
module adder32(sum, cout, a, b, cin);
	output logic [31:0] sum;
	output logic cout;
	input logic [31:0] a, b;
	input logic cin;

assign {cout, sum} = a + b + cin;
endmodule