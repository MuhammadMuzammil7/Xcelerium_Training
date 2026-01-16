// 8-bit Multiplier:
module multiplier(P, a, b);
    output logic [15:0] P;
    input  logic [7:0]  a, b;

    logic [7:0] w1, w2, w3, w4, w5, w6, w7, w8;
    logic       co_1, co_2, co_3, co_4, co_5, co_6, co_7;

    // ROW 0 (only ANDs):
    androw ROW0 (.pp(w1), .a(a), .b(b[0]));
    assign P[0] = w1[0];

    // ROW 1:
    mult_row ROW1 (
        .a_in(a),
        .b_in(b[1]),
        .c_in(1'b0),
        .in1 ({1'b0, w1[7:1]}),
        .sum_out(w2),
        .c_out(co_1)
    );
    assign P[1] = w2[0];

    // ROW 2:
    mult_row ROW2 (
        .a_in(a),
        .b_in(b[2]),
        .c_in(1'b0),
        .in1 ({co_1, w2[7:1]}),
        .sum_out(w3),
        .c_out(co_2)
    );
    assign P[2] = w3[0];

    // ROW 3:
    mult_row ROW3 (
        .a_in(a),
        .b_in(b[3]),
        .c_in(1'b0),
        .in1 ({co_2, w3[7:1]}),
        .sum_out(w4),
        .c_out(co_3)
    );
    assign P[3] = w4[0];

    // ROW 4;
    mult_row ROW4 (
        .a_in(a),
        .b_in(b[4]),
        .c_in(1'b0),
        .in1 ({co_3, w4[7:1]}),
        .sum_out(w5),
        .c_out(co_4)
    );
    assign P[4] = w5[0];

    // ROW 5:
    mult_row ROW5 (
        .a_in(a),
        .b_in(b[5]),
        .c_in(1'b0),
        .in1 ({co_4, w5[7:1]}),
        .sum_out(w6),
        .c_out(co_5)
    );
    assign P[5] = w6[0];

    // ROW 6:
    mult_row ROW6 (
        .a_in(a),
        .b_in(b[6]),
        .c_in(1'b0),
        .in1 ({co_5, w6[7:1]}),
        .sum_out(w7),
        .c_out(co_6)
    );
    assign P[6] = w7[0];

    // ROW 7:
    mult_row ROW7 (
        .a_in(a),
        .b_in(b[7]),
        .c_in(1'b0),
        .in1 ({co_6, w7[7:1]}),
        .sum_out(w8),
        .c_out(co_7)
    );

    // Final bits:
    assign P[15:7] = {co_7, w8};
endmodule