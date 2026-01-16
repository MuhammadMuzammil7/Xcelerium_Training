// Multiplier with registered inputs and outputs:
module multiplier_registered (P, clk, rst_n, EA, EB, a, b);
    output logic [15:0] P;
    input  logic        clk;
    input  logic        rst_n;
    input  logic        EA, EB;
    input  logic [7:0]  a, b;
    
    // Internal registers:
    logic [7:0]  A_reg, B_reg;
    logic [15:0] P_reg;

    // Input registers:
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            A_reg <= 8'b0;
            B_reg <= 8'b0;
        end
        else begin
        if (EA)
            A_reg <= a;
        if (EB)
            B_reg <= b;
        end 
    end

    // Combinational multiplier:
    multiplier circuit (
        .a(A_reg),
        .b(B_reg),
        .P(P_reg)
    );

    // Output register:
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) 
            P <= 16'bx;
        else 
            P <= P_reg;
    end

endmodule