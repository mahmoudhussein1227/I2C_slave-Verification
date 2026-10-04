`ifndef MH_I2C_SEQ_SIMPLE_READ_SV
    `define MH_I2C_SEQ_SIMPLE_READ_SV

    class mh_i2c_seq_simple_read#(int unsigned ADDR_WIDTH = 2) extends uvm_sequence#(mh_i2c_item_drv#(ADDR_WIDTH));
        rand logic [7:0] reg_location;
        rand logic [6:0] slave_addr;

        // available register to access
        constraint reg_location_def{
           soft reg_location inside {[0 : 3]};
        }
        //defautl slave address
        constraint slave_addr_def{
            soft slave_addr == 7'h50;
        }
        
        `uvm_object_param_utils(mh_i2c_seq_simple_read#(ADDR_WIDTH))
        function new(string name = "");
            super.new(name);
        endfunction

        virtual task body();
            mh_i2c_item_drv#(ADDR_WIDTH) item;

            `uvm_do_with(item , {num_starts    == 2;
                                 data.size()   == 1;
                                 slave_addr    == local::slave_addr;
                                 data[0]       == local::reg_location;
                                 //data[1]       == 8'b11110000;
                                 access_type   == I2C_WRITE;
                                 //data_response == 0;
                                 //pre_drv_delay == 0;
                                 //post_drv_delay== 0; 
                                 })

                `uvm_do_with(item , {num_starts   == 1;
                                 data.size()   == 1;
                                 slave_addr    == local::slave_addr;
                                 //data[0]       == 2'h0;
                                 //data[1]       == 8'b11110000;
                                 access_type   == I2C_READ;
                                 data_response == 1'b1;
                                 //pre_drv_delay == 0;
                                 //post_drv_delay== 0; 
                                 })
        endtask
    endclass


`endif