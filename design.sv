
typedef enum logic [3:0] {
  NOP = 4'b0000,
  INC,
  DEC,
  AND,
  OR,
  XOR,
  ADD,
  SUB,
  I8,
  I9,
  I10,
  I11,
  I12,
  I13,
  I14,
  I15
} opcode_e;


// This is the SystemVerilog interface that we will use to connect
// our design to our UVM testbench.
interface cpu_if;
  logic clock, reset;
  logic [15:0] instr; // Instruction
  logic program_en;
  logic [15:0] program_data;
  logic done;
endinterface

interface alu_if;
  logic clock, reset;
  opcode_e opcode;
  logic [31:0] r1;
  logic [31:0] r2;
  logic [31:0] dout;
  
  modport in (input clock, reset, opcode, r1, r2, output dout);
  
endinterface



`include "uvm_macros.svh"

`include "alu.sv"
`include "cpu_checker.sv"

typedef enum logic [3:0] {
  FETCH = 4'b0000,
  DECODE,
  EXECUTE,
  MEM,
  WB
} cpu_state_e;

// This is our design module.
// 
// It is an empty design that simply prints a message whenever
// the clock toggles.
module cpu(cpu_if cif);
  
  import uvm_pkg::*;
  
  parameter RF_WIDTH = 32;
  parameter RF_SIZE = 32;
  parameter IM_SIZE = 1024;
  
  // Register file
  logic [RF_WIDTH-1:0] reg_file [RF_SIZE-1:0];
  
  // Instruction memory
  logic [RF_WIDTH-1:0] instr_mem [IM_SIZE-1:0];
  
  logic clock;
  logic reset;
  opcode_e opcode;
  
  // Instruction register
  logic [RF_SIZE-1:0] instr;
  
  // Register addresses
  logic [3:0] r1addr;
  logic [3:0] r2addr;
  logic [3:0] rdaddr;
  
  // Instruction breakdown
  // |     opcode   |   r1addr   |   r2addr   |  rdaddr   |
  // {15, 14, 13, 12, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1, 0}
  
  assign clock = cif.clock;
  assign reset = cif.reset;
  
  // Register values
  logic [RF_WIDTH-1:0] dout;
  
  
  
  // Instruction pointer
  logic [31:0] instr_ptr;
  logic [31:0] program_ptr;
  
  //assign r1 = rf[r1addr];
  //assign r2 = rf[r2addr];
  
  alu_if aif(.*);
  
  assign aif.clock = clock;
  assign aif.reset = reset;
  //assign aif.opcode = opcode;
  //assign aif.r1 = r1;
  //assign aif.r2 = r2;
  assign dout = aif.dout;
  
  alu alu1(aif);
  
  cpu_state_e cpu_state;
  
  integer i;
  always @(posedge cif.clock) begin
    
    if (cif.program_en == 1) begin
      `uvm_info("CPU", $sformatf("program_en %0d program_data %0d instr_ptr %0d done %0d", cif.program_en, cif.program_data, instr_ptr, cif.done), UVM_MEDIUM)
      if (cif.done == 0) begin
        instr_mem[program_ptr] <= cif.program_data;
        program_ptr <= program_ptr + 1;
        if (program_ptr == 100) begin
        	cif.done <= 1;
        end
      end
    end
    else if (cif.reset == 1) begin
      
      `uvm_info("CPU", $sformatf("%s", cpu_state.name()), UVM_MEDIUM)
      
      
      // Main CPU state machine
      case (cpu_state)
        
        FETCH: begin
          
          instr <= instr_mem[instr_ptr];
          instr_ptr <= instr_ptr + 1;
          
          // Get instruction from instruction memory
          $strobe("instr_ptr=%0h instr=0x%h", instr_ptr, instr);
          
          cpu_state <= DECODE;
          
        end
        
        DECODE: begin
          
          // Split instruction
          opcode <= instr[15:12];
          r1addr <= instr[11:8];
          r2addr <= instr[7:4];
          rdaddr <= instr[3:0];
          
          $strobe("opcode=%h r1addr=%h r2addr=%h rdaddr=%h", opcode, r1addr, r2addr, rdaddr);
          
          cpu_state <= EXECUTE;
          
        end
        
        EXECUTE: begin
          
          // Perform ALU operation
          aif.opcode <= opcode;
          aif.r1 <= reg_file[r1addr];
          aif.r2 <= reg_file[r2addr];
          
          $strobe("opcode=%s r1=%h r2=%h", aif.opcode.name(), aif.r1, aif.r2);
          
          cpu_state <= MEM;
          
        end
        
        MEM: begin
          
          // Get ALU result
          //dout <= aif.dout;
          
          // Perform memory operation
          
          $strobe("dout=%h aif.dout=%h", dout, aif.dout);
          
          cpu_state <= WB;
          
        end
        
        WB: begin
          
          // Write back to register file
          reg_file[rdaddr] <= dout;
          
          $strobe("reg_file[rdaddr]=%h", reg_file[rdaddr]);
          
          cpu_state <= FETCH;
          
        end
        
        default: begin
          
          `uvm_error("CPU", $sformatf("Unknown cpu_state %d %s", cpu_state, cpu_state.name()))
          
        end
        
      endcase
      
    end
    else begin
      
      // RESET
      
      `uvm_info("CPU", "RESET", UVM_MEDIUM)
      
      // Reset register file
      for (i=0; i<RF_SIZE; i++) reg_file[i] <= i;
      
      // Reset instruction memory
      for (i=0; i<IM_SIZE; i++) instr_mem[i] <= i;
      
      // Reset cpu state
      cpu_state <= FETCH;
      
      instr_ptr <= 0;
      program_ptr <= 0;
      
      cif.done <= 0;
      
    end
    
  end
  
  cpu_checker(cif);
  
endmodule
                        
