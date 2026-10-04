`ifndef MH_I2C_REG_BLOCK_SV
    `define MH_I2C_REG_BLOCK_SV

    class mh_i2c_reg_block extends uvm_reg_block;

        rand mh_i2c_reg_file I2C_REGFILE;

        `uvm_object_utils(mh_i2c_reg_block)
        function new(string name = "");
            super.new(.name(name), .has_coverage(UVM_NO_COVERAGE));
        endfunction

        virtual function void build();
            default_map = create_map(.name("i2c_map"),
                                     .base_addr(0),
                                     .n_bytes(1),
                                     .endian(UVM_LITTLE_ENDIAN),
                                     .byte_addressing(0));

            default_map.set_check_on_read(1);

            // creating the registerfile 
            I2C_REGFILE =  mh_i2c_reg_file::type_id::create(.name("I2C_REGFILE") , 
                                                            .parent(null),
                                                            .contxt(get_full_name()));

            // configure it
            I2C_REGFILE.configure(.blk_parent(this) , .regfile_parent(null));
            // calling its build
            I2C_REGFILE.build();
            // calling its map
            I2C_REGFILE.map(.mp(default_map) , .offset(0));
        endfunction
    endclass

`endif