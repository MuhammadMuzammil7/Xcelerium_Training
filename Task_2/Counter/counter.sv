// Up-Down Counter:
module counter(count, clk, rst_n, en, up_dn);
	output logic [7:0] count;
	input logic clk, rst_n, en, up_dn;


always_ff @(posedge clk or negedge rst_n) begin
	if(!rst_n)
		count <= 0;
	else begin
		if (en) begin
			if(up_dn == 1'b1)
				count <= count + 1;
			else if(up_dn == 1'b0)
				count <= count - 1;
		end
	end
end

endmodule