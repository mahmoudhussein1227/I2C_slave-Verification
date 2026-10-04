`ifndef MH_I2C_PREDICTOR_SV
    `define MH_I2C_PREDICTOR_SV

    class mh_i2c_predictor#(type BUSTYPE = uvm_sequence_item , int unsigned ADDR_WIDTH = 8) extends uvm_reg_predictor#(.BUSTYPE(BUSTYPE));
        
        
        `uvm_component_param_utils(mh_i2c_predictor#(BUSTYPE))
        function new(string name = "" , uvm_component parent);
            super.new(name , parent);
        endfunction

        virtual function void write(BUSTYPE tr);
            mh_i2c_item_mon#(ADDR_WIDTH) item;
            if($cast(item , tr))begin
               
                case (item.access_type)
                    I2C_WRITE : begin
                        // saving the register location for the next read access
                        mh_i2c_reg_adapter#(ADDR_WIDTH) adapter_custom;
                        if($cast(adapter_custom , adapter))begin
                            adapter_custom.reg_location = item.reg_location;
                        end
                        // skips the register location byte 
                        if(item.data.size() >= 1)begin
                            super.write(tr);
                        end
                    end
                    I2C_READ : begin
                        super.write(tr);
                    end   
                endcase
            end
         
        endfunction
    endclass
`endif