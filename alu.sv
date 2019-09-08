module alu(alu_if.in aif);
  
  import uvm_pkg::*;
  
  always @(posedge aif.clock) begin
    
    case (aif.opcode)
      
      NOP: aif.dout <= 0;
      
      INC: aif.dout <= aif.r1 + 1;
      
      DEC: aif.dout <= aif.r1 - 1;
      
      AND: aif.dout <= aif.r1 & aif.r2;
      
      OR: aif.dout <= aif.r1 | aif.r2;
      
      XOR: aif.dout <= aif.r1 ^ aif.r2;
      
      ADD: aif.dout <= aif.r1 + aif.r2;
      
      SUB: aif.dout <= aif.r1 - aif.r2;
      
      default: aif.dout <= 0;
      
    endcase
    
    //$strobe("ALU %s %h %h %h", aif.opcode.name(), aif.r1, aif.r2, aif.dout);
    
    // TODO: add status register
    
  end
  
endmodule