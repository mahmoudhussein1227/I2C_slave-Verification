`ifndef MH_I2C_ENV_SV
    `define MH_I2C_ENV_SV

    class mh_i2c_env extends uvm_env implements mh_i2c_reset_handler;
        mh_i2c_agent_master#(`ADDR_WIDTH) agent_master;
        mh_i2c_model#(`ADDR_WIDTH) model;
        mh_i2c_predictor#(.BUSTYPE(mh_i2c_item_mon#(`ADDR_WIDTH)) , .ADDR_WIDTH(`ADDR_WIDTH)) predictor;
        mh_i2c_scoreboard#(`ADDR_WIDTH) scoreboard;
        `uvm_component_utils(mh_i2c_env)

        function new(string name = "" , uvm_component parent);
            super.new(name , parent);
        endfunction

        virtual function void build_phase(uvm_phase phase);
            super.build_phase(phase);
            agent_master = mh_i2c_agent_master#(`ADDR_WIDTH)::type_id::create("agent_master" , this);
            model = mh_i2c_model#(`ADDR_WIDTH)::type_id::create("model" , this);
            predictor = mh_i2c_predictor#(.BUSTYPE(mh_i2c_item_mon#(`ADDR_WIDTH)) , .ADDR_WIDTH(`ADDR_WIDTH))::type_id::create("predictor" , this);
            scoreboard = mh_i2c_scoreboard#(`ADDR_WIDTH)::type_id::create("scoreboard" , this);
        endfunction

        virtual function void connect_phase(uvm_phase phase);
            mh_i2c_reg_adapter#(`ADDR_WIDTH) adapter = mh_i2c_reg_adapter#(`ADDR_WIDTH)::type_id::create("adapter");
            super.connect_phase(phase);
            agent_master.monitor.port_out_addr.connect(model.port_in_addr);
            agent_master.monitor.port_out_data.connect(model.port_in_data);

            // bus monitor integration with the register model 
            predictor.map = model.reg_block.default_map;
            agent_master.monitor.port_out_data.connect(predictor.bus_in);
            predictor.adapter = adapter;
            

            // scoreboard connecitons
            agent_master.monitor.port_out_addr.connect(scoreboard.port_in_agent_addr);
            agent_master.monitor.port_out_data.connect(scoreboard.port_in_agent_data);
            model.port_out_model_addr.connect(scoreboard.port_in_model_addr);
            model.port_out_model_data.connect(scoreboard.port_in_model_data);

            agent_master.driver.port_out_size.connect(model.port_in_size);

        endfunction

        virtual function void handle_reset(uvm_phase phase);
            model.handle_reset(phase);
        endfunction

        virtual task run_phase(uvm_phase phase);
            forever begin
                agent_master.agent_config.wait_reset_start();
                handle_reset(phase);
                agent_master.agent_config.wait_reset_end();
            end
        endtask

    endclass

`endif