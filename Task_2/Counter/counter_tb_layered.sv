// Layered Testbench of Counter:
// Counter Transaction Class
class counter_transaction #(parameter N = 8);
    rand bit en;
    rand bit up_dn;
    bit [N-1:0] count;
    
    constraint valid_c {
        en dist {1 := 80, 0 := 20};
        up_dn dist {0 := 50, 1 := 50};
    }
    
    function void display(string tag = "");
        $display("[%0t] %s: en=%0b, up_dn=%0s, count=%0d (0x%0h)", 
                 $time, tag, en, up_dn ? "UP" : "DOWN", count, count);
    endfunction
endclass

// Counter Generator Class
class counter_generator #(parameter N = 8);
    mailbox #(counter_transaction#(N)) gen2drv;
    int num_trans;
    
    function new(mailbox #(counter_transaction#(N)) g2d, int n = 100);
        this.gen2drv = g2d;
        this.num_trans = n;
    endfunction
    
    task run();
        counter_transaction#(N) trans;
        repeat(num_trans) begin
            trans = new();
            assert(trans.randomize()) else $fatal("Randomization failed");
            gen2drv.put(trans);
        end
    endtask
endclass

// Counter Driver Class
class counter_driver #(parameter N = 8);
    virtual counter_if#(N) vif;
    mailbox #(counter_transaction#(N)) gen2drv;
    
    function new(virtual counter_if#(N) vif, mailbox #(counter_transaction#(N)) g2d);
        this.vif = vif;
        this.gen2drv = g2d;
    endfunction
    
    task reset();
        vif.rst_n <= 0;
        vif.en <= 0;
        vif.up_dn <= 0;
        repeat(2) @(posedge vif.clk);
        vif.rst_n <= 1;
        @(posedge vif.clk);
    endtask
    
    task run();
        counter_transaction#(N) trans;
        forever begin
            gen2drv.get(trans);
            @(posedge vif.clk);
            vif.en <= trans.en;
            vif.up_dn <= trans.up_dn;
            trans.display("DRIVER");
        end
    endtask
endclass

// Counter Monitor Class
class counter_monitor #(parameter N = 8);
    virtual counter_if#(N) vif;
    mailbox #(counter_transaction#(N)) mon2scb;
    
    function new(virtual counter_if#(N) vif, mailbox #(counter_transaction#(N)) m2s);
        this.vif = vif;
        this.mon2scb = m2s;
    endfunction
    
    task run();
        counter_transaction#(N) trans;
        forever begin
            @(posedge vif.clk);
            trans = new();
            trans.en = vif.en;
            trans.up_dn = vif.up_dn;
            trans.count = vif.count;
            mon2scb.put(trans);
            trans.display("MONITOR");
        end
    endtask
endclass

// Counter Scoreboard Class
class counter_scoreboard #(parameter N = 8);
    mailbox #(counter_transaction#(N)) mon2scb;
    bit [N-1:0] expected_count;
    int pass_count, fail_count;
    
    function new(mailbox #(counter_transaction#(N)) m2s);
        this.mon2scb = m2s;
        this.expected_count = 0;
        this.pass_count = 0;
        this.fail_count = 0;
    endfunction
    
    task run();
        counter_transaction#(N) trans;
        forever begin
            mon2scb.get(trans);
            
            if (trans.count === expected_count) begin
                $display("[%0t] SCOREBOARD PASS: Expected=%0d, Got=%0d", 
                         $time, expected_count, trans.count);
                pass_count++;
            end else begin
                $display("[%0t] SCOREBOARD FAIL: Expected=%0d, Got=%0d", 
                         $time, expected_count, trans.count);
                fail_count++;
            end
            
            // Update expected count for next cycle
            if (trans.en) begin
                if (trans.up_dn) // Count up
                    expected_count = expected_count + 1;
                else // Count down
                    expected_count = expected_count - 1;
            end
        end
    endtask
    
    function void report();
        $display("\n========== SCOREBOARD REPORT ==========");
        $display("Total Passed: %0d", pass_count);
        $display("Total Failed: %0d", fail_count);
        $display("Pass Rate: %.2f%%", (pass_count * 100.0) / (pass_count + fail_count));
        $display("=======================================\n");
    endfunction
endclass

// Counter Environment Class
class counter_environment #(parameter N = 8);
    counter_generator#(N) gen;
    counter_driver#(N) drv;
    counter_monitor#(N) mon;
    counter_scoreboard#(N) scb;
    
    mailbox #(counter_transaction#(N)) gen2drv;
    mailbox #(counter_transaction#(N)) mon2scb;
    
    virtual counter_if#(N) vif;
    
    function new(virtual counter_if#(N) vif);
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
            #100 gen.run();
            drv.run();
            mon.run();
            scb.run();
        join_any
    endtask
    
    function void report();
        scb.report();
    endfunction
endclass

// Counter Interface
interface counter_if #(parameter N = 8)(input logic clk);
    logic rst_n;
    logic en;
    logic up_dn;
    logic [N-1:0] count;
endinterface

// Counter Testbench Top
module counter_tb_layered;
    parameter N = 8;
    logic clk;
    
    counter_if#(N) cif(clk);
    
    counter dut (
        .clk(cif.clk),
        .rst_n(cif.rst_n),
        .en(cif.en),
        .up_dn(cif.up_dn),
        .count(cif.count)
    );
    
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end
    
    counter_environment#(N) env;
    
    initial begin
        env = new(cif);
        env.run();
        #2000;
        env.report();
        $finish;
    end
    
    // Dump waveforms
    initial begin
        $dumpfile("counter.vcd");
        $dumpvars(0, counter_tb_layered);
    end
endmodule