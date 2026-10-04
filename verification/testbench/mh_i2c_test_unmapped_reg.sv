`ifndef MH_I2C_TEST_UNMAPPED_REG_SV
    `define MH_I2C_TEST_UNMAPPED_REG_SV

    class mh_i2c_test_unmapped_reg extends mh_i2c_test_base;
        `uvm_component_utils(mh_i2c_test_unmapped_reg)
        function new(string name = "" , uvm_component parent = null);
            super.new(name , parent);
            // type_override the sequence to use the unmapped register read and write sequences
            mh_i2c_seq_simple_write#(`ADDR_WIDTH)::type_id::set_type_override(mh_i2c_seq_unmapped_reg_write#(`ADDR_WIDTH)::get_type());
            mh_i2c_seq_simple_read#(`ADDR_WIDTH)::type_id::set_type_override(mh_i2c_seq_unmapped_reg_read#(`ADDR_WIDTH)::get_type());
        endfunction

    endclass
`endif