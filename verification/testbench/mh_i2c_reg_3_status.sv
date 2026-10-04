`ifndef MH_I2C_REG_3_STATUS_SV
    `define MH_I2C_REG_3_STATUS_SV

    class mh_i2c_reg_3_status extends uvm_reg;
        // data_field (Read-Only status field)
        uvm_reg_field REG_3_STATUS_DATA_F;

        `uvm_object_utils(mh_i2c_reg_3_status)
        function new (string name = "");
            super.new(
                .name(name),
                .n_bits(8),
                .has_coverage(UVM_NO_COVERAGE));
        endfunction

        virtual function void build();
            // create and configure each field;
            REG_3_STATUS_DATA_F = uvm_reg_field::type_id::create(.name("REG_3_STATUS_DATA_F"),
                                                                 .parent(null),
                                                                 .contxt(get_full_name()));
            REG_3_STATUS_DATA_F.configure(.parent(this), 
                                          .size(8),
                                          .lsb_pos(0),
                                          .access("RO"),
                                          .volatile(0),
                                          .reset(0),
                                          .has_reset(1),
                                          .is_rand(0),
                                          .individually_accessible(0)
                                          );
        endfunction

    endclass

`endif
