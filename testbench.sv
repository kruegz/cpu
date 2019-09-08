/*******************************************
This is a basic UVM "Hello World" testbench.

Explanation of this testbench on YouTube:
https://www.youtube.com/watch?v=Qn6SvG-Kya0
*******************************************/

`include "uvm_macros.svh"
`include "my_testbench_pkg.svh"

// The top module that contains the DUT and interface.
// This module starts the test.
module top;
  import uvm_pkg::*;
  import my_testbench_pkg::*;
  
  // Instantiate the interface
  cpu_if cpu_if1();
  
  // Instantiate the DUT and connect it to the interface
  cpu cpu1(.cif(cpu_if1));
  
  // Clock generator
  initial begin
    cpu_if1.clock = 0;
    forever #5 cpu_if1.clock = ~cpu_if1.clock;
  end
  
  initial begin
    // Place the interface into the UVM configuration database
    uvm_config_db#(virtual cpu_if)::set(null, "*", "cpu_vif", cpu_if1);
    // Start the test
    run_test("my_test");
    $display($get_coverage());
  end
  
  // Dump waves
  initial begin
    $dumpfile("dump.vcd");
    $dumpvars(0, top);
  end
  
endmodule
