`ifndef MH_I2C_SEQ_ILLEGAL_SLAVE_WRITE_SV
    `define MH_I2C_SEQ_ILLEGAL_SLAVE_WRITE_SV

    class mh_i2c_seq_illegal_slave_write#(int unsigned ADDR_WIDTH = 8) extends mh_i2c_seq_simple_write#(ADDR_WIDTH);

        constraint illegal_slave_addr{
            slave_addr != 7'h50; 
        }
        
        `uvm_object_param_utils(mh_i2c_seq_illegal_slave_write#(ADDR_WIDTH))
        function new(string name = "");
            super.new(name);
            slave_addr_def.constraint_mode(0);
        endfunction


    endclass

`endif