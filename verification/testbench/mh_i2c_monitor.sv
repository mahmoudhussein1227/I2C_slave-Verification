`ifndef MH_I2C_MONITOR_SV
    `define MH_I2C_MONITOR_SV

    class mh_i2c_monitor#(int unsigned ADDR_WIDTH = 2) extends uvm_monitor implements mh_i2c_reset_handler;
        // agent_config handle
        mh_i2c_agent_master_config agent_config;
        // vif handle
        i2c_vif vif;

        //process collect_transacions handle
        process process_collect_transactions;
        
        // address_frame output port
        uvm_analysis_port#(mh_i2c_item_mon#(ADDR_WIDTH)) port_out_addr;

        // data_frame output port
        uvm_analysis_port#(mh_i2c_item_mon#(ADDR_WIDTH)) port_out_data;

        uvm_analysis_imp#(int unsigned  , mh_i2c_monitor#( ADDR_WIDTH )) port_in_size;

        int unsigned size ;
        `uvm_component_param_utils(mh_i2c_monitor#(ADDR_WIDTH))
        function new(string name= "" , uvm_component parent);
            super.new(name , parent);
            port_out_addr = new("port_out_addr" , this);
            port_out_data = new("port_out_data" , this);
            port_in_size = new("port_in_size" , this);
        endfunction

        virtual function void handle_reset(uvm_phase phase);
            if(process_collect_transactions != null)begin
                process_collect_transactions.kill();

                process_collect_transactions = null;
            end
        endfunction

        virtual function void write(int unsigned value);
            size = value;
        endfunction

        // sample_start
        /*
            this function is used to detect the start condition
        */
        virtual task sample_start( output bit start_detected);
            vif = agent_config.get_vif();
            forever begin
                @(negedge vif.sda_wand);
                //`uvm_info("SAMPlE_START" , "here" , UVM_LOW)
                if(vif.scl == 1)begin
                    start_detected = 1'b1;
                    return;
                end
                else begin
                    start_detected = 0;
                    
                end
            end  
        endtask

        // sample_stop
        /*
            this function is used to detect the stop condition
        */
        virtual task sample_stop(output bit stop_detected);
            vif = agent_config.get_vif();
            forever begin
                 @(posedge vif.sda_wand);
                //`uvm_info("SAMPlE_STOP" , "here" , UVM_LOW)
                if(vif.scl == 1'b1)begin
                    stop_detected = 1'b1;
                    return; 
                end
                else begin
                    stop_detected = 0;
                    
                end
            end

        endtask

        // sample_bit 
        /*
            this task is used to sample SDA bit 
        */
        virtual task sample_bit(output bit sampled_bit);
            vif = agent_config.get_vif();
            @(posedge vif.scl);
            #(agent_config.get_scl_t_high() / 2);
            sampled_bit = vif.sda_wand;
            #(agent_config.get_scl_t_high() / 2);
            //#(agent_config.get_t_hold());
        endtask

        virtual task sample_byte(output logic [7:0] sampled_byte);
            for(int i = 7; i >= 0 ; i--)begin
                logic sampled_bit;
                sample_bit(sampled_bit);
                `uvm_info("MONITOR" , $sformatf("bit_sampled : %0b" , sampled_bit) , UVM_HIGH)
                sampled_byte[i] = sampled_bit;
            end
        endtask


        // collect_transaction
        virtual task collect_transaction(mh_i2c_item_mon#(ADDR_WIDTH) item);
            bit start_detected;
            bit stop_detected;
            logic [6:0] slave_addr;
            logic access_type;
            logic addr_response;
            logic [7:0] sampled_byte;
            logic data_response;
            bit   repeated_start;
            vif = agent_config.get_vif();

            `uvm_info("MONITOR", "Waiting for I2C START condition", UVM_MEDIUM)
            //@(posedge vif.scl);
            sample_start( start_detected);
            `uvm_info("MONITOR", $sformatf("START detection completed: start_detected=%0b", start_detected), UVM_MEDIUM)
            if(start_detected) begin
                do begin
                    // sample slave_address + RW bit + ACK bit
                    sample_byte({slave_addr , access_type});
                    item.slave_addr = slave_addr;
                    item.access_type = i2c_access_type'(access_type);
                    `uvm_info("MONITOR", $sformatf("Address sampled: slave_addr=0x%02h access_type=%0s", item.slave_addr, item.access_type.name()), UVM_MEDIUM)
                    sample_bit(addr_response);
                    item.addr_response = i2c_response'(addr_response);
                    
                    port_out_addr.write(item);
                    
                    `uvm_info("MONITOR", $sformatf("Address response sampled: addr_response=%0s", item.addr_response.name()), UVM_MEDIUM)
                    if(item.addr_response == I2C_NACK)begin
                        //@(posedge vif.scl);
                        sample_stop(stop_detected);
                        if(stop_detected)begin
                            `uvm_info("MONITOR", "STOP detected after address NACK", UVM_MEDIUM)
                           
                            return;
                        end
                    end
                    // sample data 
                    case(item.access_type) 
                        I2C_WRITE: begin
                            bit stop;
                            //int i = 0;
                            `uvm_info("MONITOR", $sformatf("Collecting I2C write data , size = %0d" , size), UVM_HIGH)
                            for(int i = 0 ; i< size ; i ++) begin
                                
                                bit stop_data;
                                sample_byte(sampled_byte);
                                if(i == 0)begin
                                    item.reg_location = sampled_byte;
                                    `uvm_info("MONITOR", $sformatf("Register location sampled: reg_location=0x%0h", item.reg_location), UVM_MEDIUM)
                                end
                                else if(i >= 1) begin
                                    item.data.push_back(sampled_byte);
                                    `uvm_info("MONITOR", $sformatf("Data byte sampled: index=%0d data=0x%0h", i, item.data[i - 1]), UVM_MEDIUM)
                                end

                               
                                sample_bit(data_response);
                                item.data_response = i2c_response'(data_response);

                                `uvm_info("DATA" , $sformatf("data : %p "  , item.data) , UVM_HIGH)

                                port_out_data.write(item);

                                `uvm_info("MONITOR", $sformatf("Data response sampled: data_response=%0s", item.data_response.name()), UVM_MEDIUM)
                                if(item.data_response == I2C_NACK)begin
                                    //@(posedge vif.scl);
                                    sample_stop(stop_data);
                                    if(stop_data)begin
                                        `uvm_info("MONITOR", "STOP detected after data NACK", UVM_MEDIUM)
                                        return;                                
                                    end
                                end
                            end

                            `uvm_info("MONITOR", "Checking for STOP or repeated START", UVM_MEDIUM)
                                fork    
                                    begin
                                        sample_stop(stop);
                                    end
                                    begin
                                        sample_start(repeated_start);
                                    end
                                    
                                join_any
                                disable fork;     
                                
                                if(stop)begin
                                    `uvm_info("MONITOR", "STOP detected; write transaction complete" , UVM_MEDIUM)
                                    return;
                                end
                                else if(repeated_start)begin
                                    `uvm_info("MONITOR", "Repeated START detected; collecting next address", UVM_MEDIUM)
                                    continue;    
                                end 
                        end
                        I2C_READ: begin
                            //sample the data read from the slave
                            bit stop;
                            logic [7:0] data_read;
                            `uvm_info("MONITOR", "Collecting I2C read data", UVM_MEDIUM)
                            sample_byte(data_read);
                            item.data_read = data_read;
                            `uvm_info("MONITOR", $sformatf("Read data byte sampled: data=0x%02h", item.data_read), UVM_MEDIUM)
                            // smaple the data_response from the driver
                            sample_bit(data_response);
                            item.data_response =i2c_response'(data_response);

                            port_out_data.write(item);

                            `uvm_info("MONITOR", $sformatf("Read data response sampled: data_response=%0s", item.data_response.name()), UVM_MEDIUM)

                            if(item.data_response == I2C_NACK)begin
                                `uvm_info("MONITOR", "Read data NACK detected; checking for STOP", UVM_MEDIUM)
                                sample_stop(stop_detected);
                                if(stop_detected)begin
                                    `uvm_info("MONITOR", "STOP detected after read data NACK", UVM_MEDIUM)
                                    return;
                                end
                            end

                            `uvm_info("MONITOR", "Checking for STOP or repeated START", UVM_MEDIUM)
                            fork    
                                begin;
                                    sample_stop(stop);
                                end
                                begin
                                    //@(posedge vif.scl);
                                    sample_start(repeated_start);
                                end
                                
                            join_any
                            disable fork;     
                            
                            if(stop)begin
                                `uvm_info("MONITOR", "STOP detected; read transaction complete ", UVM_MEDIUM)
                                //`uvm_info("MONITOR", $sformatf("Write data byte complete: %s", item.convert2string()), UVM_MEDIUM)
                                //`uvm_info("MONITOR _ end of transaction" , $sformatf("monitored_item : %0s" , item.convert2string()) , UVM_LOW)
                                return;
                            end
                            else if(repeated_start)begin
                                `uvm_info("MONITOR", "Repeated START detected after read data; collecting next address", UVM_MEDIUM)
                                continue;    
                            end
                        end
                    endcase

                end
                while(repeated_start);
            end  
        endtask

        // collect_transactions
        virtual task collect_transactions();
            fork
                begin
                    process_collect_transactions = process::self();
                    forever begin
                        mh_i2c_item_mon#(ADDR_WIDTH) item = mh_i2c_item_mon#(ADDR_WIDTH)::type_id::create("item");
                        collect_transaction(item);
                    end
                end
            join
            
        endtask

        // run_phase
        virtual task run_phase(uvm_phase phase);
            forever begin
                agent_config.wait_reset_end();
                collect_transactions();
            end
        endtask

    endclass

`endif