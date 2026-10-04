`ifndef MH_I2C_SEQ_RO_WRITE_SV
    `define MH_I2C_SEQ_RO_WRITE_SV

    class mh_i2c_seq_ro_write#(int unsigned ADDR_WIDTH = 8) extends mh_i2c_seq_simple_write#(ADDR_WIDTH);
        constraint ro_reg{
            reg_location == 3;
        }
        `uvm_object_param_utils(mh_i2c_seq_ro_write#(ADDR_WIDTH))
        function new(string name = "");
            super.new(name);
            reg_location_def.constraint_mode(0);
        endfunction

    endclass
`endif