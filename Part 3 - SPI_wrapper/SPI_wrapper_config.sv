package SPI_wrapper_config_pkg;

  import uvm_pkg::*;
  `include "uvm_macros.svh"

  class SPI_wrapper_config extends uvm_object;
    `uvm_object_utils(SPI_wrapper_config)

    // TODO: Add your virtual interface handle(s) here
    // Example:
     virtual SPI_wrapper_if SPI_wrappervif;
    // TODO: Add other config fields (e.g. is_active, clock_period, time_scale...)
    uvm_active_passive_enum is_active;

    function new (string name = "SPI_wrapper_config");
      super.new(name);
    endfunction
  endclass

endpackage : SPI_wrapper_config_pkg