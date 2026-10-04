`ifndef MH_I2C_TEST_BASE_SV
    `define MH_I2C_TEST_BASE_SV
    
    class mh_i2c_test_base extends uvm_test;
        // env handle
        mh_i2c_env env;
        `uvm_component_utils(mh_i2c_test_base)

        function new (string name = "" , uvm_component parent);
            super.new(name , parent);
        endfunction

        virtual function void build_phase(uvm_phase phase);
            super.build_phase(phase);
            // create the env
            env = mh_i2c_env::type_id::create("env" , this);
            
        endfunction

        virtual task run_phase(uvm_phase phase);
            phase.raise_objection(this);
                #200;
                `uvm_info("DEBUG" , "START OF TEST" , UVM_LOW)
    
                repeat(20)begin
                    begin
                        mh_i2c_seq_simple_write#(`ADDR_WIDTH) seq = mh_i2c_seq_simple_write#(`ADDR_WIDTH)::type_id::create("seq");
                        void'(seq.randomize());
                        seq.start(env.agent_master.sequencer);
                    end

                    begin
                        mh_i2c_seq_simple_read#(`ADDR_WIDTH) seq = mh_i2c_seq_simple_read#(`ADDR_WIDTH)::type_id::create("seq");
                        void'(seq.randomize());
                        seq.start(env.agent_master.sequencer);
                    end
                end

                    /*
                    begin
                        i2c_vif vif;
                        vif = env.agent_master.agent_config.get_vif();
                        #40;
                        vif.reset_n <= 0;
                        #53;
                        vif.reset_n <= 1;
                    end
                    */

/*
                begin
                    mh_i2c_seq_simple_write#(`ADDR_WIDTH) seq = mh_i2c_seq_simple_write#(`ADDR_WIDTH)::type_id::create("seq");
                    seq.start(env.agent_master.sequencer);
                end
*/              
                #1000;
                `uvm_info("DEBUG" , "END OF TEST" , UVM_LOW)
            phase.drop_objection(this);

        endtask

    endclass

`endif