`ifndef MH_I2C_AGENT_MASTER_SV
    `define MH_I2C_AGENT_MASTER_SV

    class mh_i2c_agent_master#(int unsigned ADDR_WIDTH = 2) extends uvm_agent implements mh_i2c_reset_handler;
        // vif handle
        i2c_vif vif;
        // agent_config_handle
        mh_i2c_agent_master_config agent_config;
        // sequencer handle
        mh_i2c_sequencer#(ADDR_WIDTH) sequencer;
        // driver handle
        mh_i2c_driver#(ADDR_WIDTH) driver;
        //monitor handle
        mh_i2c_monitor#(ADDR_WIDTH) monitor;
        //coverage handle
        mh_i2c_coverage#(ADDR_WIDTH) coverage;
        `uvm_component_param_utils(mh_i2c_agent_master#(ADDR_WIDTH))
        function new(string name = "" , uvm_component parent);
            super.new(name ,parent);
        endfunction

        virtual function void build_phase(uvm_phase phase);
            super.build_phase(phase);
            agent_config = mh_i2c_agent_master_config::type_id::create("agent_config" , this);

            if(agent_config.get_active_passive())begin
                sequencer = mh_i2c_sequencer#(ADDR_WIDTH)::type_id::create("sequencer" , this);
                driver    = mh_i2c_driver#(ADDR_WIDTH)::type_id::create("driver" , this);
            end
            monitor =  mh_i2c_monitor#(ADDR_WIDTH)::type_id::create("monitor" , this);
            // has_coverage check
            if(agent_config.get_has_coverage())begin
                coverage = mh_i2c_coverage#(ADDR_WIDTH)::type_id::create("coverage" , this);    
            end
            
        endfunction

        virtual function void connect_phase(uvm_phase phase);
            super.connect_phase(phase);

            if(!uvm_config_db#(i2c_vif)::get(this , "" , "vif" , vif))begin
                `uvm_fatal("ALG_ISSUE" , "can't retrive the vif from the config_db")
            end
            agent_config.set_vif(vif);

            if(agent_config.get_active_passive())begin
                driver.seq_item_port.connect(sequencer.seq_item_export);
                driver.agent_config = agent_config;
                driver.port_out_size.connect(monitor.port_in_size);
            end
            monitor.agent_config = agent_config;
            // has_coverage check
            if(agent_config.get_has_coverage())begin
                monitor.port_out_addr.connect(coverage.port_in_addr);
                monitor.port_out_data.connect(coverage.port_in_data);
            end
        endfunction

        virtual function void handle_reset(uvm_phase phase);
            uvm_component children[$];
            get_children(children);
            foreach (children[idx]) begin
                mh_i2c_reset_handler reset_handler;
                if($cast(reset_handler , children[idx]))begin
                    reset_handler.handle_reset(phase);
                end
            end
        endfunction

        virtual task run_phase(uvm_phase phase);
            forever begin
                agent_config.wait_reset_start();
                handle_reset(phase);
                agent_config.wait_reset_end();
            end
        endtask

    endclass

`endif