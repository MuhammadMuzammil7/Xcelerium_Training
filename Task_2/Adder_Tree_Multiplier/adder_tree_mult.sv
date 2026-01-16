// Adder Tree Multiplier:
module adder_tree_mult (
    input  logic        clk,
    input  logic        rst_n,
    input  logic [7:0]  a,
    input  logic [7:0]  b,
    output logic [15:0] P
);

    // Input registers:
    logic [7:0] a_reg, b_reg;

    always_ff @(negedge clk or negedge rst_n) begin
        if (!rst_n) begin
            a_reg <= 8'd0;
            b_reg <= 8'd0;
        end 
        else begin
            a_reg <= a;
            b_reg <= b;
        end
    end

    // Partial products
    logic [15:0] pp [7:0];

    genvar i;
    generate
        for (i = 0; i < 8; i++) begin
            assign pp[i] = b_reg[i] ? (a_reg << i) : 16'd0;
        end
    endgenerate

    // Adder tree (combinational)
    logic [15:0] s0, s1, s2, s3;
    logic [15:0] t0, t1;
    logic [15:0] P_comb;

    assign s0 = pp[0] + pp[1];
    assign s1 = pp[2] + pp[3];
    assign s2 = pp[4] + pp[5];
    assign s3 = pp[6] + pp[7];

    assign t0 = s0 + s1;
    assign t1 = s2 + s3;

    assign P_comb = t0 + t1;

    // Output register:
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            P <= 16'd0;
        else
            P <= P_comb;
    end

endmodule