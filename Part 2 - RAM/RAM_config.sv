package RAM_config_pkg;

  import uvm_pkg::*;
  `include "uvm_macros.svh"

  class RAM_config extends uvm_object;
    `uvm_object_utils(RAM_config)

    // TODO: Add your virtual interface handle(s) here
     virtual RAM_if RAMvif;
    // TODO: Add other config fields (e.g. is_active, clock_period, time_scale...)
    uvm_active_passive_enum is_active;

    function new (string name = "RAM_config");
      super.new(name);
    endfunction
  endclass

endpackage : RAM_config_pkg