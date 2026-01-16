// 8 to 3 Priority Encoder:
module encoder8to3 (out, valid, in);
    output logic [2:0] out;
    output logic valid;
    input  logic [7:0] in;

    always_comb begin
        valid = 1'b1;
        if      (in[7]) out = 3'b111;
        else if (in[6]) out = 3'b110;
        else if (in[5]) out = 3'b101;
        else if (in[4]) out = 3'b100;
        else if (in[3]) out = 3'b011;
        else if (in[2]) out = 3'b010;
        else if (in[1]) out = 3'b001;
        else if (in[0]) out = 3'b000;
        else begin
            out = 3'b000;
            valid = 1'b0;
        end
    end

endmodule