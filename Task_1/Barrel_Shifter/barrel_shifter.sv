// Barrel Shifter:
module barrel_shifter (
    output logic [31:0] data_out,
    input  logic [31:0] data_in,
    input  logic [4:0]  shift_amt,   // 0–31
    input  logic        dir          // 0 = left, 1 = right
);

    always_comb begin
        if (dir == 1'b0)
            data_out = data_in << shift_amt;   // logical left shift
        else
            data_out = data_in >> shift_amt;   // logical right shift
    end

endmodule