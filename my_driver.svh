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
  
  task reset_phase(uvm_phase phase);
      // We raise objection to keep the test from completing
      phase.raise_objection(this);
    
      // Initial conditions
      cpu_vif.reset = 0;
      cpu_vif.program_en = 0;
      repeat(5) @(posedge cpu_vif.clock);
      
      // First toggle reset
      cpu_vif.reset = 0;
      @(posedge cpu_vif.clock);
      cpu_vif.reset = 0;
      @(posedge cpu_vif.clock);
      cpu_vif.reset = 1;
      @(posedge cpu_vif.clock);
      
      phase.drop_objection(this);
    endtask

  task run_phase(uvm_phase phase);
    
    cpu_vif.program_en = 1;
    
    // Program
    repeat (100) begin
      seq_item_port.get_next_item(req);
      cpu_vif.program_en = 1;
   	  cpu_vif.program_data = req.instr;
      
      seq_item_port.item_done();
      @(posedge cpu_vif.clock);
    end
    
    // Stop programming
    cpu_vif.program_en = 0;
    
    // Now drive normal traffic
    //forever begin
      
      //repeat (5) @(posedge cpu_vif.clock);
      
    //end
  endtask

endclass: my_driver
