class my_driver extends uvm_driver #(my_transaction);

  `uvm_component_utils(my_driver)

  virtual cpu_if cpu_vif;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    // Get interface reference from config database
    if(!uvm_config_db#(virtual cpu_if)::get(this, "", "cpu_vif", cpu_vif)) begin
      `uvm_error("", "uvm_config_db::get failed")
    end
  endfunction 

  task run_phase(uvm_phase phase);
    // First toggle reset
    cpu_vif.reset = 1;
    @(posedge cpu_vif.clock);
    #1;
    cpu_vif.reset = 0;
    
    // Now drive normal traffic
    forever begin
      seq_item_port.get_next_item(req);

      // Wiggle pins of DUT
      cpu_vif.instr  = req.instr;
      
      repeat (5) @(posedge cpu_vif.clock);

      seq_item_port.item_done();
    end
  endtask

endclass: my_driver
