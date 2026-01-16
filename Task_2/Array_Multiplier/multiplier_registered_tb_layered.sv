// Layered testbench of Array Multiplier:
// Array Multiplier Transaction Class
class array_mult_transaction #(parameter WIDTH_A = 8, parameter WIDTH_B = 8, parameter WIDTH_P = 16);
    rand bit EA;
    rand bit EB;
    rand bit [WIDTH_A-1:0] a;
    rand bit [WIDTH_B-1:0] b;
    bit [WIDTH_P-1:0] P;
    
    constraint valid_c {
        EA dist {1 := 90, 0 := 10};
        EB dist {1 := 90, 0 := 10};
        a dist {0 := 5, [1:255] := 95};
        b dist {0 := 5, [1:255] := 95};
    }
    
    // Corner case constraints
    constraint corner_cases {
        soft a inside {8'hFF, 8'h80, 8'h01, 8'h00};
        soft b inside {8'hFF, 8'h80, 8'h01, 8'h00};
    }
    
    function void display(string tag = "");
        $display("[%0t] %s: EA=%0b, EB=%0b, a=%0d (0x%0h), b=%0d (0x%0h), P=%0d (0x%0h)", 
                 $time, tag, EA, EB, a, a, b, b, P, P);
    endfunction
endclass

// Array Multiplier Generator Class
class array_mult_generator #(parameter WIDTH_A = 8, parameter WIDTH_B = 8, parameter WIDTH_P = 16);
    mailbox #(array_mult_transaction#(WIDTH_A, WIDTH_B, WIDTH_P)) gen2drv;
    int num_trans;
    
    function new(mailbox #(array_mult_transaction#(WIDTH_A, WIDTH_B, WIDTH_P)) g2d, int n = 100);
        this.gen2drv = g2d;
        this.num_trans = n;
    endfunction
    
    task run();
        array_mult_transaction#(WIDTH_A, WIDTH_B, WIDTH_P) trans;
        repeat(num_trans) begin
            trans = new();
            assert(trans.randomize()) else $fatal("Randomization failed");
            gen2drv.put(trans);
        end
    endtask
endclass

// Array Multiplier Driver Class
class array_mult_driver #(parameter WIDTH_A = 8, parameter WIDTH_B = 8, parameter WIDTH_P = 16);
    virtual array_mult_if#(WIDTH_A, WIDTH_B, WIDTH_P) vif;
    mailbox #(array_mult_transaction#(WIDTH_A, WIDTH_B, WIDTH_P)) gen2drv;
    
    function new(virtual array_mult_if#(WIDTH_A, WIDTH_B, WIDTH_P) vif, 
                 mailbox #(array_mult_transaction#(WIDTH_A, WIDTH_B, WIDTH_P)) g2d);
        this.vif = vif;
        this.gen2drv = g2d;
    endfunction
    
    task reset();
        vif.rst_n <= 0;
        vif.EA <= 0;
        vif.EB <= 0;
        vif.a <= 0;
        vif.b <= 0;
        repeat(3) @(posedge vif.clk);
        vif.rst_n <= 1;
        @(posedge vif.clk);
    endtask
    
    task run();
        array_mult_transaction#(WIDTH_A, WIDTH_B, WIDTH_P) trans;
        forever begin
            gen2drv.get(trans);
            @(negedge vif.clk);  // Drive on negedge (inputs registered on negedge)
            vif.EA <= trans.EA;
            vif.EB <= trans.EB;
            vif.a <= trans.a;
            vif.b <= trans.b;
            trans.display("DRIVER");
        end
    endtask
endclass

// Array Multiplier Monitor Class
class array_mult_monitor #(parameter WIDTH_A = 8, parameter WIDTH_B = 8, parameter WIDTH_P = 16);
    virtual array_mult_if#(WIDTH_A, WIDTH_B, WIDTH_P) vif;
    mailbox #(array_mult_transaction#(WIDTH_A, WIDTH_B, WIDTH_P)) mon2scb;
    
    function new(virtual array_mult_if#(WIDTH_A, WIDTH_B, WIDTH_P) vif, 
                 mailbox #(array_mult_transaction#(WIDTH_A, WIDTH_B, WIDTH_P)) m2s);
        this.vif = vif;
        this.mon2scb = m2s;
    endfunction
    
    task run();
        array_mult_transaction#(WIDTH_A, WIDTH_B, WIDTH_P) trans;
        forever begin
            @(posedge vif.clk);  // Sample output on posedge (output registered on posedge)
            trans = new();
            trans.EA = vif.EA;
            trans.EB = vif.EB;
            trans.a = vif.a;
            trans.b = vif.b;
            trans.P = vif.P;
            mon2scb.put(trans);
            trans.display("MONITOR");
        end
    endtask
endclass

// Array Multiplier Scoreboard Class
class array_mult_scoreboard #(parameter WIDTH_A = 8, parameter WIDTH_B = 8, parameter WIDTH_P = 16);
    mailbox #(array_mult_transaction#(WIDTH_A, WIDTH_B, WIDTH_P)) mon2scb;
    
    // Pipeline storage to account for 2-cycle latency + enable logic
    array_mult_transaction#(WIDTH_A, WIDTH_B, WIDTH_P) pipeline[$];
    
    // Track the actual registered values
    bit [WIDTH_A-1:0] A_reg_model;
    bit [WIDTH_B-1:0] B_reg_model;
    
    int pass_count, fail_count;
    int latency = 2;  // 2-cycle latency
    
    function new(mailbox #(array_mult_transaction#(WIDTH_A, WIDTH_B, WIDTH_P)) m2s);
        this.mon2scb = m2s;
        this.pass_count = 0;
        this.fail_count = 0;
        this.A_reg_model = 0;
        this.B_reg_model = 0;
    endfunction
    
    function bit [WIDTH_P-1:0] compute_expected(bit [WIDTH_A-1:0] a, bit [WIDTH_B-1:0] b);
        return a * b;
    endfunction
    
    task run();
        array_mult_transaction#(WIDTH_A, WIDTH_B, WIDTH_P) trans;
        array_mult_transaction#(WIDTH_A, WIDTH_B, WIDTH_P) expected_trans;
        bit [WIDTH_P-1:0] expected_P;
        bit [WIDTH_A-1:0] expected_A;
        bit [WIDTH_B-1:0] expected_B;
        
        forever begin
            mon2scb.get(trans);
            
            // Add current transaction to pipeline
            pipeline.push_back(trans);
            
            // Wait for pipeline to fill (latency cycles)
            if (pipeline.size() > latency) begin
                // Get the transaction that affects the registers
                expected_trans = pipeline.pop_front();
                
                // Update register model based on enables
                if (expected_trans.EA)
                    A_reg_model = expected_trans.a;
                if (expected_trans.EB)
                    B_reg_model = expected_trans.b;
                
                // Compute expected output based on register contents
                expected_P = compute_expected(A_reg_model, B_reg_model);
                
                // Compare (ignore if output is X during reset)
                if (trans.P !== 16'bx) begin
                    if (trans.P === expected_P) begin
                        $display("[%0t] SCOREBOARD PASS: %0d x %0d = %0d (A_reg=%0d, B_reg=%0d, Expected=%0d, Got=%0d)", 
                                 $time, A_reg_model, B_reg_model, expected_P, 
                                 A_reg_model, B_reg_model, expected_P, trans.P);
                        pass_count++;
                    end else begin
                        $display("[%0t] SCOREBOARD FAIL: %0d x %0d = %0d (A_reg=%0d, B_reg=%0d, Expected=%0d, Got=%0d)", 
                                 $time, A_reg_model, B_reg_model, expected_P,
                                 A_reg_model, B_reg_model, expected_P, trans.P);
                        fail_count++;
                    end
                end
            end
        end
    endtask
    
    function void report();
        real pass_rate;
        $display("\n========== SCOREBOARD REPORT ==========");
        $display("Total Passed: %0d", pass_count);
        $display("Total Failed: %0d", fail_count);
        if ((pass_count + fail_count) > 0) begin
            pass_rate = (pass_count * 100.0) / (pass_count + fail_count);
            $display("Pass Rate: %.2f%%", pass_rate);
        end
        $display("Note: First %0d transactions ignored due to pipeline latency", latency);
        $display("Note: Transactions with X output (during reset) are also ignored");
        $display("=======================================\n");
    endfunction
endclass

// Array Multiplier Environment Class
class array_mult_environment #(parameter WIDTH_A = 8, parameter WIDTH_B = 8, parameter WIDTH_P = 16);
    array_mult_generator#(WIDTH_A, WIDTH_B, WIDTH_P) gen;
    array_mult_driver#(WIDTH_A, WIDTH_B, WIDTH_P) drv;
    array_mult_monitor#(WIDTH_A, WIDTH_B, WIDTH_P) mon;
    array_mult_scoreboard#(WIDTH_A, WIDTH_B, WIDTH_P) scb;
    
    mailbox #(array_mult_transaction#(WIDTH_A, WIDTH_B, WIDTH_P)) gen2drv;
    mailbox #(array_mult_transaction#(WIDTH_A, WIDTH_B, WIDTH_P)) mon2scb;
    
    virtual array_mult_if#(WIDTH_A, WIDTH_B, WIDTH_P) vif;
    
    function new(virtual array_mult_if#(WIDTH_A, WIDTH_B, WIDTH_P) vif);
        this.vif = vif;
        gen2drv = new();
        mon2scb = new();
        
        gen = new(gen2drv, 150);  // More transactions to test enable logic
        drv = new(vif, gen2drv);
        mon = new(vif, mon2scb);
        scb = new(mon2scb);
    endfunction
    
    task run();
        fork
            drv.reset();
            #150 gen.run();
            drv.run();
            mon.run();
            scb.run();
        join_any
    endtask
    
    function void report();
        scb.report();
    endfunction
endclass

// Array Multiplier Interface
interface array_mult_if #(parameter WIDTH_A = 8, parameter WIDTH_B = 8, parameter WIDTH_P = 16)
                        (input logic clk);
    logic rst_n;
    logic EA;
    logic EB;
    logic [WIDTH_A-1:0] a;
    logic [WIDTH_B-1:0] b;
    logic [WIDTH_P-1:0] P;
endinterface

// Array Multiplier Testbench Top
module multiplier_registered_tb_layered;
    parameter WIDTH_A = 8;
    parameter WIDTH_B = 8;
    parameter WIDTH_P = 16;
    
    logic clk;
    
    array_mult_if#(WIDTH_A, WIDTH_B, WIDTH_P) amif(clk);
    
    multiplier_registered dut (
        .clk(amif.clk),
        .rst_n(amif.rst_n),
        .EA(amif.EA),
        .EB(amif.EB),
        .a(amif.a),
        .b(amif.b),
        .P(amif.P)
    );
    
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end
    
    array_mult_environment#(WIDTH_A, WIDTH_B, WIDTH_P) env;
    
    initial begin
        env = new(amif);
        env.run();
        #4000;  // Longer time for more transactions
        env.report();
        $finish;
    end
    
    initial begin
        $dumpfile("multiplier_registered.vcd");
        $dumpvars(0, multiplier_registered_tb_layered);
    end
endmodule