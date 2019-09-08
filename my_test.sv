class my_test extends uvm_test;
  `uvm_component_utils(my_test)

  my_env env;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    env = my_env::type_id::create("env", this);
  endfunction

  task run_phase(uvm_phase phase);
    // We raise objection to keep the test from completing
    phase.raise_objection(this);
    #10;
    //`uvm_warning("", "Hello World!")
    // We drop objection to allow the test to complete
    phase.drop_objection(this);
  endtask

endclass