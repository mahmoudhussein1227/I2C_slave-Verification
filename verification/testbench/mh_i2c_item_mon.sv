`ifndef MH_I2C_ITEM_MON_SV
    `define MH_I2C_ITEM_MON_SV

    class mh_i2c_item_mon#(int unsigned ADDR_WIDTH = 2) extends mh_i2c_item_base#(ADDR_WIDTH);

        // 0 means a back2back I2C accesses
        //int unsigned prev_item_delay;
        // data read from the i2c regfile
        logic [7:0] data_read;
        
        `uvm_object_param_utils(mh_i2c_item_mon#(ADDR_WIDTH))
        function new(string name = "");
            super.new(name);
        endfunction

        virtual function string convert2string();
            string result;
            result = $sformatf("%0s , read_data : %0h", super.convert2string() , data_read );
            return result;
        endfunction

    endclass

`endif