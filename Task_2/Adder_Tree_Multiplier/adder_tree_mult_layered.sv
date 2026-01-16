// Layered Testbench of Adder Tree Multiplier:
// Adder Tree Multiplier Transaction Class
class mult_transaction #(parameter WIDTH_A = 8, parameter WIDTH_B = 8, parameter WIDTH_P = 16);
    rand bit [WIDTH_A-1:0] a;
    rand bit [WIDTH_B-1:0] b;
    bit [WIDTH_P-1:0] P;
    
    constraint valid_c {
        a dist {0 := 5, [1:255] := 95};
        b dist {0 := 5, [1:255] := 95};
    }
    
    constraint corner_cases {
        // Occasionally test maximum values
        soft a inside {8'hFF, 8'h80, 8'h01};
        soft b inside {8'hFF, 8'h80, 8'h01};
    }
    
    function void display(string tag = "");
        $display("[%0t] %s: a=%0d (0x%0h), b=%0d (0x%0h), P=%0d (0x%0h)", 
                 $time, tag, a, a, b, b, P, P);
    endfunction
endclass

// Adder Tree Multiplier Generator Class
class mult_generator #(parameter WIDTH_A = 8, parameter WIDTH_B = 8, parameter WIDTH_P = 16);
    mailbox #(mult_transaction#(WIDTH_A, WIDTH_B, WIDTH_P)) gen2drv;
    int num_trans;
    
    function new(mailbox #(mult_transaction#(WIDTH_A, WIDTH_B, WIDTH_P)) g2d, int n = 100);
        this.gen2drv = g2d;
        this.num_trans = n;
    endfunction
    
    task run();
        mult_transaction#(WIDTH_A, WIDTH_B, WIDTH_P) trans;
        repeat(num_trans) begin
            trans = new();
            assert(trans.randomize()) else $fatal("Randomization failed");
            gen2drv.put(trans);
        end
    endtask
endclass

// Adder Tree Multiplier Driver Class
class mult_driver #(parameter WIDTH_A = 8, parameter WIDTH_B = 8, parameter WIDTH_P = 16);
    virtual mult_if#(WIDTH_A, WIDTH_B, WIDTH_P) vif;
    mailbox #(mult_transaction#(WIDTH_A, WIDTH_B, WIDTH_P)) gen2drv;
    
    function new(virtual mult_if#(WIDTH_A, WIDTH_B, WIDTH_P) vif, 
                 mailbox #(mult_transaction#(WIDTH_A, WIDTH_B, WIDTH_P)) g2d);
        this.vif = vif;
        this.gen2drv = g2d;
    endfunction
    
    task reset();
        vif.rst_n <= 0;
        vif.a <= 0;
        vif.b <= 0;
        repeat(3) @(posedge vif.clk);
        vif.rst_n <= 1;
        @(posedge vif.clk);
    endtask
    
    task run();
        mult_transaction#(WIDTH_A, WIDTH_B, WIDTH_P) trans;
        forever begin
            gen2drv.get(trans);
            @(negedge vif.clk);  // Drive on negedge (inputs registered on negedge)
            vif.a <= trans.a;
            vif.b <= trans.b;
            trans.display("DRIVER");
        end
    endtask
endclass

// Adder Tree Multiplier Monitor Class
class mult_monitor #(parameter WIDTH_A = 8, parameter WIDTH_B = 8, parameter WIDTH_P = 16);
    virtual mult_if#(WIDTH_A, WIDTH_B, WIDTH_P) vif;
    mailbox #(mult_transaction#(WIDTH_A, WIDTH_B, WIDTH_P)) mon2scb;
    
    function new(virtual mult_if#(WIDTH_A, WIDTH_B, WIDTH_P) vif, 
                 mailbox #(mult_transaction#(WIDTH_A, WIDTH_B, WIDTH_P)) m2s);
        this.vif = vif;
        this.mon2scb = m2s;
    endfunction
    
    task run();
        mult_transaction#(WIDTH_A, WIDTH_B, WIDTH_P) trans;
        forever begin
            @(posedge vif.clk);  // Sample output on posedge (output registered on posedge)
            trans = new();
            trans.a = vif.a;
            trans.b = vif.b;
            trans.P = vif.P;
            mon2scb.put(trans);
            trans.display("MONITOR");
        end
    endtask
endclass

// Adder Tree Multiplier Scoreboard Class
class mult_scoreboard #(parameter WIDTH_A = 8, parameter WIDTH_B = 8, parameter WIDTH_P = 16);
    mailbox #(mult_transaction#(WIDTH_A, WIDTH_B, WIDTH_P)) mon2scb;
    
    // Pipeline storage to account for 2-cycle latency
    // Cycle 1: Inputs registered on negedge
    // Cycle 2: Output registered on posedge
    mult_transaction#(WIDTH_A, WIDTH_B, WIDTH_P) pipeline[$];
    
    int pass_count, fail_count;
    int latency = 2;  // 2-cycle latency
    
    function new(mailbox #(mult_transaction#(WIDTH_A, WIDTH_B, WIDTH_P)) m2s);
        this.mon2scb = m2s;
        this.pass_count = 0;
        this.fail_count = 0;
    endfunction
    
    function bit [WIDTH_P-1:0] compute_expected(bit [WIDTH_A-1:0] a, bit [WIDTH_B-1:0] b);
        return a * b;
    endfunction
    
    task run();
        mult_transaction#(WIDTH_A, WIDTH_B, WIDTH_P) trans;
        mult_transaction#(WIDTH_A, WIDTH_B, WIDTH_P) expected_trans;
        bit [WIDTH_P-1:0] expected_P;
        
        forever begin
            mon2scb.get(trans);
            
            // Add current transaction to pipeline
            pipeline.push_back(trans);
            
            // Wait for pipeline to fill (latency cycles)
            if (pipeline.size() > latency) begin
                // Get the transaction that should produce current output
                expected_trans = pipeline.pop_front();
                expected_P = compute_expected(expected_trans.a, expected_trans.b);
                
                if (trans.P === expected_P) begin
                    $display("[%0t] SCOREBOARD PASS: %0d x %0d = %0d (Expected=%0d, Got=%0d)", 
                             $time, expected_trans.a, expected_trans.b, expected_P, expected_P, trans.P);
                    pass_count++;
                end else begin
                    $display("[%0t] SCOREBOARD FAIL: %0d x %0d = %0d (Expected=%0d, Got=%0d)", 
                             $time, expected_trans.a, expected_trans.b, expected_P, expected_P, trans.P);
                    fail_count++;
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
        $display("=======================================\n");
    endfunction
endclass

// Adder Tree Multiplier Environment Class
class mult_environment #(parameter WIDTH_A = 8, parameter WIDTH_B = 8, parameter WIDTH_P = 16);
    mult_generator#(WIDTH_A, WIDTH_B, WIDTH_P) gen;
    mult_driver#(WIDTH_A, WIDTH_B, WIDTH_P) drv;
    mult_monitor#(WIDTH_A, WIDTH_B, WIDTH_P) mon;
    mult_scoreboard#(WIDTH_A, WIDTH_B, WIDTH_P) scb;
    
    mailbox #(mult_transaction#(WIDTH_A, WIDTH_B, WIDTH_P)) gen2drv;
    mailbox #(mult_transaction#(WIDTH_A, WIDTH_B, WIDTH_P)) mon2scb;
    
    virtual mult_if#(WIDTH_A, WIDTH_B, WIDTH_P) vif;
    
    function new(virtual mult_if#(WIDTH_A, WIDTH_B, WIDTH_P) vif);
        this.vif = vif;
        gen2drv = new();
        mon2scb = new();
        
        gen = new(gen2drv, 100);
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

// Adder Tree Multiplier Interface
interface mult_if #(parameter WIDTH_A = 8, parameter WIDTH_B = 8, parameter WIDTH_P = 16)
                   (input logic clk);
    logic rst_n;
    logic [WIDTH_A-1:0] a;
    logic [WIDTH_B-1:0] b;
    logic [WIDTH_P-1:0] P;
endinterface

// Adder Tree Multiplier Testbench Top
module adder_tree_mult_layered;
    parameter WIDTH_A = 8;
    parameter WIDTH_B = 8;
    parameter WIDTH_P = 16;
    
    logic clk;
    
    mult_if#(WIDTH_A, WIDTH_B, WIDTH_P) mif(clk);
    
    adder_tree_mult dut (
        .clk(mif.clk),
        .rst_n(mif.rst_n),
        .a(mif.a),
        .b(mif.b),
        .P(mif.P)
    );
    
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end
    
    mult_environment#(WIDTH_A, WIDTH_B, WIDTH_P) env;
    
    initial begin
        env = new(mif);
        env.run();
        #3000;  // Longer time to account for pipeline latency
        env.report();
        $finish;
    end
   
    initial begin
        $dumpfile("adder_tree_mult.vcd");
        $dumpvars(0, adder_tree_mult_layered);
    end
endmodule