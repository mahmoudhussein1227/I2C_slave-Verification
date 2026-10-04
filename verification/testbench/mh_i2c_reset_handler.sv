`ifndef MH_I2C_RESET_HANDLER_SV
    `define MH_I2C_RESET_HANDLER_SV

    interface class mh_i2c_reset_handler;

        pure virtual function void handle_reset(uvm_phase phase);
        
    endclass

`endif