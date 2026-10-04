`ifndef MH_I2C_REG_MODEL_PKG_SV
    `define MH_I2C_REG_MODEL_PKG_SV

    `include "uvm_macros.svh"
    package mh_i2c_reg_model_pkg;
        import uvm_pkg::*;

        `include "mh_i2c_reg.sv"
        `include "mh_i2c_reg_3_status.sv"
        `include "mh_i2c_reg_file.sv"
        `include "mh_i2c_reg_block.sv"
    endpackage

`endif

