`ifndef MH_I2C_DRIVER_SV
    `define MH_I2C_DRIVER_SV

    class mh_i2c_driver#(int unsigned ADDR_WIDTH = 2) extends uvm_driver#(mh_i2c_item_drv#(ADDR_WIDTH)) implements mh_i2c_reset_handler;
        i2c_vif vif;
        mh_i2c_agent_master_config agent_config;
        process process_drive_transaction;
        uvm_analysis_port#(int unsigned) port_out_size;

        `uvm_component_param_utils(mh_i2c_driver#(ADDR_WIDTH))
        function new(string name = "" , uvm_component parent);
            super.new(name , parent);
            port_out_size = new("port_out_size" , this);
        endfunction

        virtual function void handle_reset(uvm_phase phase);
            if(process_drive_transaction != null)begin
                process_drive_transaction.kill();

                process_drive_transaction = null;
            end
        endfunction

        // scl_drive_0
        /*
            this task is used to drive scl line to 0 
        */
        virtual task scl_drive_0();
            vif = agent_config.get_vif();
            vif.scl <= 0;
        endtask

        // scl_release
        /*
            this task is used to release the scl line
        */
        virtual task scl_release();
            vif = agent_config.get_vif();
            vif.scl <= 1;
        endtask

        // sda_drive_0
        /*
            this task is used to drive sda line to 0 
        */
        virtual task sda_drive_0();
            vif = agent_config.get_vif();
            vif.sda <= 0;
        endtask

        // sda_release
        /*
            this task is used to release the sda line
        */
        virtual task sda_release();
            vif = agent_config.get_vif();
            vif.sda <= 1;
        endtask

        // drive_start
        /*
            this task is used to perform start condtion on the sda and scl lines
        */ 
        virtual task drive_start();
            vif = agent_config.get_vif();
            sda_release();
            @(posedge vif.clk);
            @(posedge vif.clk);
            scl_release();
            
            #(agent_config.get_t_bus_f());
            sda_drive_0();
            #(agent_config.get_t_hold()); // small amount of time that scl is high
            scl_drive_0();
        endtask
         
        // drive_stop
        /*
            this task is used to perform stop condition on the sda and scl lines
        */
        virtual task drive_stop();
            vif = agent_config.get_vif();
            sda_drive_0();
            @(posedge vif.clk);
            @(posedge vif.clk);
            scl_release();
            #(agent_config.get_t_hold());
            sda_release();
            // wait period
            #(agent_config.get_t_bus_f());
        endtask

        // drive_bit 
        /*
            this task is used to toggles sda lines
        */
        virtual task drive_bit(bit value);
            vif = agent_config.get_vif();
            scl_drive_0();
            #(agent_config.get_t_hold());
            vif.sda <= value;
            #(agent_config.get_t_setup());
            scl_release();
            #(agent_config.get_scl_t_high());
            scl_drive_0();
            #(agent_config.get_t_hold());
        endtask

        // sample_bit
        /*
            this task is used to sample sda line usign the scl 
        */
        virtual task sample_bit(output bit value);
            vif = agent_config.get_vif();
            // ensure that we release the line of sda for the slave
            sda_release();
            #(agent_config.get_t_setup());
            scl_release();
            #(agent_config.get_scl_t_high() / 2);
           // `uvm_info("DRIVER" , $sformatf("Sampling bit: %0b" , vif.sda) , UVM_LOW)
            value = vif.sda_wand;
            #(agent_config.get_scl_t_high() / 2);
            scl_drive_0();
            //sda_drive_0();
            #(agent_config.get_t_hold());
        endtask

        // drive_byte 
        /*
            this task is used to drive byte
        */
        virtual task drive_byte(logic[7:0] value);
            for(int i = 7 ; i>=0 ; i--)begin
                drive_bit(value[i]); // drive MSB bit first
                 `uvm_info("DRIVER" , $sformatf("Driving bit: %0b" , value[i]) , UVM_HIGH)
            end
        endtask



        virtual task drive_transaction(mh_i2c_item_drv#(ADDR_WIDTH) item);
            vif = agent_config.get_vif();
            `uvm_info("DRIVER" , $sformatf("Starting transaction: %0s" , item.convert2string()) , UVM_LOW)
            
           
            for(int i = 0 ; i < item.num_starts ; i++)begin
                bit addr_ack;
                // start condition
                `uvm_info("DRIVER" , $sformatf("START condition (%0d/%0d)" , i + 1 , item.num_starts) , UVM_LOW)
                drive_start();

                //address frame (7-bit address + RW + ACK)
                `uvm_info("DRIVER" , $sformatf("Driving address: 0x%0h, access: %0s" , item.slave_addr , item.access_type.name()) , UVM_LOW)
                drive_byte({item.slave_addr , item.access_type});
                sample_bit(addr_ack);
                `uvm_info("DRIVER" , $sformatf("Address ACK sampled: %0s" , addr_ack ? "NACK" : "ACK") , UVM_HIGH)
                if(addr_ack)begin
                    `uvm_info("DRIVER" , "Address was NACKed; driving STOP" , UVM_LOW)
                    drive_stop();
                    return;
                end
                // sda held high for 2 cycles
                `uvm_info("DRIVER" , "Releasing SDA between address and data" , UVM_LOW)
                repeat(2)begin
                    @(posedge vif.clk);
                    sda_release();
                    
                end
                // drive data_frame(s)
                foreach (item.data[idx]) begin
                    //`uvm_info("DRIVER" , $sformatf("Data byte %0d/%0d: 0x%0h" , idx + 1 , item.data.size() , item.data[idx]) , UVM_LOW)
                    case (item.access_type)
                        I2C_WRITE: begin
                            bit data_ack;
                            `uvm_info("DRIVER" , $sformatf("Data byte %0d/%0d: 0x%0h" , idx + 1 , item.data.size() , item.data[idx]) , UVM_LOW)
                            `uvm_info("DRIVER" , "Driving WRITE data byte" , UVM_LOW)
                            drive_byte(item.data[idx]);
                            sample_bit(data_ack);
                            `uvm_info("DRIVER" , $sformatf("Data ACK sampled: %0s" , data_ack ? "NACK" : "ACK") , UVM_LOW)
                            if(data_ack)begin
                                `uvm_info("DRIVER" , "Data byte was NACKed; driving STOP" , UVM_LOW)
                                drive_stop();
                                return;
                            end
                        end
                        I2C_READ : begin
                            logic read_bit;
                            `uvm_info("DRIVER" , "Sampling READ data byte" , UVM_LOW)
                            for(int i = 7 ; i >= 0 ; i--) begin
                                // slave driving the SDA line with the data read
                                sample_bit(read_bit);
                            end
                            //ack part from the controller
                            `uvm_info("DRIVER" , "Driving controller response for READ data" , UVM_LOW)
                            drive_bit(item.data_response);
                            if(item.data_response)begin
                                `uvm_info("DRIVER" , "Controller response was NACK; driving STOP" , UVM_LOW)
                                drive_stop();
                                return;
                            end
                        end  
                    endcase
                end
                // stop condition
                if(i == item.num_starts - 1)begin
                    `uvm_info("DRIVER" , "Driving STOP condition" , UVM_LOW)
                    drive_stop();
                end
                else begin
                    `uvm_info("DRIVER" , "Preparing repeated START condition" , UVM_LOW)
                    return;
                end
            end
            `uvm_info("DRIVER" , "Transaction complete" , UVM_LOW)

        endtask

        virtual task drive_transactions();
            mh_i2c_item_drv#(ADDR_WIDTH) item;
            fork
                begin
                    process_drive_transaction = process::self();
                    forever begin
                        seq_item_port.get_next_item(item);
                            port_out_size.write(item.data.size());
                            drive_transaction(item);
                        seq_item_port.item_done();
                    end
                end
            join
            
            
        endtask

        virtual task run_phase(uvm_phase phase);
            forever begin
                agent_config.wait_reset_end();
                drive_transactions();    
            end          
        endtask

    endclass

`endif