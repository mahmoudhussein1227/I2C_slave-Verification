`ifndef MH_I2C_AGENT_MASTER_PKG_SV
    `define MH_I2C_AGENT_MASTER_PKG_SV

    `include "mh_i2c_intf.sv"
    `include "uvm_macros.svh"

    package mh_i2c_agent_master_pkg;
        import uvm_pkg::*;
        
        // types file
        `include "i2c_agent_master_types.sv"
        // reset_handler interface class
        `include "mh_i2c_reset_handler.sv"

        // sequence items
        `include "mh_i2c_item_base.sv"
        `include "mh_i2c_item_drv.sv"
        `include "mh_i2c_item_mon.sv"

        // components
        `include "mh_i2c_agent_master_config.sv"
        `include "mh_i2c_sequencer.sv"
        `include "mh_i2c_driver.sv"
        `include "mh_i2c_monitor.sv"
        `include "mh_i2c_coverage.sv"
        `include "mh_i2c_agent_master.sv"
        

        //sequences
        `include "mh_i2c_seq_simple_write.sv"
        `include "mh_i2c_seq_simple_read.sv"
            // write sequences        
            `include "mh_i2c_seq_illegal_slave_write.sv"
            `include "mh_i2c_seq_ro_write.sv"
            `include "mh_i2c_seq_unmapped_reg_write.sv"

            // read_sequences
            `include "mh_i2c_seq_illegal_slave_read.sv"
            `include "mh_i2c_seq_unmapped_reg_read.sv"
            `include "mh_i2c_seq_ro_read.sv"


        // reg_adapter
        `include "mh_i2c_adapter.sv"
    endpackage

`endif 