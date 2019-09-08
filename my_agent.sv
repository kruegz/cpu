// The agent contains sequencer, driver, and monitor (not included)
class my_agent extends uvm_agent;
  `uvm_component_utils(my_agent)

  my_driver driver;
  uvm_sequencer#(my_transaction) sequencer;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    driver = my_driver ::type_id::create("driver", this);
    sequencer = uvm_sequencer#(my_transaction)::type_id::create("sequencer", this);
  endfunction    

  // In UVM connect phase, we connect the sequencer to the driver.
  function void connect_phase(uvm_phase phase);
    driver.seq_item_port.connect(sequencer.seq_item_export);
  endfunction

  task run_phase(uvm_phase phase);
    // We raise objection to keep the test from completing
    phase.raise_objection(this);
    begin
      my_sequence seq;
      seq = my_sequence::type_id::create("seq");
      seq.start(sequencer);
    end
    // We drop objection to allow the test to complete
    phase.drop_objection(this);
  endtask

endclass