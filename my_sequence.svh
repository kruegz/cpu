class my_transaction extends uvm_sequence_item;

  `uvm_object_utils(my_transaction)

  
  rand bit [15:0] instr;

  constraint c_instr { instr >= 0; instr < 65536; }

  function new (string name = "");
    super.new(name);
  endfunction

endclass: my_transaction

class my_sequence extends uvm_sequence#(my_transaction);

  `uvm_object_utils(my_sequence)

  function new (string name = "");
    super.new(name);
  endfunction

  task body;
    
    req = my_transaction::type_id::create("req");
    
    // NOPS
    repeat(1) begin
      start_item(req); 
      req.instr = 16'b0;
      finish_item(req);
    end
    
    // Fibonacci
    forever begin
      
      // ADD r0 r1 -> r2
      start_item(req); 
      req.instr = {4'h6, 4'h0, 4'h1, 4'h2};
      finish_item(req);
      
      // OR r1 r1 -> r0 (MOV r1 -> r0)
      start_item(req); 
      req.instr = {4'h4, 4'h1, 4'h1, 4'h0};
      finish_item(req);
      
      // OR r2 r2 -> r1 (MOV r2 -> r1)
      start_item(req); 
      req.instr = {4'h4, 4'h2, 4'h2, 4'h1};
      finish_item(req);
      
      // JNZ r3 0
      start_item(req); 
      req.instr = {4'h8, 4'h3, 8'h0};
      finish_item(req);
      
    end
    
  endtask: body

endclass: my_sequence
