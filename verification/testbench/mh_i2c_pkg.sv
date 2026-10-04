`ifndef MH_I2C_PKG_SV
    `define MH_I2C_PKG_SV

    `include "uvm_macros.svh"
    `include "mh_i2c_agent_master_pkg.sv"
    `include "mh_i2c_reg_model_pkg.sv"

    package mh_i2c_pkg;
        import uvm_pkg::*;
        import mh_i2c_agent_master_pkg::*;
        import mh_i2c_reg_model_pkg::*;

        `include "mh_i2c_defines.sv"
        `include "mh_i2c_model.sv"
        `include "mh_i2c_predictor.sv"
        `include "mh_i2c_scoreboard.sv"
        `include "mh_i2c_env.sv"

    endpackage

`endif