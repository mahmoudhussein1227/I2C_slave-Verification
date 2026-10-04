`ifndef MH_I2C_ITEM_DRV_SV
    `define MH_I2C_ITEM_DRV_SV

    class mh_i2c_item_drv#(int unsigned ADDR_WIDTH = 2) extends mh_i2c_item_base#(ADDR_WIDTH);

        // number or reapted start conditions (1 means only one strart condition)
        rand int unsigned num_starts;

        // number of data bytes driven constraints 
        constraint data_size_default{
            soft data.size() <= 5;
            soft data.size() > 0 ;
        }

        // available register to access
        constraint reg_locations_default{
            soft data[0] inside {[0 : 3]};
        }
    
        `uvm_object_param_utils(mh_i2c_item_drv#(ADDR_WIDTH))
        function new(string name = "");
            super.new(name);
        endfunction

        virtual function string convert2string();
            string result;
            result = $sformatf("num_starts : %0d , %0s" , 
            num_starts , super.convert2string());
            return result;
        endfunction

    endclass

`endif