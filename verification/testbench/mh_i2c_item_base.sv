`ifndef MH_I2C_ITEM_BASE_SV
    `define MH_I2C_ITEM_BASE_SV

    // this class is parametrized with the reg_file address width 
    class mh_i2c_item_base#(int unsigned ADDR_WIDTH = 2) extends uvm_sequence_item;

        //address of target (7-bit address configuration)
        rand logic [6:0] slave_addr;
        // access type (I2C_WRITE/I2C_READ)
        rand i2c_access_type access_type;
        // register location to be accessed
        rand logic [ADDR_WIDTH - 1 : 0] reg_location;
        // write data bytes
        rand logic [7:0] data [$];
        //response (I2C_ACK/I2C_NACK)
        rand i2c_response addr_response;
        rand i2c_response data_response;

        // defualt slave 
        constraint slave_addr_default{
            soft slave_addr == 7'h50;
        }

        `uvm_object_param_utils(mh_i2c_item_base#(ADDR_WIDTH))
        function new(string name = "");
            super.new(name);
        endfunction

        virtual function string convert2string();
            string result = $sformatf("slave_addr : %0h , access_type : %0s , reg_location : %0h , data : %p , addr_response : %0s , data_response : %0s " , 
            slave_addr , access_type.name() , reg_location , data , addr_response.name() , data_response.name());
            return result;
        endfunction


    endclass

`endif