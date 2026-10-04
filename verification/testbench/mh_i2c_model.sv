`ifndef MH_I2C_MODEL_SV
    `define MH_I2C_MODEL_SV

    `uvm_analysis_imp_decl(_in_addr)
    `uvm_analysis_imp_decl(_in_data)
    `uvm_analysis_imp_decl(_in_size)

    class mh_i2c_model#(int unsigned ADDR_WIDTH  = 8) extends uvm_component implements mh_i2c_reset_handler;
        // port to recieve the addr byte content
        uvm_analysis_imp_in_addr#(mh_i2c_item_mon#(ADDR_WIDTH) , mh_i2c_model#(ADDR_WIDTH)) port_in_addr;
        // port to recieve the data byte content
        uvm_analysis_imp_in_data#(mh_i2c_item_mon#(ADDR_WIDTH) , mh_i2c_model#(ADDR_WIDTH)) port_in_data;
        // port to recieve the size of the data queue from the driver
        uvm_analysis_imp_in_size#(int unsigned , mh_i2c_model#(ADDR_WIDTH)) port_in_size;
        // port to send the expected addr response to the scb
        uvm_analysis_port#(i2c_response) port_out_model_addr;
        // port to send the expected data response to the scb
        uvm_analysis_port#(i2c_response) port_out_model_data;

        // reg_block handle
        mh_i2c_reg_block reg_block;

        // slave_addresses
        logic[6:0] slave_addrs[string];

        // size of the data queue
        int unsigned size;

        `uvm_component_param_utils(mh_i2c_model#(ADDR_WIDTH))

        function new(string name = "" , uvm_component parent);
            super.new(name , parent);
            port_in_addr        = new("port_in_addr"        , this);
            port_in_data        = new("port_in_data"        , this);
            port_out_model_addr = new("port_out_model_addr" , this);
            port_out_model_data = new("port_out_model_data" , this);
            port_in_size        = new("port_in_size" , this);
            slave_addrs["slave_0"] = 7'h50;
        endfunction

        virtual function void handle_reset(uvm_phase phase);
            reg_block.reset("HARD");
        endfunction

        virtual function void build_phase(uvm_phase phase);
            super.build_phase(phase);
            // creating reg_block
            if(reg_block == null)begin
                reg_block = mh_i2c_reg_block::type_id::create("reg_block");
                reg_block.build();
                reg_block.lock_model();
            end
        endfunction

        virtual function void write_in_size(int unsigned value);
            size = value;
        endfunction

        // get_exp_addr_resp 
        /*  
            this function is used to generate expected address response
        */
        virtual function i2c_response get_exp_addr_resp(mh_i2c_item_mon#(ADDR_WIDTH) item);
            i2c_response exp_addr_resp = I2C_NACK;
            foreach (slave_addrs[slave_name]) begin
                if(item.slave_addr == slave_addrs[slave_name])begin
                    exp_addr_resp = I2C_ACK;
                    break;
                end
            end

            return exp_addr_resp;
        endfunction
        // get_exp_data_resp 
        /*  
            this function is used to generate expected data response
        */
        virtual function i2c_response get_exp_data_resp(mh_i2c_item_mon#(ADDR_WIDTH) item);
            i2c_response exp_data_response = I2C_ACK;
            uvm_reg register = reg_block.default_map.get_reg_by_offset(item.reg_location);
            if(register == null)begin
                exp_data_response = I2C_NACK;
            end
            else begin
                case (item.access_type)
                I2C_WRITE : begin
                    // check if the register is read only and the operation done is write (size > 1  means that driver has more than the reg_location to drive)
                    // item.data.size() >=1 means that the monitor are monitoring the first data_byte after the reg_location
                    if(register.get_rights(reg_block.default_map) == "RO" && size > 1  && item.data.size() >= 1)begin
                        exp_data_response = I2C_NACK;
                    end    
                end
                I2C_READ : begin
                    
                    exp_data_response = I2C_NACK;
                    
                end
                endcase
            end
            
            return exp_data_response;
        endfunction


        virtual function void write_in_addr(mh_i2c_item_mon#(ADDR_WIDTH) item);
            i2c_response exp_response;
            exp_response = get_exp_addr_resp(item);
            port_out_model_addr.write(exp_response);
        endfunction

        virtual function void write_in_data(mh_i2c_item_mon#(ADDR_WIDTH) item);
            i2c_response exp_response;
            exp_response = get_exp_data_resp(item);
            port_out_model_data.write(exp_response);
            
        endfunction

    endclass

`endif