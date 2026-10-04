`ifndef MH_I2C_TEST_RESET_ONGOING_SV
    `define MH_I2C_TEST_RESET_ONGOING_SV

    class mh_i2c_test_reset_ongoing extends mh_i2c_test_base;
        int unsigned wait_period;
        i2c_vif vif;
        bit start;
        `uvm_component_utils(mh_i2c_test_reset_ongoing)
        function new(string name = "" , uvm_component parent = null);
            super.new(name , parent);
        endfunction
        virtual task run_phase(uvm_phase phase);
            `uvm_info("DEBUG" , "START OF TEST" , UVM_LOW)
            phase.raise_objection(this);

            #200;
           
            fork
                begin
                    mh_i2c_seq_simple_write#(`ADDR_WIDTH) seq = mh_i2c_seq_simple_write#(`ADDR_WIDTH)::type_id::create("seq");
                    void'(seq.randomize());
                    seq.start(env.agent_master.sequencer);
                end

                begin
                        wait_period = $urandom_range(10 , 26);
                        vif = env.agent_master.agent_config.get_vif();
                        env.agent_master.monitor.sample_start(start);
                        if(start)begin
                            repeat(wait_period)begin
                                @(posedge vif.scl);
                            end
                            #30;
                            vif.reset_n = 0;
                            #30;
                            vif.reset_n = 1;
                        end    
                end
            join  
            
            #1000;
            `uvm_info("DEBUG" , "END OF TEST" , UVM_LOW)
            phase.drop_objection(this);

        endtask

    endclass

`endif