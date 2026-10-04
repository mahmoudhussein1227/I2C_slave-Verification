`ifndef MH_I2C_REG_FILE_SV
    `define MH_I2C_REG_FILE_SV
    
    class mh_i2c_reg_file extends uvm_reg_file ;

        // registers
        rand mh_i2c_reg I2C_REG[3];
        rand mh_i2c_reg_3_status STATUS_REG; 

        `uvm_object_utils(mh_i2c_reg_file)
        function new(string name = "");
            super.new(.name(name));
        endfunction

        virtual function void build();
            uvm_reg_block blk_parent = get_parent();
            // create the registers and configure them
            foreach (I2C_REG[i]) begin
                string reg_name = $sformatf("I2C_REG_%0d" , i);
                I2C_REG[i] = mh_i2c_reg::type_id::create(.name(reg_name),
                                                         .parent(null),
                                                         .contxt(get_full_name()));
            end

            STATUS_REG = mh_i2c_reg_3_status::type_id::create(.name("STATUS_REG") , 
                                                             .parent(null),
                                                            .contxt(get_full_name()));

            // configure
            foreach (I2C_REG[i]) begin
                I2C_REG[i].configure(.blk_parent(blk_parent),
                                     .regfile_parent(this));
            end

            STATUS_REG.configure(.blk_parent(blk_parent),
                                 .regfile_parent(this));

            // call build method of each reg

            foreach (I2C_REG[i]) begin
                I2C_REG[i].build();
            end

            STATUS_REG.build();

        endfunction

        virtual function void map(uvm_reg_map mp, uvm_reg_addr_t offset);
            foreach (I2C_REG[i]) begin
                mp.add_reg(.rg(I2C_REG[i]), 
                           .offset(offset+i),
                           .rights("RW"));
            end
            mp.add_reg(.rg(STATUS_REG),
                       .offset(offset + 3),
                       .rights("RO"));
        endfunction

    endclass

`endif