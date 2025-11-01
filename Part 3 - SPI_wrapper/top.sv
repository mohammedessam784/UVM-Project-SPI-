
import uvm_pkg::*;
`include "uvm_macros.svh"
import SPI_wrapper_test_pkg::*;
import SPI_wrapper_shared_pkg::*;


module top();

  bit clk;
  // Clock generation
  initial begin
    forever begin
      #5 clk=~clk;
    end
  end

  // Instantiate the interface and DUT
   SPI_wrapper_if SPI_wrapperif(clk);
   SPI_slave_if SPI_slaveif(clk);
   RAM_if RAMif(clk);

   //SPI_wrapper dut (.SPI_wrapperif(SPI_wrapperif) );
   //SPI_wrapper_ref dut_ref (.SPI_wrapperif(SPI_wrapperif) );
  

   WRAPPER DUT (SPI_wrapperif);
   WRAPPER_Golden REF (SPI_wrapperif);
    
  /*
wire [9:0] rx_data_din;
wire       rx_valid;
wire       tx_valid;
wire [7:0] tx_data_dout;
  */

  assign SPI_slaveif.MOSI      = SPI_wrapperif.MOSI;
  assign SPI_slaveif.rst_n     = SPI_wrapperif.rst_n;
  assign SPI_slaveif.SS_n      = SPI_wrapperif.SS_n;
  assign SPI_slaveif.tx_valid  = DUT.SLAVE_instance.tx_valid;
  assign SPI_slaveif.tx_data   = DUT.SLAVE_instance.tx_data;

    assign SPI_slaveif.rx_data      = DUT.SLAVE_instance.rx_data;
    assign SPI_slaveif.rx_valid     = DUT.SLAVE_instance.rx_valid;
    assign SPI_slaveif.MISO         = SPI_slaveif.MISO;
    assign SPI_slaveif.rx_data_ref  = REF.SLAVE_inst.rx_data;
    assign SPI_slaveif.rx_valid_ref = REF.SLAVE_inst.rx_valid;
    assign SPI_slaveif.MISO_ref     = SPI_slaveif.MISO_ref;


    assign RAMif.din         = DUT.RAM_instance.din;
    assign RAMif.rst_n       = DUT.RAM_instance.rst_n;
    assign RAMif.rx_valid    = DUT.RAM_instance.rx_valid;
    assign RAMif.dout        = DUT.RAM_instance.dout;
    assign RAMif.tx_valid    = DUT.RAM_instance.tx_valid;
    assign RAMif.dout_ref    = REF.RAM_inst.dout;
    assign RAMif.tx_valid_ref= REF.RAM_inst.tx_valid;


  //  bind the SVA module to the design, and pass the interface
   bind WRAPPER SPI_wrapper_sva inst_sva (SPI_wrapperif);


 initial begin
   $readmemb("mem.dat", DUT.RAM_instance.MEM);
   $readmemb("mem.dat", REF.RAM_inst.mem);
  uvm_config_db #(virtual SPI_wrapper_if)::set(null,"uvm_test_top","SPI_wrapper_if",SPI_wrapperif);
  uvm_config_db #(virtual SPI_slave_if)::set(null,"uvm_test_top","SPI_slave_if",SPI_slaveif);
  uvm_config_db #(virtual RAM_if)::set(null,"uvm_test_top","RAM_if",RAMif);
  run_test("SPI_wrapper_test");
 end
  
endmodule