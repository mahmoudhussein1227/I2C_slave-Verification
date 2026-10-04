`ifndef MH_I2C_TEST_PKG_SV
    `define MH_I2C_TEST_PKG_SV

    `include "uvm_macros.svh"
    `include "mh_i2c_pkg.sv"
    
    package mh_i2c_test_pkg;
        import uvm_pkg::*;
        import mh_i2c_pkg::*;
        import mh_i2c_agent_master_pkg::*;

        bit mh_i2c_test_error_seen = 0;

        class mh_i2c_test_error_catcher extends uvm_report_catcher;
            function new(string name = "mh_i2c_test_error_catcher");
                super.new(name);
            endfunction

            virtual function action_e catch();
                if (get_severity() == UVM_ERROR) begin
                    mh_i2c_test_error_seen = 1;
                end
                return THROW;
            endfunction
        endclass

        `include "mh_i2c_test_base.sv"  
        `include "mh_i2c_test_unmapped_reg.sv"  
        `include "mh_i2c_test_illegal_slave.sv"  
        `include "mh_i2c_test_ro_reg.sv" 
        `include "mh_i2c_test_reset_ongoing.sv" 

    endpackage

`endif