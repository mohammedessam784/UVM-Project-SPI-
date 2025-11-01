
import uvm_pkg::*;
`include "uvm_macros.svh"
import SPI_slave_test_pkg::*;
import SPI_slave_shared_pkg::*;

module top();
   bit [2:0] cs;
   bit [3:0] counter;
  bit clk;
  // Clock generation
  initial begin
    forever begin
      #5 clk=~clk;
    end
  end
  // Instantiate the interface and DUT
   SPI_slave_if SPI_slaveif(clk);
   
   SPI_Slave_Golden Golden(SPI_slaveif);

    SLAVE DUT (SPI_slaveif);
    assign cs=DUT.cs;
    assign counter=DUT.counter;


//bind SLAVE SPI_slave_sva  if_sva( SPI_slaveif);
  /// ALSU_DUT ALSU_sva ALSU(ALSUif);
   

  // run test using run_test task
 initial begin
  uvm_config_db #(virtual SPI_slave_if)::set(null,"uvm_test_top","SPI_slave_if",SPI_slaveif);
  run_test("SPI_slave_test");
 end
  
endmodule