module cpu_checker(cpu_if cif);

  assign clock = cif.clock;
  assign reset = cif.reset;
  assign opcode = cif.instr[15:12];
  assign data = cif.instr[12:0];
  assign r1 = cif.instr[11:8];
  assign r2 = cif.instr[7:4];
  
  covergroup cpu_cg;
    
    opcode_cp: coverpoint opcode;
    
    r1_cp: coverpoint r1;
    r2_cp: coverpoint r2;
    
  endgroup;
  
endmodule