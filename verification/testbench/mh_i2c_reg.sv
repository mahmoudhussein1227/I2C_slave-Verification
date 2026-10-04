`ifndef MH_I2C_REG_SV
    `define MH_I2C_REG_SV

    class mh_i2c_reg extends uvm_reg;
        // data_field
        rand uvm_reg_field REG_DATA_F;

        `uvm_object_utils(mh_i2c_reg)
        function new (string name = "");
            super.new(
                .name(name),
                .n_bits(8),
                .has_coverage(UVM_NO_COVERAGE));
        endfunction

        virtual function void build();
            // create and configure each field;
            REG_DATA_F = uvm_reg_field::type_id::create(.name("REG_DATA_F"),
                                                          .parent(null),
                                                          .contxt(get_full_name()));
            REG_DATA_F.configure(  .parent(this) , 
                                   .size(8),
                                   .lsb_pos(0),
                                   .access("RW"),
                                   .volatile(0),
                                   .reset(0),
                                   .has_reset(1),
                                   .is_rand(1),
                                   .individually_accessible(0)
                                   );
        endfunction


    endclass
    

`endif