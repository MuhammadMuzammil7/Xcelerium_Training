// Self-checking testbench of Barrel Shifter:

`timescale 1ns/1ps

module barrel_shifter_tb;
    logic [31:0] data_in;
    logic [4:0]  shift_amt;
    logic        dir;
    logic [31:0] data_out;

// Instantiating the DUT:
    barrel_shifter DUT(
        .data_in(data_in),
        .shift_amt(shift_amt), 
        .dir(dir), 
        .data_out(data_out)
        );

    int total_tests = 0;
    int passed_tests = 0;

// Creating a task:
    task run_test(input logic [31:0] din, input logic [4:0] shamt, input logic d);
        logic [31:0] data_out_expected;
        total_tests++;

// Computing expected output:
        data_out_expected = (d == 1'b0) ? (din << shamt) : (din >> shamt);

        data_in   = din;
        shift_amt = shamt;
        dir       = d;
        #1;

        if (data_out === data_out_expected) begin
            $display("PASS: data_in=0x%h shift=%0d dir=%b => data_out=0x%h", din, shamt, d, data_out);
            passed_tests++;
        end else begin
            $display("FAIL: data_in=0x%h shift=%0d dir=%b => data_out=0x%h (expected 0x%h)", 
                     din, shamt, d, data_out, data_out_expected);
        end
    endtask

    // Displaying the results:
    initial begin
        $display("=== Directed Tests ===");
        run_test(32'h0000_0001, 5'd0, 1'b0);
        run_test(32'h0000_0001, 5'd4, 1'b0);
        run_test(32'h8000_0000, 5'd1, 1'b1);
        run_test(32'hFF00_0000, 5'd8, 1'b1);

        $display("=== Randomized Tests ===");
        repeat(10) run_test($random, $random % 32, $random % 2);

        $display("=== SUMMARY === ");
        $display("Total tests: %0d, Passed tests: %0d", total_tests, passed_tests);
        $finish;
    end

endmodule