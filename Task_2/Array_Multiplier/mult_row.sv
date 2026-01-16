// AND + FA Row:
module mult_row(sum_out, c_out, in1, a_in, b_in, c_in);
    output logic [7:0] sum_out;
    output logic       c_out;
    input  logic [7:0] in1;
    input  logic [7:0] a_in;
    input  logic       b_in;
    input  logic       c_in;

    logic [7:0] in2;

    androw AND_ROW (
        .pp(in2),
        .a (a_in),
        .b (b_in)
    );

    adderrow ADD_ROW (
        .a   (in1),
        .b   (in2),
        .cin (c_in),
        .sum (sum_out),
        .cout(c_out)
    );
endmodule