`ifndef MH_I2C_SEQ_UNMAPPED_REG_READ_SV
    `define MH_I2C_SEQ_UNMAPPED_REG_READ_SV
    class mh_i2c_seq_unmapped_reg_read#(int unsigned ADDR_WIDTH = 8) extends mh_i2c_seq_simple_read#(ADDR_WIDTH);
        
        constraint unmapped_reg{
            !reg_location inside {[0:3]}; 
        }
        `uvm_object_param_utils(mh_i2c_seq_unmapped_reg_read#(ADDR_WIDTH))
        function new(string name = "");
            super.new(name);
            reg_location_def.constraint_mode(0);
        endfunction

    endclass
`endif