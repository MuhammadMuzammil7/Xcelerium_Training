// Shift Register:
module shift_reg #(parameter WIDTH = 8) (q_out, clk, rst_n, shift_en, dir, d_in);
	output logic [WIDTH-1:0] q_out;
	input logic clk, rst_n, shift_en, dir, d_in;

always_ff @(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		q_out <= 0;
	end
	else if(shift_en) begin
		if(dir == 0) begin
			q_out <= {q_out[WIDTH-2:0], d_in};
		end
		else begin
			q_out <= {d_in, q_out[WIDTH-1:1]};
		end
	end
end

endmodule