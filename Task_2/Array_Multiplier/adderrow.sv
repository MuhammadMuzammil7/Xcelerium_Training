// Adder Row:
module adderrow(sum, cout, a, b, cin);
    output logic [7:0] sum;
    output logic       cout;
    input  logic [7:0] a, b;
    input  logic       cin;

    logic [8:0] temp_sum; // 8-bit sum + carry

    assign temp_sum = a + b + cin;
    assign sum = temp_sum[7:0];
    assign cout = temp_sum[8];
endmodule