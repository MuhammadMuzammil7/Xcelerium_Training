// Self-checking testbench of 8 to 3 priority encoder:

`timescale 1ns/1ps

module encoder8to3_tb;
    logic [7:0] in;
    logic [2:0] out;
    logic       valid;

// Instantiating the DUT:
    encoder8to3 DUT(
        .in(in), 
        .out(out), 
        .valid(valid)
        );

    int total_tests = 0;
    int passed_tests = 0;

// Creating a task:
    task run_test(input logic [7:0] in_vec);
        logic [2:0] expected_out;
        logic       expected_valid;
        total_tests++;

// Computing expected output:
        expected_valid = (|in_vec); // valid if any bit is 1
        casez (in_vec)
            8'b1???????: expected_out = 3'b111;
            8'b01??????: expected_out = 3'b110;
            8'b001?????: expected_out = 3'b101;
            8'b0001????: expected_out = 3'b100;
            8'b00001???: expected_out = 3'b011;
            8'b000001??: expected_out = 3'b010;
            8'b0000001?: expected_out = 3'b001;
            8'b00000001: expected_out = 3'b000;
            default:     expected_out = 3'b000;
        endcase

        in = in_vec;
        #1;

        if (out === expected_out && valid === expected_valid) begin
            $display("PASS: in=0x%b => out=%b valid=%b", in, out, valid);
            passed_tests++;
        end else begin
            $display("FAIL: in=0x%b => out=%b (expected %b) valid=%b (expected %b)", 
                     in, out, expected_out, valid, expected_valid);
        end
    endtask

    // Printing the results:
    initial begin
        $display("=== Directed Tests: all 1-bit inputs ===");
        for (int i=0; i<8; i=i+1)
            run_test(8'b1 << i);

        $display("=== Directed Tests: multiple bits high (invalid patterns) ===");
        run_test(8'b00000011);
        run_test(8'b10101010);
        run_test(8'b11111111);

        $display("=== Randomized Tests ===");
        repeat(10) run_test($random);

        $display("=== SUMMARY ===");
        $display("Total tests: %0d, Passed tests: %0d", total_tests, passed_tests);
        $finish;
    end

endmodule