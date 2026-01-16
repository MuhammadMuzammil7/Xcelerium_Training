// 32-bit Register:
module register32(q, clk, rst_n, load, d);
	output logic [31:0] q;
	input logic clk, rst_n, load;
	input logic [31:0] d;

always_ff @(posedge clk) begin
	if(!rst_n) begin
		q <= 32'b0;
	end
	else if (load) begin
		q <= d;
	end
end

endmodule
