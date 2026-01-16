// Self-checking testbench of 32-bit Adder:
`timescale 1ns/1ps

module adder32_tb;
    logic [31:0] a, b;
    logic        cin;
    logic [31:0] sum;
    logic        cout;

// Instantiating the DUT:
    adder32 DUT (
        .sum(sum), 
        .cout(cout), 
        .a(a), 
        .b(b), 
        .cin(cin)
        );

    int total_tests = 0;
    int passed_tests = 0;

// Creating a task:
    task run_test(input logic [31:0] a_in, input logic [31:0] b_in, input logic c_in);
        logic [31:0] expected_sum;
        logic        expected_cout;
        total_tests++;

// Computing expected output:
        {expected_cout, expected_sum} = a_in + b_in + c_in;

        a = a_in;
        b = b_in;
        cin = c_in;
        #1;

        if (sum === expected_sum && cout === expected_cout) begin
            $display("PASS: a=0x%h b=0x%h cin=%b => sum=0x%h cout=%b", a, b, cin, sum, cout);
            passed_tests++;
        end else begin
            $display("FAIL: a=0x%h b=0x%h cin=%b => sum=0x%h (expected 0x%h) cout=%b (expected %b)", 
                     a, b, cin, sum, expected_sum, cout, expected_cout);
        end
    endtask

// Printing the results:
    initial begin
        $display("=== Directed Tests ===");
        // Edge cases
        run_test(32'h00000000, 32'h00000000, 1'b0);        // 0+0
        run_test(32'hFFFFFFFF, 32'hFFFFFFFF, 1'b0);        // max + max
        run_test(32'hFFFFFFFF, 32'h00000001, 1'b0);        // overflow scenario
        run_test(32'h7FFFFFFF, 32'h00000001, 1'b0);        // overflow scenario
        run_test(32'h12345678, 32'h87654321, 1'b1);        // arbitrary values

        $display("=== Randomized Tests ===");
        repeat(10) begin
            run_test($random, $random, $random % 2);
        end

        $display("=== SUMMARY ===");
        $display("Total tests: %0d , Passed tests: %0d", total_tests, passed_tests);
        $finish;
    end

endmodule