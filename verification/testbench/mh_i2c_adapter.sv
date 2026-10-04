`ifndef MH_I2C_ADAPTER_SV
    `define MH_I2C_ADAPTER_SV

    class mh_i2c_reg_adapter#(int unsigned ADDR_WIDTH = 8) extends uvm_reg_adapter;
        logic[ADDR_WIDTH - 1 : 0] reg_location;

        `uvm_object_param_utils(mh_i2c_reg_adapter#(ADDR_WIDTH))
        function new(string name = "");
            super.new(name);
        endfunction

        virtual function uvm_sequence_item reg2bus(const ref uvm_reg_bus_op rw); 
            // todo
        endfunction

        virtual function void bus2reg(uvm_sequence_item bus_item, ref uvm_reg_bus_op rw);
            mh_i2c_item_mon#(ADDR_WIDTH) item;
            //item = mh_i2c_item_mon#(ADDR_WIDTH)::type_id::create("item");
            if($cast(item , bus_item))begin
                rw.kind = (item.access_type == I2C_WRITE) ? UVM_WRITE : UVM_READ ;
                case (rw.kind)
                    UVM_READ : begin
                        rw.data = item.data_read;
                    end
                    UVM_WRITE : begin
                        rw.data = item.data.pop_front();
                    end
                endcase
                rw.addr = reg_location;
               `uvm_info("ADAPTER" , $sformatf("reg_location = %0d , kind = %0s" , reg_location, rw.kind.name()) , UVM_LOW)
                rw.status = (item.data_response == I2C_ACK) ? UVM_IS_OK : UVM_NOT_OK;
            end
        endfunction

    endclass

`endif