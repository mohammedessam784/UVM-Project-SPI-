
import uvm_pkg::*;
`include "uvm_macros.svh"
import RAM_test_pkg::*;
import RAM_shared_pkg::*;

module top();

  bit clk;
  // Clock generation
  initial begin
    forever begin
      #5 clk=~clk;
    end
  end
  // Instantiate the interface and DUT
   RAM_if RAMif(clk);
   RAM dut (.RAMif(RAMif) );
   RAM_ref dut_ref (.RAMif(RAMif) );

  //  bind the SVA module to the design, and pass the interface
   bind RAM RAM_sva inst_sva (RAMif);


 initial begin
  uvm_config_db #(virtual RAM_if)::set(null,"uvm_test_top","RAM_if",RAMif);
  run_test("RAM_test");
 end
  
endmodule