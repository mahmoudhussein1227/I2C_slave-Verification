`ifndef MH_I2C_TEST_ILLEGAL_SLAVE_SV
    `define MH_I2C_TEST_ILLEGAL_SLAVE_SV

    class mh_i2c_test_illegal_slave extends mh_i2c_test_base;
        `uvm_component_utils(mh_i2c_test_illegal_slave)
        function new(string name = "" , uvm_component parent = null);
            super.new(name , parent);
            // type_override the sequence to use the illegal slave read and write sequences
            mh_i2c_seq_simple_write#(`ADDR_WIDTH)::type_id::set_type_override(mh_i2c_seq_illegal_slave_write#(`ADDR_WIDTH)::get_type());
            mh_i2c_seq_simple_read#(`ADDR_WIDTH)::type_id::set_type_override(mh_i2c_seq_illegal_slave_read#(`ADDR_WIDTH)::get_type());
        endfunction

    endclass

`endif